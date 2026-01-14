#!/bin/bash

# Soapbox Flow Health Check
# Verifies all tools are installed and configured correctly

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Soapbox Flow Health Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

ERRORS=0
WARNINGS=0

check_command() {
    local cmd=$1
    local name=$2
    local version_flag=${3:---version}

    if command -v "$cmd" >/dev/null 2>&1; then
        version=$($cmd $version_flag 2>/dev/null | head -1)
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: not installed"
        ((ERRORS++))
        return 1
    fi
}

check_file() {
    local file=$1
    local name=$2

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $name: $file"
        return 0
    else
        echo -e "${YELLOW}○${NC} $name: not found"
        ((WARNINGS++))
        return 1
    fi
}

check_dir() {
    local dir=$1
    local name=$2

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $name: $dir"
        return 0
    else
        echo -e "${YELLOW}○${NC} $name: not found"
        ((WARNINGS++))
        return 1
    fi
}

check_symlink() {
    local link=$1
    local name=$2

    if [[ -L "$link" ]]; then
        target=$(readlink -f "$link")
        echo -e "${GREEN}✓${NC} $name → $target"
        return 0
    elif [[ -d "$link" ]]; then
        echo -e "${GREEN}✓${NC} $name (directory)"
        return 0
    else
        echo -e "${YELLOW}○${NC} $name: not linked"
        ((WARNINGS++))
        return 1
    fi
}

# Check installed tools
echo -e "${BLUE}Installed Tools${NC}"
echo "─────────────────────────────────────────────"
check_command "nak" "nak"
check_command "task" "taskwarrior" "--version"
check_command "khal" "khal"
check_command "khard" "khard"
check_command "vdirsyncer" "vdirsyncer"
check_command "jq" "jq"
check_command "python3" "python3"
check_command "git" "git"
echo ""

# Check configuration files
echo -e "${BLUE}Configuration Files${NC}"
echo "─────────────────────────────────────────────"
check_file "$HOME/.config/soapbox-flow/config.env" "Soapbox Flow config"
check_file "$HOME/.taskrc" "Taskwarrior config"
check_file "$HOME/.config/khal/config" "khal config"
check_file "$HOME/.config/vdirsyncer/config" "vdirsyncer config"
echo ""

# Check Claude skills
echo -e "${BLUE}Claude Code Skills${NC}"
echo "─────────────────────────────────────────────"
check_symlink "$HOME/.claude/skills/executive-assistant" "executive-assistant"
check_symlink "$HOME/.claude/skills/nostr-devrel" "nostr-devrel"
check_symlink "$HOME/.claude/skills/content-research-writer" "content-research-writer"
check_symlink "$HOME/.claude/skills/planning-with-files" "planning-with-files"
echo ""

# Check data directories
echo -e "${BLUE}Data Directories${NC}"
echo "─────────────────────────────────────────────"
check_dir "$HOME/.task" "Taskwarrior data"
check_dir "$HOME/.local/share/khal" "khal data"
check_dir "$HOME/.local/share/vdirsyncer" "vdirsyncer data"
echo ""

# Test connections (if configured)
echo -e "${BLUE}Connection Tests${NC}"
echo "─────────────────────────────────────────────"

# Test GitLab
if [[ -f "$HOME/.config/soapbox-flow/config.env" ]]; then
    source "$HOME/.config/soapbox-flow/config.env"

    if [[ -n "$GITLAB_TOKEN" ]] && [[ -n "$GITLAB_URL" ]]; then
        if curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/user" 2>/dev/null | grep -q '"id"'; then
            echo -e "${GREEN}✓${NC} GitLab API: connected"
        else
            echo -e "${RED}✗${NC} GitLab API: connection failed"
            ((ERRORS++))
        fi
    else
        echo -e "${YELLOW}○${NC} GitLab: not configured"
    fi

    if [[ -n "$GITHUB_TOKEN" ]]; then
        if curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/user" 2>/dev/null | grep -q '"login"'; then
            echo -e "${GREEN}✓${NC} GitHub API: connected"
        else
            echo -e "${RED}✗${NC} GitHub API: connection failed"
            ((ERRORS++))
        fi
    else
        echo -e "${YELLOW}○${NC} GitHub: not configured"
    fi
else
    echo -e "${YELLOW}○${NC} Soapbox Flow not configured (run ./configure.sh)"
fi

# Test relay connectivity
echo ""
echo -n "Testing Nostr relay connectivity... "
if command -v nak >/dev/null 2>&1; then
    if nak req -k 0 -l 1 wss://relay.damus.io 2>/dev/null | head -1 | grep -q '"pubkey"'; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}○${NC} (slow or offline)"
    fi
else
    echo -e "${YELLOW}○${NC} (nak not installed)"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}All checks passed!${NC}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}$WARNINGS warnings, 0 errors${NC}"
    echo "Run ./configure.sh to set up missing configurations."
else
    echo -e "${RED}$ERRORS errors, $WARNINGS warnings${NC}"
    echo "Run ./install.sh to fix missing tools."
fi

echo ""
exit $ERRORS
