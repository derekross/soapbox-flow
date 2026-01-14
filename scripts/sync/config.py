import os
from pathlib import Path

from dotenv import load_dotenv

# Load .env file from current directory or script directory
load_dotenv()

# GitLab Configuration
GITLAB_URL = os.getenv("GITLAB_URL", "https://gitlab.com")
GITLAB_TOKEN = os.getenv("GITLAB_TOKEN")

# Output Configuration
OUTPUT_DIR = Path(os.getenv("GITLAB_SYNC_OUTPUT", "./tasks"))

# How many days of activity to fetch from starred projects
ACTIVITY_DAYS = int(os.getenv("GITLAB_ACTIVITY_DAYS", "7"))

def validate_config():
    """Validate required configuration is present."""
    if not GITLAB_TOKEN:
        raise ValueError(
            "GITLAB_TOKEN environment variable is required.\n"
            "Create a token at: https://gitlab.com/-/user_settings/personal_access_tokens\n"
            "Required scopes: read_api"
        )
    return True
