#!/usr/bin/env bash

set -eu

REPO="https://raw.githubusercontent.com/OnofficalUP/Package-Manager-/main"
BIN="$HOME/.local/bin"
GK_HOME="$HOME/.gk"

mkdir -p "$BIN" "$GK_HOME"

if command -v curl >/dev/null 2>&1; then
    curl -fLsS "$REPO/main.sh" -o "$BIN/gk"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$REPO/main.sh" -O "$BIN/gk"
else
    echo "Please install curl or wget."
    exit 1
fi

chmod +x "$BIN/gk"

for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -Fq '.local/bin' "$rc"; then
        printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
    fi
done

echo "GK Package Manager installed!"
echo
echo "Run:"
echo "  $BIN/gk list"
echo
echo "If gk is not found, run:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
