#!/usr/bin/env bash

set -eu

REPO="https://raw.githubusercontent.com/OnofficalUP/Package-Manager-/main"
BIN="$HOME/.local/bin"
PKG="$HOME/.gk/packages/cameditor"
CONFIG="$HOME/.gkrc"

echo "=================================="
echo "       CAMEDITOR INSTALLER"
echo "=================================="

mkdir -p "$BIN" "$PKG"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "[1/4] Downloading Cameditor..."

if command -v curl >/dev/null 2>&1; then
    curl -fLsS "$REPO/cameditor/main.sh" -o "$TMP"
elif command -v wget >/dev/null 2>&1; then
    wget -q "$REPO/cameditor/main.sh" -O "$TMP"
else
    echo "ERROR: Install curl or wget first."
    exit 1
fi

if [ ! -s "$TMP" ]; then
    echo "ERROR: Downloaded editor is empty."
    exit 1
fi

if ! bash -n "$TMP"; then
    echo "ERROR: The downloaded main.sh has a syntax error."
    exit 1
fi

echo "[2/4] Installing editor..."

install -m 755 "$TMP" "$PKG/main.sh"
install -m 755 "$TMP" "$BIN/cam"

echo "[3/4] Creating configuration..."

if [ ! -f "$CONFIG" ]; then
    cat > "$CONFIG" <<'CONFIG'
# GK Cameditor Configuration

Syntax_Colors=("green" "cyan" "yellow")
Syntax=("plain" "shell" "text")
random_THEME=("virgin" "pulsar")

Company_Name="NIL"

Save="ctrl-O"
quit="ctrl-X"

# SIMPLIFIED TEXT EDITOR FOR YOU !!
CONFIG
fi

echo "[4/4] Checking installation..."

if [ -x "$BIN/cam" ]; then
    echo
    echo "Cameditor installed successfully!"
    echo
    echo "Run:"
    echo "  cam hello.txt"
    echo
    echo "Package location: $PKG"
    echo "Configuration:    $CONFIG"
else
    echo "ERROR: Installation failed."
    exit 1
fi

case ":${PATH:-}:" in
    *":$BIN:"*) ;;
    *) echo "Note: add $BIN to your PATH." ;;
esac
