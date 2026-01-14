#!/usr/bin/env python3
"""
Daily Sync

Combines calendar, GitLab, and Taskwarrior data into a prioritized daily task markdown file.
"""

import argparse
from datetime import datetime, timezone
from pathlib import Path

from config import OUTPUT_DIR
from calendar_sync import fetch_calendar_events
from gitlab_sync import get_gitlab_client, fetch_all_gitlab_data, time_ago
from taskwarrior_sync import (
    fetch_taskwarrior_tasks,
    format_task_for_markdown,
    sync_gitlab_issues_to_taskwarrior,
)


def format_mr_line(mr_details, show_approvals=True):
    """Format a merge request as a markdown checkbox line."""
    mr = mr_details['mr']
    approvals_info = mr_details.get('approvals')

    project = mr.references.get("full", mr.source_project_id)
    updated = time_ago(mr.updated_at)

    extra_info = []

    if show_approvals and approvals_info:
        approvals_left = getattr(approvals_info, 'approvals_left', None)
        if approvals_left is not None and approvals_left > 0:
            extra_info.append(f"{approvals_left} approvals needed")
        elif approvals_left == 0:
            extra_info.append("approved")

    if mr_details.get('has_unresolved_discussions'):
        extra_info.append("has discussions")

    extra_str = f" - {', '.join(extra_info)}" if extra_info else ""
    return f"- [ ] [!{mr.iid} {mr.title}]({mr.web_url}) - {project} - {updated}{extra_str}"


def format_issue_line(issue):
    """Format an issue as a markdown checkbox line."""
    project = issue.references.get("full", "").rsplit("#", 1)[0].rstrip()
    due = ""
    if issue.due_date:
        due = f" - due: {issue.due_date}"
    else:
        due = " - no due date"

    return f"- [ ] [#{issue.iid} {issue.title}]({issue.web_url}) - {project}{due}"


def format_todo_line(todo):
    """Format a GitLab todo item as a markdown line."""
    action = todo.action_name
    target_type = todo.target_type.lower() if todo.target_type else "item"
    title = getattr(todo, 'body', '') or getattr(todo.target, 'title', 'Untitled') if hasattr(todo, 'target') else 'Untitled'

    if len(title) > 60:
        title = title[:57] + "..."

    project = todo.project.get('path_with_namespace', '') if hasattr(todo, 'project') and todo.project else ''
    target_url = todo.target_url if hasattr(todo, 'target_url') else '#'

    return f"- [ ] [{target_type}: {title}]({target_url}) - {action} - {project}"


def format_activity_line(event):
    """Format an activity event as a markdown line."""
    action = event["action"]
    target = event["target_type"] or ""
    title = event["target_title"] or ""

    if target and title:
        return f"- {event['project']}: {action} {target.lower()} \"{title}\""
    elif action == "pushed to":
        return f"- {event['project']}: pushed new commits"
    else:
        return f"- {event['project']}: {action}"


