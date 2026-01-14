#!/bin/bash

# Soapbox Flow Installer
# Installs dependencies and sets up the environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if command_exists brew; then
            PKG_MANAGER="brew"
        else
            print_error "Homebrew not found. Please install from https://brew.sh"
            exit 1
        fi
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="linux"
        if command_exists apt-get; then
            PKG_MANAGER="apt"
        elif command_exists dnf; then
            PKG_MANAGER="dnf"
        elif command_exists pacman; then
            PKG_MANAGER="pacman"
        else
            print_error "Unsupported package manager"
            exit 1
        fi
    else
        print_error "Unsupported operating system"
        exit 1
    fi

    print_substep "Detected: $OS ($PKG_MANAGER)"
}

# Install system package
install_package() {
    local package=$1
    local brew_package=${2:-$1}

    case $PKG_MANAGER in
        apt)
            sudo apt-get install -y "$package"
            ;;
        dnf)
            sudo dnf install -y "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        brew)
            brew install "$brew_package"
            ;;
    esac
}

# Install nak from GitHub releases
install_nak() {
    if command_exists nak; then
        print_substep "nak already installed ($(nak --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    print_substep "Installing nak..."

    # Determine architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *)
            print_error "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac

    # Determine OS for download
    if [[ "$OS" == "macos" ]]; then
        NAK_OS="darwin"
    else
        NAK_OS="linux"
    fi

    # Get latest release
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/fiatjaf/nak/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    if [[ -z "$LATEST_RELEASE" ]]; then
        print_warning "Could not determine latest nak release, using v0.7.6"
        LATEST_RELEASE="v0.7.6"
    fi

    # Download URL
    NAK_URL="https://github.com/fiatjaf/nak/releases/download/${LATEST_RELEASE}/nak-${NAK_OS}-${ARCH}"

    # Download and install
    print_substep "Downloading nak ${LATEST_RELEASE}..."
    if curl -sL "$NAK_URL" -o /tmp/nak; then
        chmod +x /tmp/nak
        sudo mv /tmp/nak /usr/local/bin/nak
        print_success "nak installed to /usr/local/bin/nak"
    else
        print_error "Failed to download nak"
        print_warning "Try installing manually: go install github.com/fiatjaf/nak@latest"
        return 1
    fi
}

# Install Python packages
install_python_packages() {
    print_substep "Installing Python packages..."

    # Check for pip
    if ! command_exists pip3; then
        print_substep "Installing pip..."
        case $PKG_MANAGER in
            apt) sudo apt-get install -y python3-pip ;;
            dnf) sudo dnf install -y python3-pip ;;
            pacman) sudo pacman -S --noconfirm python-pip ;;
            brew) ;; # pip comes with python on macOS
        esac
    fi

    # Install packages
    pip3 install --user khal khard vdirsyncer python-gitlab requests

    print_success "Python packages installed"
}

# Install Obsidian
install_obsidian() {
    if command_exists obsidian; then
        print_substep "Obsidian already installed"
        return 0
    fi

    print_substep "Installing Obsidian..."

    case $PKG_MANAGER in
        apt)
            # Download and install .deb
            OBSIDIAN_VERSION="1.7.7"
            curl -sL "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" -o /tmp/obsidian.deb
            sudo apt-get install -y /tmp/obsidian.deb
            rm /tmp/obsidian.deb
            ;;
        dnf)
            # Use Flatpak on Fedora
            if command_exists flatpak; then
                flatpak install -y flathub md.obsidian.Obsidian
            else
                print_warning "Install Flatpak first or download Obsidian manually from https://obsidian.md"
                return 1
            fi
            ;;
        pacman)
            # Available in AUR
            if command_exists yay; then
                yay -S --noconfirm obsidian
            elif command_exists paru; then
                paru -S --noconfirm obsidian
            else
                print_warning "Install yay or paru, then run: yay -S obsidian"
                return 1
            fi
            ;;
        brew)
            brew install --cask obsidian
            ;;
    esac

    print_success "Obsidian installed"
}

# Install OpenCode Sidebar plugin for Obsidian
install_opencode_sidebar() {
    print_substep "Installing OpenCode Sidebar plugin..."

    # Ask for vault path
    if [[ -z "$VAULT_PATH" ]]; then
        read -p "Enter your Obsidian vault path (e.g., ~/Vault): " VAULT_PATH
        VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
    fi

    if [[ ! -d "$VAULT_PATH" ]]; then
        print_warning "Vault path not found: $VAULT_PATH"
        print_warning "Create your vault first, then run: ./configure.sh to install the plugin"
        return 1
    fi

    PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/opencode-sidebar"
    mkdir -p "$PLUGIN_DIR"

    # Download plugin files
    curl -sL "https://raw.githubusercontent.com/derekross/obsidian-opencode-sidebar/refs/heads/main/main.js" -o "$PLUGIN_DIR/main.js"
    curl -sL "https://raw.githubusercontent.com/derekross/obsidian-opencode-sidebar/refs/heads/main/manifest.json" -o "$PLUGIN_DIR/manifest.json"
    curl -sL "https://raw.githubusercontent.com/derekross/obsidian-opencode-sidebar/refs/heads/main/styles.css" -o "$PLUGIN_DIR/styles.css"

    print_success "OpenCode Sidebar plugin installed to $PLUGIN_DIR"
    print_warning "Enable the plugin in Obsidian Settings > Community Plugins"
}

