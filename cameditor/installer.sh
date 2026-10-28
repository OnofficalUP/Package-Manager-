#!/usr/bin/env bash
set -eu

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
CONFIG="$HOME/.gkrc"

mkdir -p "$BIN_DIR"

if [ ! -f "$REPO_DIR/main.sh" ]; then
    echo "ERROR: main.sh not found."
    exit 1
fi

# Install the editor and package manager.
cp "$REPO_DIR/main.sh" "$BIN_DIR/gk"
chmod +x "$BIN_DIR/gk"

# Install the cam command.
cat > "$BIN_DIR/cam" <<'LAUNCHER'
#!/usr/bin/env bash
exec "$HOME/.local/bin/gk" edit "$@"
LAUNCHER

chmod +x "$BIN_DIR/cam"

# Create default configuration.
if [ ! -f "$CONFIG" ]; then
    cat > "$CONFIG" <<'CONFIG'
# Chooses Random Theme For Cameditor
Syntax_Colors=("green" "cyan" "yellow")
Syntax=("plain" "shell" "text")

# Chooses Syntax And Syntax Color
Company-Name="NIL"

# Keyboard shortcuts
Save="ctrl-O"
quit="ctrl-X"

# SIMPLIFIED TEXT EDITOR FOR YOU !!
CONFIG
fi

# Add local binaries to PATH when possible.
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC" ] && ! grep -Fq '.local/bin' "$RC"; then
        printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$RC"
    fi
done

echo
echo "================================"
echo "       GK INSTALLER"
echo "================================"
echo "Cameditor installed successfully!"
echo "Package manager: gk"
echo "Text editor:     cam <file>"
echo "Configuration:   ~/.gkrc"
echo
echo "If commands are not found, run:"
echo 'export PATH="$HOME/.local/bin:$PATH"'