def generate_markdown(calendar_events, gitlab_data, taskwarrior_tasks):
    """Generate the daily task markdown content."""
    today = datetime.now().strftime("%Y-%m-%d")
    weekday = datetime.now().strftime("%A")
    lines = [f"# Daily Tasks - {weekday}, {today}", ""]

    mr_categories = gitlab_data['mr_categories']
    gitlab_todos = gitlab_data['todos']
    issues_assigned = gitlab_data['issues_assigned']
    issues_authored = gitlab_data['issues_authored']
    activity = gitlab_data['activity']

    # Section: Today's Calendar
    lines.append(f"## Today's Schedule ({len(calendar_events)} events)")
    if calendar_events:
        for event in calendar_events:
            lines.append(f"- {event}")
    else:
        lines.append("_No calendar events today._")
    lines.append("")

    # Section: Taskwarrior Tasks
    lines.append(f"## Tasks ({len(taskwarrior_tasks)})")
    if taskwarrior_tasks:
        for task in taskwarrior_tasks[:20]:  # Limit to top 20
            lines.append(format_task_for_markdown(task))
    else:
        lines.append("_No pending tasks._")
    lines.append("")

    # Section: GitLab Todos
    lines.append(f"## GitLab Todos ({len(gitlab_todos)})")
    if gitlab_todos:
        for todo in gitlab_todos:
            lines.append(format_todo_line(todo))
    else:
        lines.append("_No pending GitLab todos._")
    lines.append("")

    # Section: Review Requested
    review_requested = mr_categories['review_requested']
    lines.append(f"## Urgent - Review Requested ({len(review_requested)})")
    if review_requested:
        for mr_details in review_requested:
            lines.append(format_mr_line(mr_details))
    else:
        lines.append("_No merge requests waiting for your review._")
    lines.append("")

    # Section: Return to You
    return_to_you = mr_categories['return_to_you']
    lines.append(f"## Action Required - Return to You ({len(return_to_you)})")
    if return_to_you:
        for mr_details in return_to_you:
            lines.append(format_mr_line(mr_details))
    else:
        lines.append("_None of your MRs need attention._")
    lines.append("")

    # Section: Your MRs Waiting
    your_mrs = mr_categories['your_mrs_waiting']
    lines.append(f"## Your Merge Requests ({len(your_mrs)})")
    if your_mrs:
        for mr_details in your_mrs:
            lines.append(format_mr_line(mr_details))
    else:
        lines.append("_No open merge requests submitted by you._")
    lines.append("")

    # Section: MRs Assigned to You
    assigned_mrs = mr_categories['assigned_to_you']
    lines.append(f"## MRs Assigned to You ({len(assigned_mrs)})")
    if assigned_mrs:
        for mr_details in assigned_mrs:
            lines.append(format_mr_line(mr_details))
    else:
        lines.append("_No merge requests assigned to you._")
    lines.append("")

    # Section: Approved by You
    approved_by_you = mr_categories['approved_by_you']
    lines.append(f"## Approved by You ({len(approved_by_you)})")
    if approved_by_you:
        for mr_details in approved_by_you:
            lines.append(format_mr_line(mr_details))
    else:
        lines.append("_No MRs you've approved are waiting to merge._")
    lines.append("")

    # Section: Issues assigned
    lines.append(f"## Assigned Issues ({len(issues_assigned)})")
    if issues_assigned:
        for issue in issues_assigned:
            lines.append(format_issue_line(issue))
    else:
        lines.append("_No issues assigned to you._")
    lines.append("")

    # Section: Issues authored
    lines.append(f"## Issues I'm Tracking ({len(issues_authored)})")
    if issues_authored:
        for issue in issues_authored:
            lines.append(format_issue_line(issue))
    else:
        lines.append("_No open issues authored by you._")
    lines.append("")

    # Section: Recent activity
    lines.append(f"## Recent Updates ({len(activity)} events)")
    if activity:
        seen = set()
        for event in activity[:20]:
            line = format_activity_line(event)
            if line not in seen:
                seen.add(line)
                lines.append(line)
    else:
        lines.append("_No recent activity from starred projects._")
    lines.append("")

    # Footer
    total_mrs = sum(len(mr_categories[k]) for k in mr_categories)
    lines.append("---")
    lines.append(f"**Summary:** {len(calendar_events)} events | {len(taskwarrior_tasks)} tasks | {len(gitlab_todos)} todos | {total_mrs} MRs | {len(issues_assigned)} assigned issues")
    lines.append(f"_Generated at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}_")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Sync calendar and GitLab tasks to daily markdown file"
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        default=OUTPUT_DIR,
        help=f"Output directory (default: {OUTPUT_DIR})"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print output to stdout instead of saving to file"
    )
    parser.add_argument(
        "--sync-to-taskwarrior",
        action="store_true",
        help="Create Taskwarrior tasks from GitLab assigned issues"
    )
    args = parser.parse_args()

    print("Syncing and fetching calendar events...")
    calendar_events = fetch_calendar_events()
    print(f"  Found {len(calendar_events)} events today")

    print("Connecting to GitLab...")
    gl = get_gitlab_client()
    print(f"Authenticated as: {gl.user.username}")

    gitlab_data = fetch_all_gitlab_data(gl)

    # Optionally sync GitLab issues to Taskwarrior
    if args.sync_to_taskwarrior:
        print("Syncing GitLab issues to Taskwarrior...")
        created = sync_gitlab_issues_to_taskwarrior(gitlab_data['issues_assigned'])
        print(f"  Created {created} new tasks")

    print("Fetching Taskwarrior tasks...")
    taskwarrior_tasks = fetch_taskwarrior_tasks()
    print(f"  Found {len(taskwarrior_tasks)} pending tasks")

    print("Generating markdown...")
    content = generate_markdown(calendar_events, gitlab_data, taskwarrior_tasks)

    if args.dry_run:
        print("\n" + "=" * 60 + "\n")
        print(content)
    else:
        args.output.mkdir(parents=True, exist_ok=True)
        filename = datetime.now().strftime("%Y-%m-%d") + "-tasks.md"
        filepath = args.output / filename
        filepath.write_text(content)
        print(f"\nSaved to: {filepath}")


if __name__ == "__main__":
    main()