# Setup Claude skills
setup_skills() {
    print_substep "Setting up Claude Code skills..."

    # Create skills directory if needed
    mkdir -p ~/.claude/skills

    # Symlink each skill
    for skill_dir in "$SCRIPT_DIR"/skills/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")

            # Skip README
            if [[ "$skill_name" == "README.md" ]]; then
                continue
            fi

            target="$HOME/.claude/skills/$skill_name"

            # Remove existing symlink or directory
            if [[ -L "$target" ]]; then
                rm "$target"
            elif [[ -d "$target" ]]; then
                print_warning "Skill '$skill_name' exists, skipping (remove manually to update)"
                continue
            fi

            ln -sf "$skill_dir" "$target"
            print_substep "Linked: $skill_name"
        fi
    done

    print_success "Skills installed to ~/.claude/skills/"
}

# Make scripts executable
setup_scripts() {
    print_substep "Making scripts executable..."

    find "$SCRIPT_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
    find "$SCRIPT_DIR/scripts" -name "*.py" -exec chmod +x {} \;

    print_success "Scripts are executable"
}

# Create config directory
setup_config() {
    print_substep "Creating configuration directories..."

    mkdir -p ~/.config/khal
    mkdir -p ~/.config/khard
    mkdir -p ~/.config/vdirsyncer
    mkdir -p ~/.local/share/khal/calendars
    mkdir -p ~/.local/share/khard/contacts
    mkdir -p ~/.local/share/vdirsyncer

    print_success "Configuration directories created"
}

# Main installation
main() {
    print_header "Soapbox Flow Installer"

    echo ""
    echo "This will install:"
    echo "  • nak (Nostr Army Knife)"
    echo "  • taskwarrior (task management)"
    echo "  • khal, khard, vdirsyncer (calendar/contacts)"
    echo "  • jq (JSON processing)"
    echo "  • Obsidian (notes & knowledge base)"
    echo "  • OpenCode Sidebar plugin for Obsidian"
    echo "  • Claude Code skills"
    echo ""

    read -p "Continue? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    # Detect OS
    print_header "Detecting System"
    detect_os

    # Update package manager
    print_header "Updating Package Manager"
    case $PKG_MANAGER in
        apt)
            print_step "Updating apt..."
            sudo apt-get update
            ;;
        dnf)
            print_step "Updating dnf..."
            sudo dnf check-update || true
            ;;
        pacman)
            print_step "Updating pacman..."
            sudo pacman -Sy
            ;;
        brew)
            print_step "Updating Homebrew..."
            brew update
            ;;
    esac

    # Install system dependencies
    print_header "Installing System Dependencies"

    print_step "Installing Python 3..."
    if command_exists python3; then
        print_substep "Python 3 already installed ($(python3 --version))"
    else
        case $PKG_MANAGER in
            apt) install_package python3 ;;
            dnf) install_package python3 ;;
            pacman) install_package python ;;
            brew) install_package python3 python ;;
        esac
    fi

    print_step "Installing jq..."
    if command_exists jq; then
        print_substep "jq already installed"
    else
        install_package jq
    fi

    print_step "Installing curl..."
    if command_exists curl; then
        print_substep "curl already installed"
    else
        install_package curl
    fi

    print_step "Installing git..."
    if command_exists git; then
        print_substep "git already installed"
    else
        install_package git
    fi

    print_step "Installing taskwarrior..."
    if command_exists task; then
        print_substep "taskwarrior already installed ($(task --version 2>/dev/null | head -1))"
    else
        case $PKG_MANAGER in
            apt) install_package taskwarrior ;;
            dnf) install_package task ;;
            pacman) install_package task ;;
            brew) install_package task taskwarrior ;;
        esac
    fi

    # Install nak
    print_header "Installing Nostr Tools"
    print_step "Installing nak..."
    install_nak

    # Install Python packages
    print_header "Installing Python Packages"
    install_python_packages

    # Install Obsidian
    print_header "Installing Obsidian"
    print_step "Installing Obsidian..."
    install_obsidian

    # Setup configuration directories
    print_header "Setting Up Configuration"
    setup_config

    # Setup skills
    print_header "Installing Claude Skills"
    setup_skills

    # Setup scripts
    print_header "Setting Up Scripts"
    setup_scripts

    # Install OpenCode Sidebar plugin
    print_header "OpenCode Sidebar Plugin"
    echo ""
    read -p "Install OpenCode Sidebar plugin for Obsidian? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        install_opencode_sidebar
    else
        print_substep "Skipped. Run ./configure.sh later to install."
    fi

    # Final summary
    print_header "Installation Complete!"

    echo ""
    echo -e "${GREEN}Soapbox Flow has been installed successfully!${NC}"
    echo ""
    echo "Installed tools:"
    echo -e "  ${GREEN}✓${NC} nak $(nak --version 2>/dev/null || echo '')"
    echo -e "  ${GREEN}✓${NC} taskwarrior $(task --version 2>/dev/null | head -1 || echo '')"
    echo -e "  ${GREEN}✓${NC} khal $(khal --version 2>/dev/null || echo '')"
    echo -e "  ${GREEN}✓${NC} khard $(khard --version 2>/dev/null || echo '')"
    echo -e "  ${GREEN}✓${NC} vdirsyncer $(vdirsyncer --version 2>/dev/null || echo '')"
    echo -e "  ${GREEN}✓${NC} jq $(jq --version 2>/dev/null || echo '')"
    echo ""
    echo "Skills installed to: ~/.claude/skills/"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Run ./configure.sh to set up integrations"
    echo "  2. Review skills in ~/.claude/skills/"
    echo "  3. Try: nak key generate"
    echo ""
    echo "Documentation: $SCRIPT_DIR/docs/"
    echo ""
}

# Run main
main "$@"
