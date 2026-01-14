#!/usr/bin/env python3
"""
GitLab Sync

Fetches MRs, issues, todos, and project activity from GitLab.
"""

from datetime import datetime, timedelta, timezone

import gitlab

from config import GITLAB_URL, GITLAB_TOKEN, ACTIVITY_DAYS, validate_config


def get_gitlab_client():
    """Initialize and return GitLab client."""
    validate_config()
    gl = gitlab.Gitlab(GITLAB_URL, private_token=GITLAB_TOKEN)
    gl.auth()
    return gl


def time_ago(dt):
    """Convert datetime to human-readable time ago string."""
    if dt is None:
        return "unknown"

    if isinstance(dt, str):
        dt = datetime.fromisoformat(dt.replace("Z", "+00:00"))

    now = datetime.now(timezone.utc)
    diff = now - dt

    if diff.days > 0:
        return f"{diff.days}d ago"
    hours = diff.seconds // 3600
    if hours > 0:
        return f"{hours}h ago"
    minutes = diff.seconds // 60
    return f"{minutes}m ago"


def get_mr_details(gl, mr):
    """Get detailed MR info including approvals and discussions."""
    try:
        project = gl.projects.get(mr.project_id)
        detailed_mr = project.mergerequests.get(mr.iid)

        # Get approval info
        approvals = None
        try:
            approvals = detailed_mr.approvals.get()
        except Exception:
            pass

        # Check for unresolved discussions
        has_unresolved = False
        try:
            discussions = detailed_mr.discussions.list(get_all=True)
            for disc in discussions:
                for note in disc.attributes.get('notes', []):
                    if note.get('resolvable') and not note.get('resolved'):
                        has_unresolved = True
                        break
        except Exception:
            pass

        return {
            'mr': mr,
            'approvals': approvals,
            'has_unresolved_discussions': has_unresolved,
            'detailed': detailed_mr
        }
    except Exception:
        return {'mr': mr, 'approvals': None, 'has_unresolved_discussions': False, 'detailed': None}


def categorize_mrs(gl):
    """
    Fetch and categorize MRs like GitLab dashboard.
    """
    user = gl.user
    categories = {
        'review_requested': [],
        'return_to_you': [],
        'your_mrs_waiting': [],
        'assigned_to_you': [],
        'approved_by_you': [],
    }

    seen_mr_ids = set()

    # 1. MRs where you're a reviewer
    print("  Checking MRs where you're a reviewer...")
    reviewer_mrs = gl.mergerequests.list(
        reviewer_username=user.username,
        state="opened",
        scope="all",
        get_all=True
    )

    for mr in reviewer_mrs:
        if mr.id in seen_mr_ids:
            continue
        seen_mr_ids.add(mr.id)

        details = get_mr_details(gl, mr)
        approvals = details.get('approvals')

        user_approved = False
        if approvals:
            approved_by = getattr(approvals, 'approved_by', []) or []
            for approver in approved_by:
                if approver.get('user', {}).get('id') == user.id:
                    user_approved = True
                    break

        if user_approved:
            categories['approved_by_you'].append(details)
        else:
            categories['review_requested'].append(details)

    # 2. MRs you authored
    print("  Checking your authored MRs...")
    authored_mrs = gl.mergerequests.list(
        author_id=user.id,
        state="opened",
        scope="all",
        get_all=True
    )

    for mr in authored_mrs:
        if mr.id in seen_mr_ids:
            continue
        seen_mr_ids.add(mr.id)

        details = get_mr_details(gl, mr)

        if details.get('has_unresolved_discussions'):
            categories['return_to_you'].append(details)
        else:
            categories['your_mrs_waiting'].append(details)

    # 3. MRs assigned to you (but not authored by you)
    print("  Checking MRs assigned to you...")
    assigned_mrs = gl.mergerequests.list(
        assignee_id=user.id,
        state="opened",
        scope="all",
        get_all=True
    )

    for mr in assigned_mrs:
        if mr.id in seen_mr_ids:
            continue
        seen_mr_ids.add(mr.id)

        if mr.author.get('id') != user.id:
            details = get_mr_details(gl, mr)
            categories['assigned_to_you'].append(details)

    return categories


def fetch_issues_assigned(gl):
    """Fetch issues assigned to current user."""
    issues = gl.issues.list(
        assignee_id=gl.user.id,
        state="opened",
        scope="all",
        get_all=True
    )
    return list(issues)


def fetch_issues_authored(gl):
    """Fetch issues authored by current user."""
    issues = gl.issues.list(
        author_id=gl.user.id,
        state="opened",
        scope="all",
        get_all=True
    )
    return list(issues)


def fetch_gitlab_todos(gl):
    """Fetch pending GitLab todos."""
    todos = gl.todos.list(state="pending", get_all=True)
    return list(todos)


def fetch_starred_project_activity(gl):
    """Fetch recent activity from starred projects."""
    starred = gl.projects.list(starred=True, get_all=True)
    cutoff = datetime.now(timezone.utc) - timedelta(days=ACTIVITY_DAYS)

    activity = []
    for project in starred:
        try:
            events = project.events.list(per_page=20, get_all=False)
            for event in events:
                event_time = datetime.fromisoformat(
                    event.created_at.replace("Z", "+00:00")
                )
                if event_time > cutoff:
                    activity.append({
                        "project": project.path_with_namespace,
                        "project_url": project.web_url,
                        "action": event.action_name,
                        "target_type": getattr(event, "target_type", None),
                        "target_title": getattr(event, "target_title", None),
                        "target_iid": getattr(event, "target_iid", None),
                        "created_at": event_time,
                        "author": getattr(event, "author_username", "unknown"),
                    })
        except gitlab.exceptions.GitlabGetError:
            continue

    activity.sort(key=lambda x: x["created_at"], reverse=True)
    return activity[:50]


def fetch_all_gitlab_data(gl):
    """Fetch all GitLab data and return as dict."""
    print("Fetching GitLab todos...")
    todos = fetch_gitlab_todos(gl)
    print(f"  Found {len(todos)} pending todos")

    print("Fetching and categorizing merge requests...")
    mr_categories = categorize_mrs(gl)
    print(f"  Review requested: {len(mr_categories['review_requested'])}")
    print(f"  Return to you: {len(mr_categories['return_to_you'])}")
    print(f"  Your MRs waiting: {len(mr_categories['your_mrs_waiting'])}")
    print(f"  Assigned to you: {len(mr_categories['assigned_to_you'])}")
    print(f"  Approved by you: {len(mr_categories['approved_by_you'])}")

    print("Fetching assigned issues...")
    issues_assigned = fetch_issues_assigned(gl)
    print(f"  Found {len(issues_assigned)} issues")

    print("Fetching authored issues...")
    issues_authored = fetch_issues_authored(gl)
    print(f"  Found {len(issues_authored)} issues")

    print("Fetching starred project activity...")
    activity = fetch_starred_project_activity(gl)
    print(f"  Found {len(activity)} events")

    return {
        'todos': todos,
        'mr_categories': mr_categories,
        'issues_assigned': issues_assigned,
        'issues_authored': issues_authored,
        'activity': activity,
    }


def main():
    """Run GitLab sync standalone."""
    print("Connecting to GitLab...")
    gl = get_gitlab_client()
    print(f"Authenticated as: {gl.user.username}\n")
    fetch_all_gitlab_data(gl)


if __name__ == "__main__":
    main()
