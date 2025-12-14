#!/usr/bin/env bash
set -e

echo "Updating package lists..."
sudo apt update

# go to the root directory of the install scripts
ROOT_DIR="$HOME/ubuntu24_install_scripts"
cd "$ROOT_DIR"

echo "Starting all application and ROS2 installers..."

# BambuStudio
echo "Running BambuStudio installer..."
BAMBU_SCRIPT="$ROOT_DIR/Applications/Bambu/build-bambustudio.sh"
if [ -f "$BAMBU_SCRIPT" ]; then
    chmod +x "$BAMBU_SCRIPT"
    "$BAMBU_SCRIPT"
else
    echo "BambuStudio installer not found at $BAMBU_SCRIPT, skipping."
fi

# Fusion 360
echo "Running Fusion 360 installer..."
FUSION_SCRIPT="$ROOT_DIR/Applications/Fusion/install_fusion360.sh"

if [ -f "$FUSION_SCRIPT" ]; then
    chmod +x "$FUSION_SCRIPT"

    # run from $HOME to avoid issues with missing working directory
    ( cd "$HOME" && "$FUSION_SCRIPT" --install --default --full )
else
    echo "Fusion 360 installer not found at $FUSION_SCRIPT, skipping."
fi

# NVIDIA Isaac Sim
echo "Running NVIDIA Isaac Sim installer..."
ISAAC_SCRIPT="$ROOT_DIR/Applications/IsaacSim/install_nvidia_isaac_sim.sh"
if [ -f "$ISAAC_SCRIPT" ]; then
    chmod +x "$ISAAC_SCRIPT"
    "$ISAAC_SCRIPT"
else
    echo "Isaac Sim installer not found at $ISAAC_SCRIPT, skipping."
fi

# ROS2 Jazzy
echo "Running ROS2 Jazzy installer..."
ROS2_INSTALL_SCRIPT="$ROOT_DIR/ROS2/ros2_install_jazzy.sh"
if [ -f "$ROS2_INSTALL_SCRIPT" ]; then
    chmod +x "$ROS2_INSTALL_SCRIPT"
    "$ROS2_INSTALL_SCRIPT"
else
    echo "ROS2 installer not found at $ROS2_INSTALL_SCRIPT, skipping."
fi

# Docker setup for Ubuntu
echo "Running Docker setup script..."
DOCKER_SETUP_SCRIPT="$ROOT_DIR/ROS2/setup_docker_ubuntu.sh"
if [ -f "$DOCKER_SETUP_SCRIPT" ]; then
    chmod +x "$DOCKER_SETUP_SCRIPT"
    "$DOCKER_SETUP_SCRIPT"
else
    echo "Docker setup script not found at $DOCKER_SETUP_SCRIPT, skipping."
fi

# Pull ROS2 Docker images
echo "Pulling ROS2 Docker images..."
PULL_ROS2_SCRIPT="$ROOT_DIR/Docker/pull_ros2_images.sh"
if [ -f "$PULL_ROS2_SCRIPT" ]; then
    chmod +x "$PULL_ROS2_SCRIPT"
    "$PULL_ROS2_SCRIPT"
else
    echo "ROS2 Docker images pull script not found at $PULL_ROS2_SCRIPT, skipping."
fi

# Brave Browser
echo "Running Brave installer..."
BRAVE_SCRIPT="$ROOT_DIR/Applications/Brave/install_brave.sh"
if [ -f "$BRAVE_SCRIPT" ]; then
    chmod +x "$BRAVE_SCRIPT"
    "$BRAVE_SCRIPT"
else
    echo "Brave installer not found at $BRAVE_SCRIPT, skipping."
fi

# Terminator Terminal
echo "Running Terminator installer..."
TERMINATOR_SCRIPT="$ROOT_DIR/Applications/Terminator/install_terminator.sh"
if [ -f "$TERMINATOR_SCRIPT" ]; then
    chmod +x "$TERMINATOR_SCRIPT"
    "$TERMINATOR_SCRIPT"
else
    echo "Terminator installer not found at $TERMINATOR_SCRIPT, skipping."
fi

# Cursor
echo "Running Cursor installer..."
CURSOR_SCRIPT="$ROOT_DIR/Applications/Cursor/install_cursor_windows.sh"
if [ -f "$CURSOR_SCRIPT" ]; then
  chmod +x "$CURSOR_SCRIPT"
  ( cd "$HOME" && "$CURSOR_SCRIPT" )
else
  echo "Cursor installer not found at $CURSOR_SCRIPT, skipping."
fi


echo "All installers finished!"

