#!/usr/bin/env bash
set -e

cd ~
mkdir -p BambuStudio
cd BambuStudio

# clone the repo if we don't have it
if [ ! -d ".git" ]; then
    echo "Cloning BambuStudio repository..."
    git clone https://github.com/bambulab/BambuStudio.git .
else
    echo "BambuStudio repository already exists, skipping clone."
fi

chmod +x BuildLinux.sh

# install dependencies (only do this once)
if [ ! -f ".deps_installed" ]; then
    echo "Installing dependency packages..."
    ./BuildLinux.sh -u
    touch .deps_installed
else
    echo "Dependencies already installed, skipping."
fi

# Build BambuStudio and AppImage (skip if AppImage already exists)
APPIMAGE="$HOME/BambuStudio/build/BambuStudio_ubu64.AppImage"
if [ ! -f "$APPIMAGE" ]; then
    echo "Building BambuStudio and generating AppImage..."
    ./BuildLinux.sh -dsi
else
    echo "AppImage already exists at $APPIMAGE, skipping build."
fi

# Add alias to .bashrc
BASHRC="$HOME/.bashrc"
ALIAS_LINE="alias bambu=\"$APPIMAGE\""

if ! grep -Fxq "$ALIAS_LINE" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# Alias to run BambuStudio from anywhere" >> "$BASHRC"
    echo "$ALIAS_LINE" >> "$BASHRC"
    echo "Added 'bambu' alias to $BASHRC"
else
    echo "Alias 'bambu' already exists in $BASHRC"
fi

# add desktop entry so it shows up in the app launcher
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
DESKTOP_FILE="$DESKTOP_DIR/BambuStudio.desktop"

ICON_PATH="$HOME/BambuStudio/build/resources/icon.png"  # adjust if icon exists elsewhere

if [ ! -f "$DESKTOP_FILE" ]; then
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=BambuStudio
Comment=BambuLab 3D printing software
Exec=$APPIMAGE
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Graphics;3DPrinting;
EOF

    chmod +x "$DESKTOP_FILE"
    echo "Created desktop application at $DESKTOP_FILE"
else
    echo "Desktop application already exists at $DESKTOP_FILE"
fi

echo "Done! Reload your shell:"
echo "  source ~/.bashrc"
echo "Run BambuStudio from anywhere using:"
echo "  bambu"
echo "You should also now see BambuStudio in your application launcher/menu."

