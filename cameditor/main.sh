#!/usr/bin/env bash

set -u

VERSION="1.0.0"
CONFIG="$HOME/.gkrc"

# ----------------------------------------
# CONFIGURATION
# ----------------------------------------

COMPANY="NIL"

# Parse only the company setting.
# Do not source ~/.gkrc as executable code.
if [ -f "$CONFIG" ]; then
    value="$(
        sed -n \
            's/^[[:space:]]*Company_Name="[[:space:]]*\(.*\)"[[:space:]]*$/\1/p' \
            "$CONFIG" | head -n 1
    )"

    [ -n "$value" ] && COMPANY="$value"
fi

# ----------------------------------------
# ARGUMENTS
# ----------------------------------------

FILE="${1:-}"

if [ -z "$FILE" ]; then
    echo "Cameditor v$VERSION"
    echo "Lightweight terminal text editor"
    echo
    echo "Usage: cam <file>"
    exit 1
fi

# ----------------------------------------
# VALIDATION
# ----------------------------------------

if [ -d "$FILE" ]; then
    echo "ERROR: '$FILE' is a directory."
    exit 1
fi

PARENT="$(dirname "$FILE")"

if [ ! -d "$PARENT" ]; then
    echo "ERROR: Directory does not exist: $PARENT"
    exit 1
fi

# ----------------------------------------
# TEMPORARY WORKSPACE
# ----------------------------------------

TMP="$(mktemp)" || exit 1
trap 'rm -f "$TMP"' EXIT

if [ -f "$FILE" ]; then
    if ! cat "$FILE" > "$TMP"; then
        echo "ERROR: Cannot read $FILE"
        exit 1
    fi
fi

# ----------------------------------------
# HEADER
# ----------------------------------------

clear 2>/dev/null || true

printf '\n'
printf '  =====================================\n'
printf '             CAMEDITOR %s\n' "$VERSION"
printf '  =====================================\n'
printf '  File:    %s\n' "$FILE"
printf '  Company: %s\n' "$COMPANY"
printf '  -------------------------------------\n'
printf '  Commands:\n'
printf '    :p     Show current document\n'
printf '    :a     Append text\n'
printf '    :c     Clear document\n'
printf '    :w     Save\n'
printf '    :wq    Save and quit\n'
printf '    :q     Quit without saving\n'
printf '    :help  Show help\n'
printf '  =====================================\n'

# ----------------------------------------
# DISPLAY DOCUMENT
# ----------------------------------------

show_document() {
    printf '\n'
    printf '%s\n' '  ------------ DOCUMENT ---------------'

    if [ -s "$TMP" ]; then
        awk '{ printf "  %4d | %s\n", NR, $0 }' "$TMP"
    else
        printf '  (empty document)\n'
    fi

    printf '%s\n' '  -------------------------------------'
}

show_document

# ----------------------------------------
# EDITOR LOOP
# ----------------------------------------

while true; do
    printf '\ncam:%s> ' "$FILE"

    if ! IFS= read -r LINE; then
        printf '\nLeaving editor without saving.\n'
        break
    fi

    case "$LINE" in
        :help)
            printf '\nCommands:\n'
            printf '  :p     Display the document\n'
            printf '  :a     Append multiple lines\n'
            printf '  :c     Clear all text\n'
            printf '  :w     Save changes\n'
            printf '  :wq    Save and quit\n'
            printf '  :q     Quit without saving\n'
            ;;

        :p)
            show_document
            ;;

        :a)
            printf 'Enter text. Type a single . on a line to finish.\n'

            while true; do
                printf '  | '

                if ! IFS= read -r TEXT; then
                    break
                fi

                [ "$TEXT" = "." ] && break

                printf '%s\n' "$TEXT" >> "$TMP"
            done
            ;;

        :c)
            printf 'Clear the entire document? Type YES to confirm: '
            IFS= read -r CONFIRM || break

            if [ "$CONFIRM" = "YES" ]; then
                : > "$TMP"
                printf 'Document cleared. Save with :w.\n'
            else
                printf 'Cancelled.\n'
            fi
            ;;

        :w)
            if cat "$TMP" > "$FILE"; then
                printf 'Saved: %s\n' "$FILE"
            else
                printf 'ERROR: Could not save file.\n'
            fi
            ;;

        :wq)
            if cat "$TMP" > "$FILE"; then
                printf 'Saved: %s\n' "$FILE"
                break
            else
                printf 'ERROR: Could not save file.\n'
            fi
            ;;

        :q)
            printf 'Unsaved changes will be discarded. Type YES to confirm: '
            IFS= read -r CONFIRM || break

            if [ "$CONFIRM" = "YES" ]; then
                printf 'Leaving Cameditor.\n'
                break
            fi
            ;;

        *)
            printf 'Unknown command. Type :help for commands.\n'
            ;;
    esac
done
