#!/usr/bin/env bash

set -eu

GK_REPO="https://github.com/OnofficalUP/Package-Manager-"
GK_RAW="https://raw.githubusercontent.com/OnofficalUP/Package-Manager-/main"
GK_HOME="${GK_HOME:-$HOME/.gk}"
GK_BIN="${GK_BIN:-$HOME/.local/bin}"

mkdir -p "$GK_HOME/packages" "$GK_BIN"

usage() {
    cat <<'EOF'
GK Package Manager

Usage:
  gk list
  gk install <package>
  gk update <package>
  gk remove <package>
  gk help

Packages:
  cameditor    Lightweight terminal text editor
EOF
}

install_package() {
    package="${1:-}"

    if [ -z "$package" ]; then
        echo "Usage: gk install <package>"
        exit 1
    fi

    case "$package" in
        cameditor)
            url="$GK_RAW/cameditor/Installer.sh"
            ;;
        *)
            echo "Package not found: $package"
            exit 1
            ;;
    esac

    if command -v curl >/dev/null 2>&1; then
        downloader="curl"
    elif command -v wget >/dev/null 2>&1; then
        downloader="wget"
    else
        echo "Install curl or wget first."
        exit 1
    fi

    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT

    echo "Downloading $package installer..."

    if [ "$downloader" = "curl" ]; then
        curl -fLsS "$url" -o "$tmp"
    else
        wget -q "$url" -O "$tmp"
    fi

    echo "Running $package installer..."
    bash "$tmp"
}

case "${1:-help}" in
    list)
        echo "GK Package Manager"
        echo
        echo "Available packages:"
        echo "  cameditor - Lightweight terminal text editor"
        ;;

    install)
        shift
        install_package "${1:-}"
        ;;

    update)
        shift
        install_package "${1:-}"
        ;;

    remove)
        package="${2:-}"

        case "$package" in
            cameditor)
                rm -f "$GK_BIN/cam"
                rm -rf "$GK_HOME/packages/cameditor"
                echo "Cameditor removed."
                ;;
            *)
                echo "Unknown package: $package"
                exit 1
                ;;
        esac
        ;;

    help|-h|--help)
        usage
        ;;

    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
