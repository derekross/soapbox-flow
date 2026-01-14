#!/usr/bin/env python3
"""
Taskwarrior Sync

Syncs tasks between Taskwarrior and GitLab.
- Pull: Get pending Taskwarrior tasks for daily report
- Push: Create Taskwarrior tasks from GitLab issues/MRs
- Sync: Mark GitLab issues closed when Taskwarrior tasks complete
"""

import json
import subprocess
from datetime import datetime, timezone


def run_task_command(*args, json_output=True):
    """Run a taskwarrior command and return output."""
    cmd = ["task", "rc.confirmation=off", "rc.verbose=nothing"]
    if json_output:
        cmd.append("rc.json.array=on")
    cmd.extend(args)

    result = subprocess.run(cmd, capture_output=True, text=True)

    if json_output and result.stdout.strip():
        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError:
            return []
    return result.stdout


def get_pending_tasks():
    """Get all pending tasks from Taskwarrior."""
    tasks = run_task_command("status:pending", "export")
    if isinstance(tasks, list):
        return tasks
    return []


def get_gitlab_tasks():
    """Get tasks that originated from GitLab."""
    tasks = run_task_command("status:pending", "gitlab_id.any:", "export")
    if isinstance(tasks, list):
        return tasks
    return []


def get_completed_gitlab_tasks():
    """Get completed tasks that have GitLab IDs (for syncing back)."""
    tasks = run_task_command("status:completed", "gitlab_id.any:", "end.after:today-1d", "export")
    if isinstance(tasks, list):
        return tasks
    return []


def task_exists_for_gitlab(gitlab_type, gitlab_id):
    """Check if a Taskwarrior task already exists for a GitLab item."""
    tasks = run_task_command(
        f"gitlab_type:{gitlab_type}",
        f"gitlab_id:{gitlab_id}",
        "export"
    )
    return len(tasks) > 0 if isinstance(tasks, list) else False


def create_task_from_gitlab(item_type, item):
    """Create a Taskwarrior task from a GitLab issue or MR."""
    if item_type == "issue":
        gitlab_id = f"issue-{item.project_id}-{item.iid}"
        description = f"[GitLab Issue] {item.title}"
        project = item.references.get("full", "").rsplit("#", 1)[0].rstrip()
        url = item.web_url
        priority = "M"

        # Set priority based on labels
        labels = getattr(item, 'labels', []) or []
        if any(l.lower() in ['critical', 'urgent', 'high'] for l in labels):
            priority = "H"
        elif any(l.lower() in ['low'] for l in labels):
            priority = "L"

        # Add due date if present
        due_arg = []
        if item.due_date:
            due_arg = [f"due:{item.due_date}"]

    elif item_type == "mr":
        gitlab_id = f"mr-{item.project_id}-{item.iid}"
        description = f"[GitLab MR] {item.title}"
        project = item.references.get("full", item.source_project_id)
        url = item.web_url
        priority = "H"  # MRs are usually higher priority
        due_arg = []
    else:
        return False

    # Check if task already exists
    if task_exists_for_gitlab(item_type, gitlab_id):
        return False

    # Create the task
    cmd = [
        "add",
        description,
        f"gitlab_type:{item_type}",
        f"gitlab_id:{gitlab_id}",
        f"gitlab_url:{url}",
        f"gitlab_project:{project}",
        f"priority:{priority}",
        "+gitlab",
    ] + due_arg

    run_task_command(*cmd, json_output=False)
    return True


def sync_gitlab_issues_to_taskwarrior(issues, mrs_assigned=None):
    """Create Taskwarrior tasks from GitLab issues and assigned MRs."""
    created = 0

    for issue in issues:
        if create_task_from_gitlab("issue", issue):
            created += 1
            print(f"  Created task for issue: {issue.title[:50]}...")

    if mrs_assigned:
        for mr in mrs_assigned:
            if create_task_from_gitlab("mr", mr):
                created += 1
                print(f"  Created task for MR: {mr.title[:50]}...")

    return created


def complete_task_by_gitlab_id(gitlab_type, gitlab_id):
    """Mark a Taskwarrior task as complete."""
    run_task_command(
        f"gitlab_type:{gitlab_type}",
        f"gitlab_id:{gitlab_id}",
        "done",
        json_output=False
    )


def format_task_for_markdown(task):
    """Format a Taskwarrior task as markdown."""
    desc = task.get('description', 'No description')
    priority = task.get('priority', '')
    project = task.get('project', '')
    due = task.get('due', '')
    gitlab_url = task.get('gitlab_url', '')
    tags = task.get('tags', [])

    priority_icon = {'H': '!!!', 'M': '!!', 'L': '!'}.get(priority, '')

    parts = [f"- [ ] {desc}"]

    if priority_icon:
        parts[0] = f"- [ ] {priority_icon} {desc}"

    meta = []
    if project:
        meta.append(f"project:{project}")
    if due:
        # Format due date
        try:
            due_dt = datetime.strptime(due[:8], "%Y%m%d")
            meta.append(f"due:{due_dt.strftime('%Y-%m-%d')}")
        except:
            pass
    if 'gitlab' in tags and gitlab_url:
        meta.append(f"[GitLab]({gitlab_url})")

    if meta:
        parts.append(f"  - {' | '.join(meta)}")

    return "\n".join(parts)


def fetch_taskwarrior_tasks():
    """Fetch tasks for the daily report."""
    tasks = get_pending_tasks()

    # Sort by priority (H > M > L > none) then by urgency
    priority_order = {'H': 0, 'M': 1, 'L': 2, '': 3}
    tasks.sort(key=lambda t: (
        priority_order.get(t.get('priority', ''), 3),
        -t.get('urgency', 0)
    ))

    return tasks


def main():
    """Run Taskwarrior sync standalone."""
    print("Fetching Taskwarrior tasks...")
    tasks = fetch_taskwarrior_tasks()

    print(f"\nFound {len(tasks)} pending tasks:")
    for task in tasks[:10]:
        print(f"  - [{task.get('priority', ' ')}] {task.get('description', '')[:60]}")

    gitlab_tasks = get_gitlab_tasks()
    print(f"\nGitLab-linked tasks: {len(gitlab_tasks)}")


if __name__ == "__main__":
    main()
