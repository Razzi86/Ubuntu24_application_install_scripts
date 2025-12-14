#!/usr/bin/env bash
set -e

CURSOR_VERSION="2.2"
URL="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/${CURSOR_VERSION}"
TMP_DEB="/tmp/cursor_${CURSOR_VERSION}_amd64.deb"

echo "Installing Cursor ${CURSOR_VERSION}..."

# Check if Cursor is already installed
if command -v cursor >/dev/null 2>&1; then
    INSTALLED_VERSION=$(cursor --version 2>/dev/null || true)
    echo "Cursor already installed: ${INSTALLED_VERSION}"
    echo "Skipping install."
    exit 0
fi

# download the deb file
echo "Downloading Cursor .deb..."
curl -L "${URL}" -o "${TMP_DEB}"

# install it
echo "Installing Cursor..."
sudo apt install -y "${TMP_DEB}"

# clean up the temp file
rm -f "${TMP_DEB}"

echo "Cursor ${CURSOR_VERSION} installation complete!"

