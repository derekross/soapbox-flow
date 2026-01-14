#!/bin/bash

# Soapbox Flow Configuration Wizard
# Interactive setup for all integrations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Config file location
CONFIG_DIR="$HOME/.config/soapbox-flow"
CONFIG_FILE="$CONFIG_DIR/config.env"

# Print functions
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_substep() {
    echo -e "  ${GREEN}•${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Prompt for input with default
prompt_with_default() {
    local prompt=$1
    local default=$2
    local var_name=$3

    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " value
        value="${value:-$default}"
    else
        read -p "$prompt: " value
    fi

    eval "$var_name=\"$value\""
}

# Prompt for secret input
prompt_secret() {
    local prompt=$1
    local var_name=$2

    read -s -p "$prompt: " value
    echo ""

    eval "$var_name=\"$value\""
}

# Save configuration
save_config() {
    mkdir -p "$CONFIG_DIR"

    cat > "$CONFIG_FILE" << EOF
# Soapbox Flow Configuration
# Generated: $(date)

# User Info
USER_NAME="$USER_NAME"
USER_EMAIL="$USER_EMAIL"

# Paths
VAULT_PATH="$VAULT_PATH"
TASKS_PATH="$TASKS_PATH"
SCHEDULE_PATH="$SCHEDULE_PATH"

# GitLab
GITLAB_URL="$GITLAB_URL"
GITLAB_TOKEN="$GITLAB_TOKEN"
GITLAB_PROJECT_IDS="$GITLAB_PROJECT_IDS"

# GitHub
GITHUB_TOKEN="$GITHUB_TOKEN"

# Nostr
NOSTR_NPUB="$NOSTR_NPUB"
NOSTR_RELAYS="$NOSTR_RELAYS"

# Timezone
TIMEZONE="$TIMEZONE"
EOF

    chmod 600 "$CONFIG_FILE"
    print_success "Configuration saved to $CONFIG_FILE"
}

# Load existing configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        print_info "Loaded existing configuration from $CONFIG_FILE"
    fi
}

# Configure user info
configure_user() {
    print_header "User Information"

    prompt_with_default "Your name" "${USER_NAME:-$(git config --global user.name 2>/dev/null || echo '')}" USER_NAME
    prompt_with_default "Your email" "${USER_EMAIL:-$(git config --global user.email 2>/dev/null || echo '')}" USER_EMAIL
    prompt_with_default "Timezone" "${TIMEZONE:-$(timedatectl show -p Timezone --value 2>/dev/null || echo 'America/Chicago')}" TIMEZONE

    print_success "User info configured"
}

# Configure paths
configure_paths() {
    print_header "Directory Paths"

    echo ""
    print_info "These paths are where your data will be stored."
    echo ""

    prompt_with_default "Obsidian vault path" "${VAULT_PATH:-$HOME/Vault}" VAULT_PATH
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

    prompt_with_default "Tasks output path" "${TASKS_PATH:-$VAULT_PATH/Work/Tasks}" TASKS_PATH
    TASKS_PATH="${TASKS_PATH/#\~/$HOME}"

    prompt_with_default "Schedule output path" "${SCHEDULE_PATH:-$VAULT_PATH/Work/Schedule}" SCHEDULE_PATH
    SCHEDULE_PATH="${SCHEDULE_PATH/#\~/$HOME}"

    # Create directories
    mkdir -p "$VAULT_PATH" "$TASKS_PATH" "$SCHEDULE_PATH"

    print_success "Paths configured and directories created"
}

# Configure GitLab
configure_gitlab() {
    print_header "GitLab Integration"

    echo ""
    print_info "GitLab integration syncs issues to Taskwarrior."
    print_info "Create a token at: GitLab → Settings → Access Tokens"
    print_info "Required scopes: read_api"
    echo ""

    read -p "Configure GitLab integration? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_substep "Skipped GitLab configuration"
        return 0
    fi

    prompt_with_default "GitLab URL" "${GITLAB_URL:-https://gitlab.com}" GITLAB_URL
    prompt_secret "GitLab access token" GITLAB_TOKEN

    echo ""
    print_info "Enter project IDs separated by commas (e.g., 123,456,789)"
    print_info "Find project ID: Project → Settings → General"
    prompt_with_default "GitLab project IDs" "$GITLAB_PROJECT_IDS" GITLAB_PROJECT_IDS

    # Test connection
    if [[ -n "$GITLAB_TOKEN" ]]; then
        print_substep "Testing GitLab connection..."
        if curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/user" | grep -q '"id"'; then
            print_success "GitLab connection successful"
        else
            print_warning "Could not verify GitLab connection. Check your token."
        fi
    fi
}

