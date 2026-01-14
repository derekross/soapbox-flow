#!/bin/bash

# Soapbox Flow Uninstaller
# Removes symlinks and configuration (keeps user data)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  $1${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header "Soapbox Flow Uninstaller"

echo ""
echo "This will remove:"
echo "  • Claude Code skill symlinks"
echo "  • Soapbox Flow configuration (~/.config/soapbox-flow/)"
echo ""
echo "This will NOT remove:"
echo "  • Installed tools (nak, taskwarrior, khal, etc.)"
echo "  • Your data (tasks, calendars, vault)"
echo "  • Tool configurations (~/.taskrc, ~/.config/khal/, etc.)"
echo ""

read -p "Continue with uninstall? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Remove skill symlinks
print_step "Removing Claude Code skill symlinks..."
for skill in executive-assistant nostr-devrel content-research-writer planning-with-files docx pptx xlsx strategic-planning; do
    target="$HOME/.claude/skills/$skill"
    if [[ -L "$target" ]]; then
        rm "$target"
        echo "  Removed: $skill"
    fi
done

# Remove Soapbox Flow config
print_step "Removing Soapbox Flow configuration..."
if [[ -d "$HOME/.config/soapbox-flow" ]]; then
    rm -rf "$HOME/.config/soapbox-flow"
    echo "  Removed: ~/.config/soapbox-flow/"
fi

# Ask about OpenCode Sidebar plugin
echo ""
read -p "Remove OpenCode Sidebar plugin from Obsidian? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter vault path: " VAULT_PATH
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
    PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/opencode-sidebar"
    if [[ -d "$PLUGIN_DIR" ]]; then
        rm -rf "$PLUGIN_DIR"
        echo "  Removed: OpenCode Sidebar plugin"
    else
        echo "  Plugin not found at $PLUGIN_DIR"
    fi
fi

print_header "Uninstall Complete"

echo ""
echo "Soapbox Flow has been uninstalled."
echo ""
echo "To fully remove installed tools, run:"
echo ""
echo "  # Remove nak"
echo "  sudo rm /usr/local/bin/nak"
echo ""
echo "  # Remove Python CLI tools (if installed via pipx)"
echo "  pipx uninstall khal khard vdirsyncer"
echo ""
echo "  # Or remove system packages (if installed via apt)"
echo "  sudo apt remove khal khard vdirsyncer"
echo ""
echo "  # Remove sync scripts virtual environment"
echo "  rm -rf /path/to/soapbox-flow/scripts/sync/venv/"
echo ""
echo "  # Remove system packages (Linux)"
echo "  sudo apt remove taskwarrior"
echo ""
echo "  # Remove system packages (macOS)"
echo "  brew uninstall taskwarrior"
echo ""
echo "Your data in ~/.task/, ~/.config/khal/, and your vault remains intact."
echo ""
