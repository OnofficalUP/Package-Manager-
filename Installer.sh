#!/usr/bin/env bash

set -eu

REPO="https://raw.githubusercontent.com/OnofficalUP/Package-Manager-/main"
BIN="$HOME/.local/bin"
GK_HOME="$HOME/.gk"
CONFIG="$HOME/.gkrc"

mkdir -p "$BIN" "$GK_HOME"

echo "================================"
echo "      GK INSTALLER v2.0"
echo "================================"
echo

if ! command -v curl >/dev/null 2>&1 &&
   ! command -v wget >/dev/null 2>&1; then
    echo "Install curl or wget first."
    exit 1
fi

# Back up an existing broken configuration.
if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$CONFIG.backup"
    echo "Configuration backup: $CONFIG.backup"
fi

# Download the main package manager.
if command -v curl >/dev/null 2>&1; then
    curl -fLsS "$REPO/main.sh" -o "$BIN/gk"
else
    wget -q "$REPO/main.sh" -O "$BIN/gk"
fi

chmod +x "$BIN/gk"

# Make the command available in the current terminal.
export PATH="$BIN:$PATH"

# Persist PATH for common shells.
for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] &&
       ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$rc"; then
        printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
    fi
done

# Replace the broken configuration with a valid one.
cat > "$CONFIG" <<'CONFIG'
# GK Configuration

Syntax_Colors=("green" "cyan" "yellow")
Syntax=("plain" "shell" "text")
random_THEME=("virgin" "pulsar")

Company_Name="NIL"

Save="ctrl-O"
quit="ctrl-X"

# SIMPLIFIED TEXT EDITOR FOR YOU !!
CONFIG

echo
echo "GK installed successfully."
echo
echo "Try these commands:"
echo "  gk help"
echo "  gk list"
echo "  gk doctor"
echo "  gk install cameditor"
echo
echo "Restart your terminal if necessary."