# Configure GitHub
configure_github() {
    print_header "GitHub Integration"

    echo ""
    print_info "GitHub integration syncs issues and PRs."
    print_info "Create a token at: GitHub → Settings → Developer settings → Personal access tokens"
    echo ""

    read -p "Configure GitHub integration? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_substep "Skipped GitHub configuration"
        return 0
    fi

    prompt_secret "GitHub personal access token" GITHUB_TOKEN

    # Test connection
    if [[ -n "$GITHUB_TOKEN" ]]; then
        print_substep "Testing GitHub connection..."
        if curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user" | grep -q '"login"'; then
            print_success "GitHub connection successful"
        else
            print_warning "Could not verify GitHub connection. Check your token."
        fi
    fi
}

# Configure Nostr
configure_nostr() {
    print_header "Nostr Configuration"

    echo ""
    print_info "Configure your Nostr identity for publishing and broadcasting."
    echo ""

    read -p "Configure Nostr? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_substep "Skipped Nostr configuration"
        return 0
    fi

    # Check for existing npub
    if [[ -n "$NOSTR_NPUB" ]]; then
        print_info "Current npub: $NOSTR_NPUB"
        read -p "Keep existing npub? [Y/n] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_substep "Keeping existing npub"
        else
            NOSTR_NPUB=""
        fi
    fi

    if [[ -z "$NOSTR_NPUB" ]]; then
        echo ""
        echo "Options:"
        echo "  1. Enter existing npub"
        echo "  2. Generate new keypair"
        echo ""
        read -p "Choose [1/2]: " -n 1 -r
        echo ""

        if [[ $REPLY == "2" ]]; then
            if command_exists nak; then
                print_substep "Generating new keypair..."
                KEYS=$(nak key generate 2>/dev/null)
                NSEC=$(echo "$KEYS" | head -1)
                NPUB=$(nak key public "$NSEC" 2>/dev/null)
                NOSTR_NPUB="$NPUB"

                echo ""
                print_warning "SAVE YOUR SECRET KEY SECURELY!"
                echo -e "${RED}nsec: $NSEC${NC}"
                echo -e "npub: $NPUB"
                echo ""
                print_warning "The nsec will NOT be saved. Store it in a password manager!"
                read -p "Press Enter when you've saved your nsec..."
            else
                print_error "nak not installed. Run ./install.sh first."
                return 1
            fi
        else
            prompt_with_default "Your npub" "$NOSTR_NPUB" NOSTR_NPUB
        fi
    fi

    # Configure relays
    echo ""
    print_info "Enter your preferred relays (comma-separated)"
    DEFAULT_RELAYS="wss://relay.damus.io,wss://relay.primal.net,wss://nos.lol,wss://relay.ditto.pub"
    prompt_with_default "Relays" "${NOSTR_RELAYS:-$DEFAULT_RELAYS}" NOSTR_RELAYS

    print_success "Nostr configured"
}

