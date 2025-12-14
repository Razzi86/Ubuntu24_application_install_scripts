#!/usr/bin/env bash
set -e

# Path to Fusion 360 executable inside Wine
EXEC_PATH="$HOME/.wine/drive_c/Program Files/Autodesk/Autodesk Fusion 360/AutodeskFusion360.exe"

# Only run installer if executable doesn't exist
if [ ! -f "$EXEC_PATH" ]; then
    echo "Fusion 360 not found. Running installer..."
    curl -L https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/autodesk_fusion_installer_x86-64.sh -o "autodesk_fusion_installer_x86-64.sh" && chmod +x autodesk_fusion_installer_x86-64.sh && ./autodesk_fusion_installer_x86-64.sh --install --default --full
else
    echo "Fusion 360 already installed at $EXEC_PATH, skipping installer."
fi

# Optionally create desktop launcher if it doesn't exist
DESKTOP_FILE="$HOME/.local/share/applications/fusion360.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Creating Fusion 360 desktop launcher..."
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Autodesk Fusion 360
Comment=Autodesk Fusion 360 CAD software
Exec=wine "$EXEC_PATH"
Icon=$HOME/.wine/drive_c/Program Files/Autodesk/Autodesk Fusion 360/fusion360.png
Terminal=false
Type=Application
Categories=Graphics;Engineering;
EOF
    chmod +x "$DESKTOP_FILE"
    echo "Desktop launcher created at $DESKTOP_FILE"
else
    echo "Desktop launcher already exists at $DESKTOP_FILE"
fi

