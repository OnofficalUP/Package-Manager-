
#!/usr/bin/env bash

set -u

VERSION="1.0.0"
CONFIG="$HOME/.gkrc"
BIN_DIR="$HOME/.local/bin"

# Load user configuration.
if [ -f "$CONFIG" ]; then
    source "$CONFIG"
fi

# Package manager.
case "${1:-help}" in
    list)
        echo "GK Package Manager v$VERSION"
        echo
        echo "Available packages:"
        echo "  cameditor - Lightweight terminal text editor"
        ;;

    install)
        PACKAGE="${2:-}"

        if [ "$PACKAGE" = "cameditor" ]; then
            echo "Cameditor is installed with Installer.sh."
            echo "Run Installer.sh from the cloned repository:"
            echo "  bash Installer.sh"
        else
            echo "Usage: gk install cameditor"
        fi
        ;;

    help)
        echo "GK Package Manager v$VERSION"
        echo
        echo "Commands:"
        echo "  gk list"
        echo "  gk install cameditor"
        echo "  gk edit <file>"
        echo "  cam <file>"
        echo "  gk help"
        exit 0
        ;;

    edit)
        shift
        ;;

    *)
        echo "Unknown command: $1"
        echo "Run 'gk help' for usage."
        exit 1
        ;;
esac

# If the command was a package-manager command, stop here.
if [ "${1:-}" != "edit" ]; then
    exit 0
fi

# Editor.
shift

FILE="${1:-}"

if [ -z "$FILE" ]; then
    echo "Cameditor - Lightweight Text Editor"
    echo "Usage: cam <file>"
    exit 1
fi

# Read the configuration without executing it as shell code.
if [ -f "$FILE" ]; then
    ORIGINAL="$(cat "$FILE")"
else
    ORIGINAL=""
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

printf '%s\n' "$ORIGINAL" > "$TMP"

clear 2>/dev/null || true

echo "================================"
echo "          CAMEDITOR"
echo "================================"
echo "File: $FILE"
echo "Company: ${Company_Name:-NIL}"
echo "--------------------------------"
echo "Type your text below."
echo "Commands:"
echo "  :w  - Save"
echo "  :q  - Quit"
echo "  :wq - Save and quit"
echo "--------------------------------"

# Use a temporary file so the original is preserved until saving.
while true; do
    echo
    printf "cam> "

    if ! IFS= read -r LINE; then
        break
    fi

    case "$LINE" in
        :w)
            if cat "$TMP" > "$FILE"; then
                echo "Saved: $FILE"
            else
                echo "Error saving file."
            fi
            ;;

        :q)
            echo "Exiting Cameditor."
            break
            ;;

        :wq)
            if cat "$TMP" > "$FILE"; then
                echo "Saved: $FILE"
                break
            else
                echo "Error saving file."
            fi
            ;;

        *)
            printf '%s\n' "$LINE" >> "$TMP"
            ;;
    esac
done