# Configure Taskwarrior
configure_taskwarrior() {
    print_header "Taskwarrior Configuration"

    if ! command_exists task; then
        print_warning "Taskwarrior not installed. Run ./install.sh first."
        return 1
    fi

    # Check if already configured
    if [[ -f "$HOME/.taskrc" ]]; then
        print_info "Taskwarrior already configured at ~/.taskrc"
        read -p "Reconfigure? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_substep "Keeping existing configuration"
            return 0
        fi
    fi

    print_substep "Creating Taskwarrior configuration..."

    cat > "$HOME/.taskrc" << EOF
# Taskwarrior configuration
# Generated by Soapbox Flow

# Data location
data.location=~/.task

# Color theme
include /usr/share/taskwarrior/dark-256.theme

# Custom UDAs for GitLab integration
uda.gitlab_id.type=numeric
uda.gitlab_id.label=GitLab ID
uda.gitlab_url.type=string
uda.gitlab_url.label=GitLab URL
uda.gitlab_project.type=string
uda.gitlab_project.label=GitLab Project

# Date format
dateformat=Y-M-D
dateformat.report=Y-M-D
dateformat.annotation=Y-M-D

# Default due date for tasks without one
default.due=

# Urgency coefficients
urgency.user.tag.next.coefficient=15.0
urgency.user.tag.today.coefficient=10.0

# Reports
report.next.columns=id,start.age,entry.age,depends,priority,project,tags,recur,scheduled.countdown,due.relative,until.remaining,description,urgency
report.next.labels=ID,Active,Age,Deps,P,Project,Tag,Recur,S,Due,Until,Description,Urg
EOF

    print_success "Taskwarrior configured"

    # Create first task
    print_substep "Creating welcome task..."
    task add "Welcome to Soapbox Flow! Run 'task list' to see your tasks." +welcome 2>/dev/null || true
}

# Configure calendar (khal/vdirsyncer)
configure_calendar() {
    print_header "Calendar Configuration"

    echo ""
    print_info "Calendar sync uses vdirsyncer + khal."
    print_info "This requires a CalDAV server (Google Calendar, Nextcloud, etc.)"
    echo ""

    read -p "Configure calendar sync? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_substep "Skipped calendar configuration"
        return 0
    fi

    echo ""
    echo "Calendar providers:"
    echo "  1. Google Calendar"
    echo "  2. Nextcloud/Other CalDAV"
    echo "  3. Skip for now"
    echo ""
    read -p "Choose [1/2/3]: " -n 1 -r
    echo ""

    case $REPLY in
        1)
            print_info "Google Calendar requires OAuth setup."
            print_info "See: docs/integrations/google-calendar.md for detailed instructions"
            print_warning "Manual configuration required for Google Calendar"
            ;;
        2)
            prompt_with_default "CalDAV URL" "" CALDAV_URL
            prompt_with_default "CalDAV username" "$USER_EMAIL" CALDAV_USER
            prompt_secret "CalDAV password" CALDAV_PASS

            # Create vdirsyncer config
            mkdir -p ~/.config/vdirsyncer
            cat > ~/.config/vdirsyncer/config << EOF
[general]
status_path = "~/.local/share/vdirsyncer/status/"

[pair calendar]
a = "calendar_local"
b = "calendar_remote"
collections = ["from a", "from b"]
metadata = ["color"]

[storage calendar_local]
type = "filesystem"
path = "~/.local/share/khal/calendars/"
fileext = ".ics"

[storage calendar_remote]
type = "caldav"
url = "$CALDAV_URL"
username = "$CALDAV_USER"
password = "$CALDAV_PASS"
EOF
            chmod 600 ~/.config/vdirsyncer/config
            print_success "vdirsyncer configured"
            ;;
        *)
            print_substep "Skipped calendar configuration"
            ;;
    esac
}

# Install OpenCode Sidebar plugin
configure_opencode_sidebar() {
    print_header "OpenCode Sidebar Plugin"

    if [[ -z "$VAULT_PATH" ]] || [[ ! -d "$VAULT_PATH" ]]; then
        print_warning "Vault path not configured or doesn't exist."
        return 1
    fi

    PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/opencode-sidebar"

    if [[ -d "$PLUGIN_DIR" ]]; then
        print_info "OpenCode Sidebar already installed"
        read -p "Reinstall/update? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi

    print_substep "Installing OpenCode Sidebar plugin..."
    mkdir -p "$PLUGIN_DIR"

    curl -sL "https://raw.githubusercontent.com/derekross/obsidian-opencode-sidebar/refs/heads/main/main.js" -o "$PLUGIN_DIR/main.js"
    curl -sL "https://raw.githubusercontent.com/derekross/obsidian-opencode-sidebar/refs/heads/main/manifest.json" -o "$PLUGIN_DIR/manifest.json"
    curl -sL "https://raw.githubusercontent.com/derekross/obsidian-opencode-sidebar/refs/heads/main/styles.css" -o "$PLUGIN_DIR/styles.css"

    print_success "OpenCode Sidebar installed to $PLUGIN_DIR"
    print_warning "Enable the plugin in Obsidian Settings > Community Plugins"
}

