#!/usr/bin/env bash
set -e

# Variables
ISAAC_DIR="$HOME/isaac-sim"
ZIP_URL="https://download.isaacsim.omniverse.nvidia.com/isaac-sim-standalone-5.1.0-linux-x86_64.zip"
ZIP_FILE="$HOME/isaac-sim.zip"
UNZIP_SUBDIR="$ISAAC_DIR/isaac-sim-standalone-5.1.0-linux-x86_64"
POST_INSTALL_FLAG="$UNZIP_SUBDIR/.post_install_done"

# Create isaac-sim directory if missing
mkdir -p "$ISAAC_DIR"

# Only unzip if not already unzipped
if [ ! -d "$UNZIP_SUBDIR" ]; then
    # Only download zip if it doesn't exist or is invalid
    if [ ! -f "$ZIP_FILE" ] || ! unzip -tq "$ZIP_FILE" &>/dev/null; then
        echo "Downloading Isaac Sim zip..."
        curl -L "$ZIP_URL" -o "$ZIP_FILE"
    else
        echo "Isaac Sim zip already exists and is valid, skipping download."
    fi

    # Unzip the zip file
    echo "Unzipping Isaac Sim..."
    unzip -q "$ZIP_FILE" -d "$ISAAC_DIR"
else
    echo "Isaac Sim already unzipped, skipping unzip."
fi

cd "$UNZIP_SUBDIR"

# Run post_install.sh if not already run
if [ ! -f "$POST_INSTALL_FLAG" ]; then
    echo "Running post_install.sh..."
    chmod +x post_install.sh
    ./post_install.sh
    touch "$POST_INSTALL_FLAG"
else
    echo "post_install.sh already run, skipping."
fi

# Run selector
if [ -f "./isaac-sim.selector.sh" ]; then
    echo "Running isaac-sim.selector.sh..."
    chmod +x isaac-sim.selector.sh
    ./isaac-sim.selector.sh
else
    echo "isaac-sim.selector.sh not found, skipping."
fi

echo "Isaac Sim setup complete!"

