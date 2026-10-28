#!/usr/bin/env bash

set -u

GK_VERSION="2.0.0"
GK_REPO="OnofficalUP/Package-Manager-"
GK_BRANCH="main"
GK_RAW="https://raw.githubusercontent.com/${GK_REPO}/${GK_BRANCH}"

GK_HOME="${GK_HOME:-$HOME/.gk}"
GK_BIN="${GK_BIN:-$HOME/.local/bin}"
GK_CONFIG="${GK_CONFIG:-$HOME/.gkrc}"
GK_PACKAGES="$GK_HOME/packages"
GK_DB="$GK_HOME/installed"

mkdir -p "$GK_HOME" "$GK_PACKAGES" "$GK_BIN"

# --------------------------------------------------
# OUTPUT
# --------------------------------------------------

info() {
    printf '[GK] %s\n' "$*"
}

success() {
    printf '[OK] %s\n' "$*"
}

error() {
    printf '[ERROR] %s\n' "$*" >&2
}

# --------------------------------------------------
# DOWNLOAD
# --------------------------------------------------

download() {
    url="$1"
    output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fLsS --connect-timeout 15 "$url" -o "$output"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$output"
    else
        error "Install curl or wget first."
        return 1
    fi
}

# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

create_config() {
    if [ ! -f "$GK_CONFIG" ]; then
        cat > "$GK_CONFIG" <<'CONFIG'
# GK Configuration

Syntax_Colors=("green" "cyan" "yellow")
Syntax=("plain" "shell" "text")
random_THEME=("virgin" "pulsar")

Company_Name="NIL"

Save="ctrl-O"
quit="ctrl-X"

# SIMPLIFIED TEXT EDITOR FOR YOU !!
CONFIG
        success "Created ~/.gkrc"
    fi
}

# Never source ~/.gkrc: it may contain invalid Bash syntax.
# Parse only the known settings safely.
config_value() {
    key="$1"
    default="$2"

    [ -f "$GK_CONFIG" ] || {
        printf '%s' "$default"
        return
    }

    value="$(sed -n \
        "s/^[[:space:]]*${key}=[\"']\\{0,1\\}\\([^\"']*\\)[\"']\\{0,1\\}[[:space:]]*$/\\1/p" \
        "$GK_CONFIG" | head -n 1)"

    printf '%s' "${value:-$default}"
}

# --------------------------------------------------
# PACKAGE DATABASE
# --------------------------------------------------

is_installed() {
    grep -Fxq "$1" "$GK_DB" 2>/dev/null
}

mark_installed() {
    touch "$GK_DB"

    if ! is_installed "$1"; then
        printf '%s\n' "$1" >> "$GK_DB"
    fi
}

unmark_installed() {
    package="$1"
    tmp="$(mktemp)"

    if [ -f "$GK_DB" ]; then
        grep -Fxv "$package" "$GK_DB" > "$tmp" || true
        cat "$tmp" > "$GK_DB"
    fi

    rm -f "$tmp"
}

# --------------------------------------------------
# PACKAGE INFORMATION
# --------------------------------------------------

package_info() {
    case "${1:-}" in
        cameditor)
            printf '%s\n' \
                "Name: Cameditor" \
                "Version: 1.0.0" \
                "Description: Lightweight terminal text editor" \
                "Source: GitHub" \
                "Repository: $GK_REPO"
            ;;
        *)
            error "Unknown package: ${1:-}"
            return 1
            ;;
    esac
}

# --------------------------------------------------
# INSTALL
# --------------------------------------------------

install_package() {
    package="${1:-}"

    if [ -z "$package" ]; then
        error "Usage: gk install <package>"
        return 1
    fi

    case "$package" in
        cameditor)
            installer_url="$GK_RAW/cameditor/Installer.sh"
            ;;
        *)
            error "Package not found: $package"
            info "Available package: cameditor"
            return 1
            ;;
    esac

    tmp="$(mktemp)"

    info "Downloading $package installer..."

    if ! download "$installer_url" "$tmp"; then
        rm -f "$tmp"
        error "Download failed."
        error "Check your internet connection and GitHub repository."
        return 1
    fi

    info "Installing $package..."

    if ! bash "$tmp"; then
        rm -f "$tmp"
        error "Package installer failed."
        return 1
    fi

    rm -f "$tmp"

    mark_installed "$package"
    success "$package installed."
}

