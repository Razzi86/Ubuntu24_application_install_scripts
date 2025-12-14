#!/usr/bin/env bash
set -e

wineserver -k || true
pkill -9 wine 2>/dev/null || true
pkill -9 wineserver 2>/dev/null || true

PREFIX="$HOME/.autodesk_fusion/wineprefixes/default"

# check if fusion is already installed, if so skip
if [[ -d "$PREFIX/drive_c" ]] && \
   find "$PREFIX/drive_c" -type f \
     \( -iname "FusionLauncher.exe" -o -iname "Fusion360.exe" -o -iname "Fusion.exe" \) \
     -print -quit 2>/dev/null | grep -q .; then
  echo "Fusion 360 already installed in $PREFIX — skipping install."
  exit 0
fi

# install it
curl -L https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/autodesk_fusion_installer_x86-64.sh -o "autodesk_fusion_installer_x86-64.sh" && chmod +x autodesk_fusion_installer_x86-64.sh && ./autodesk_fusion_installer_x86-64.sh --install --default --full