# Create sync scripts .env file
configure_sync_scripts() {
    print_header "Sync Scripts Configuration"

    ENV_FILE="$SCRIPT_DIR/scripts/sync/.env"

    print_substep "Creating sync scripts configuration..."

    cat > "$ENV_FILE" << EOF
# Sync Scripts Configuration
# Generated by Soapbox Flow configure.sh

# GitLab
GITLAB_URL=$GITLAB_URL
GITLAB_TOKEN=$GITLAB_TOKEN
GITLAB_PROJECT_IDS=$GITLAB_PROJECT_IDS

# Paths
VAULT_PATH=$VAULT_PATH
TASKS_PATH=$TASKS_PATH
SCHEDULE_PATH=$SCHEDULE_PATH

# Timezone
TIMEZONE=$TIMEZONE
EOF

    chmod 600 "$ENV_FILE"
    print_success "Sync scripts configured"
}

# Print configuration summary
print_summary() {
    print_header "Configuration Summary"

    echo ""
    echo "User: $USER_NAME <$USER_EMAIL>"
    echo "Timezone: $TIMEZONE"
    echo ""
    echo "Paths:"
    echo "  Vault: $VAULT_PATH"
    echo "  Tasks: $TASKS_PATH"
    echo "  Schedule: $SCHEDULE_PATH"
    echo ""
    echo "Integrations:"
    [[ -n "$GITLAB_TOKEN" ]] && echo -e "  ${GREEN}✓${NC} GitLab ($GITLAB_URL)" || echo -e "  ${YELLOW}○${NC} GitLab (not configured)"
    [[ -n "$GITHUB_TOKEN" ]] && echo -e "  ${GREEN}✓${NC} GitHub" || echo -e "  ${YELLOW}○${NC} GitHub (not configured)"
    [[ -n "$NOSTR_NPUB" ]] && echo -e "  ${GREEN}✓${NC} Nostr ($NOSTR_NPUB)" || echo -e "  ${YELLOW}○${NC} Nostr (not configured)"
    command_exists task && echo -e "  ${GREEN}✓${NC} Taskwarrior" || echo -e "  ${YELLOW}○${NC} Taskwarrior (not installed)"
    [[ -f ~/.config/vdirsyncer/config ]] && echo -e "  ${GREEN}✓${NC} Calendar sync" || echo -e "  ${YELLOW}○${NC} Calendar (not configured)"
    echo ""
    echo "Configuration saved to: $CONFIG_FILE"
    echo ""
}

# Main configuration wizard
main() {
    print_header "Soapbox Flow Configuration Wizard"

    echo ""
    echo "This wizard will help you configure:"
    echo "  • User information"
    echo "  • Directory paths"
    echo "  • GitLab/GitHub integration"
    echo "  • Nostr identity"
    echo "  • Taskwarrior"
    echo "  • Calendar sync"
    echo "  • OpenCode Sidebar plugin"
    echo ""

    read -p "Continue? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    # Load existing config
    load_config

    # Run configuration steps
    configure_user
    configure_paths
    configure_gitlab
    configure_github
    configure_nostr
    configure_taskwarrior
    configure_calendar
    configure_opencode_sidebar

    # Save configuration
    save_config
    configure_sync_scripts

    # Print summary
    print_summary

    print_header "Configuration Complete!"

    echo ""
    echo -e "${GREEN}Soapbox Flow is now configured!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Open Obsidian and enable OpenCode Sidebar plugin"
    echo "  2. Try: task list"
    echo "  3. Try: khal list today 7d"
    echo "  4. Try: python3 scripts/sync/daily_sync.py --dry-run"
    echo ""
    echo "Documentation: $SCRIPT_DIR/docs/"
    echo ""
}

# Run main
main "$@"