# --------------------------------------------------
# REMOVE
# --------------------------------------------------

remove_package() {
    package="${1:-}"

    case "$package" in
        cameditor)
            rm -f "$GK_BIN/cam"
            rm -rf "$GK_PACKAGES/cameditor"
            unmark_installed cameditor
            success "Cameditor removed."
            info "Your documents have not been deleted."
            ;;
        *)
            error "Unknown package: $package"
            return 1
            ;;
    esac
}

# --------------------------------------------------
# LIST
# --------------------------------------------------

list_packages() {
    printf '\nGK Package Manager %s\n\n' "$GK_VERSION"
    printf '%-15s %-12s %s\n' "PACKAGE" "STATUS" "DESCRIPTION"
    printf '%-15s %-12s %s\n' "---------------" "------------" "------------------------------"

    if is_installed cameditor; then
        status="installed"
    else
        status="available"
    fi

    printf '%-15s %-12s %s\n' \
        "cameditor" "$status" "Lightweight terminal editor"

    printf '\n'
}

# --------------------------------------------------
# DOCTOR
# --------------------------------------------------

doctor() {
    printf '\nGK Diagnostics\n'
    printf '%s\n' '----------------------------'

    printf 'Version: %s\n' "$GK_VERSION"
    printf 'Home: %s\n' "$GK_HOME"
    printf 'Config: %s\n' "$GK_CONFIG"

    if command -v bash >/dev/null 2>&1; then
        success "Bash available"
    else
        error "Bash missing"
    fi

    if command -v curl >/dev/null 2>&1 ||
       command -v wget >/dev/null 2>&1; then
        success "Downloader available"
    else
        error "Install curl or wget"
    fi

    if [ -f "$GK_CONFIG" ]; then
        success "Configuration exists"
    else
        info "Configuration will be created"
    fi

    if command -v cam >/dev/null 2>&1; then
        success "Cameditor command found"
    else
        info "Cameditor is not on PATH"
    fi

    printf '\n'
}

# --------------------------------------------------
# HELP
# --------------------------------------------------

help() {
    cat <<EOF
GK Package Manager v$GK_VERSION

USAGE:
  gk <command> [arguments]

PACKAGE COMMANDS:
  gk list                   List available packages
  gk install cameditor      Install Cameditor
  gk update cameditor       Reinstall/update Cameditor
  gk remove cameditor       Remove Cameditor
  gk info cameditor         Package information
  gk doctor                 Check your setup

EDITOR:
  gk hello.txt              Open a file
  gk edit hello.txt         Open a file
  cam hello.txt             Open a file

OTHER:
  gk config                 Show configuration path
  gk version                Show version
  gk help                   Show this help

Repository:
  https://github.com/$GK_REPO
EOF
}

# --------------------------------------------------
# COMMAND ROUTER
# --------------------------------------------------

create_config

COMMAND="${1:-help}"

case "$COMMAND" in
    help|-h|--help)
        help
        ;;

    version|--version|-v)
        printf 'GK Package Manager %s\n' "$GK_VERSION"
        ;;

    list|ls)
        list_packages
        ;;

    install|add)
        install_package "${2:-}"
        ;;

    update|upgrade)
        install_package "${2:-}"
        ;;

    remove|uninstall|delete)
        remove_package "${2:-}"
        ;;

    info|show)
        package_info "${2:-}"
        ;;

    doctor|check)
        doctor
        ;;

    config)
        printf '%s\n' "$GK_CONFIG"
        ;;

    edit)
        shift

        if [ "$#" -eq 0 ]; then
            error "Usage: gk edit <file>"
            exit 1
        fi

        if ! command -v cam >/dev/null 2>&1; then
            error "Cameditor is not installed."
            info "Run: gk install cameditor"
            exit 1
        fi

        exec cam "$@"
        ;;

    *)
        # Treat an unknown command as a filename.
        # Example: gk hello.txt
        if [ -f "$GK_BIN/cam" ] || command -v cam >/dev/null 2>&1; then
            exec cam "$@"
        else
            error "Unknown command: $COMMAND"
            info "Run: gk help"
            info "To edit a file, install Cameditor first."
            exit 1
        fi
        ;;
esac
