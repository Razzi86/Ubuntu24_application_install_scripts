#!/usr/bin/env bash
set -e

# Detect system architecture
ARCH=$(uname -m)

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -cs)

# Auto-detect system type based on architecture
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    DETECTED_SYSTEM_TYPE="Jetson"
    DETECTED_IS_JETSON=true
elif [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    DETECTED_SYSTEM_TYPE="PC"
    DETECTED_IS_JETSON=false
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Verify detection with user
echo "System Detection:"
echo "  Architecture: $ARCH"
echo "  Detected system type: $DETECTED_SYSTEM_TYPE"
echo "  Ubuntu version: $UBUNTU_VERSION ($UBUNTU_CODENAME)"
echo ""
read -p "Is this correct? (y/n): " CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ] || [ "$CONFIRM" = "yes" ] || [ "$CONFIRM" = "Yes" ]; then
    SYSTEM_TYPE="$DETECTED_SYSTEM_TYPE"
    IS_JETSON="$DETECTED_IS_JETSON"
else
    # Ask for corrections - separate questions for each setting
    echo ""
    echo "Please provide the correct settings:"
    echo ""
    
    # Ask for Architecture
    echo "Architecture:"
    echo "1) x86_64 (amd64)"
    echo "2) aarch64 (arm64)"
    read -p "Enter choice (1 or 2): " ARCH_CHOICE
    
    if [ "$ARCH_CHOICE" = "1" ]; then
        ARCH="x86_64"
    elif [ "$ARCH_CHOICE" = "2" ]; then
        ARCH="aarch64"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
    
    # Ask for System Type
    echo ""
    echo "System Type:"
    echo "1) PC"
    echo "2) Jetson"
    read -p "Enter choice (1 or 2): " SYSTEM_CHOICE
    
    if [ "$SYSTEM_CHOICE" = "1" ]; then
        SYSTEM_TYPE="PC"
        IS_JETSON=false
    elif [ "$SYSTEM_CHOICE" = "2" ]; then
        SYSTEM_TYPE="Jetson"
        IS_JETSON=true
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
    
    # Ask for Operating System
    echo ""
    echo "Operating System:"
    echo "1) Ubuntu 24.04 (Noble)"
    echo "2) Ubuntu 22.04 (Jammy)"
    read -p "Enter choice (1 or 2): " OS_CHOICE
    
    if [ "$OS_CHOICE" = "1" ]; then
        UBUNTU_VERSION="24.04"
        UBUNTU_CODENAME="noble"
    elif [ "$OS_CHOICE" = "2" ]; then
        UBUNTU_VERSION="22.04"
        UBUNTU_CODENAME="jammy"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
    
    echo ""
    echo "Selected settings:"
    echo "  Architecture: $ARCH"
    echo "  System type: $SYSTEM_TYPE"
    echo "  Operating system: Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME)"
    echo ""
fi

echo "Updating package lists..."
sudo apt update

# go to the root directory of the install scripts
ROOT_DIR="$HOME/Ubuntu24_application_install_scripts"
cd "$ROOT_DIR"

echo "Starting all application and ROS2 installers..."

# BambuStudio (x86-64 only, skip on Jetson)
if [ "$IS_JETSON" = false ]; then
    echo "Running BambuStudio installer..."
    BAMBU_SCRIPT="$ROOT_DIR/Applications/Bambu/build-bambustudio.sh"
    if [ -f "$BAMBU_SCRIPT" ]; then
        chmod +x "$BAMBU_SCRIPT"
        "$BAMBU_SCRIPT"
    else
        echo "BambuStudio installer not found at $BAMBU_SCRIPT, skipping."
    fi
else
    echo "BambuStudio is x86-64 only, skipping on Jetson."
fi

# Fusion 360 (x86-64 only, skip on Jetson)
if [ "$IS_JETSON" = false ]; then
    echo "Running Fusion 360 installer..."
    FUSION_SCRIPT="$ROOT_DIR/Applications/Fusion/install_fusion360.sh"

    if [ -f "$FUSION_SCRIPT" ]; then
        chmod +x "$FUSION_SCRIPT"

        # run from $HOME to avoid issues with missing working directory
        ( cd "$HOME" && "$FUSION_SCRIPT" --install --default --full )
    else
        echo "Fusion 360 installer not found at $FUSION_SCRIPT, skipping."
    fi
else
    echo "Fusion 360 is x86-64 only, skipping on Jetson."
fi

# NVIDIA Isaac Sim (x86_64 only, skip on Jetson)
if [ "$IS_JETSON" = false ]; then
    echo "Running NVIDIA Isaac Sim installer..."
    ISAAC_SCRIPT="$ROOT_DIR/Applications/IsaacSim/install_nvidia_isaac_sim.sh"
    if [ -f "$ISAAC_SCRIPT" ]; then
        chmod +x "$ISAAC_SCRIPT"
        "$ISAAC_SCRIPT"
    else
        echo "Isaac Sim installer not found at $ISAAC_SCRIPT, skipping."
    fi
else
    echo "NVIDIA Isaac Sim is x86_64 only, skipping on Jetson."
fi

# ROS2 (Jazzy for Ubuntu 24.04, Humble for Ubuntu 22.04)
if [ "$UBUNTU_CODENAME" = "noble" ] || [ "$UBUNTU_VERSION" = "24.04" ]; then
    echo "Running ROS2 Jazzy installer for Ubuntu 24.04..."
    ROS2_INSTALL_SCRIPT="$ROOT_DIR/ROS2/ros2_install_jazzy.sh"
    ROS2_DISTRO="jazzy"
    if [ -f "$ROS2_INSTALL_SCRIPT" ]; then
        chmod +x "$ROS2_INSTALL_SCRIPT"
        "$ROS2_INSTALL_SCRIPT"
    else
        echo "ROS2 Jazzy installer not found at $ROS2_INSTALL_SCRIPT, skipping."
    fi
elif [ "$UBUNTU_CODENAME" = "jammy" ] || [ "$UBUNTU_VERSION" = "22.04" ]; then
    echo "Running ROS2 Humble installer for Ubuntu 22.04..."
    ROS2_INSTALL_SCRIPT="$ROOT_DIR/ROS2/ros2_install_humble.sh"
    ROS2_DISTRO="humble"
    if [ -f "$ROS2_INSTALL_SCRIPT" ]; then
        chmod +x "$ROS2_INSTALL_SCRIPT"
        "$ROS2_INSTALL_SCRIPT"
    else
        echo "ROS2 Humble installer not found at $ROS2_INSTALL_SCRIPT, skipping."
    fi
else
    echo "Unsupported Ubuntu version: $UBUNTU_VERSION ($UBUNTU_CODENAME)"
    echo "Skipping ROS2 installation."
    ROS2_DISTRO=""
fi

# Docker setup for Ubuntu
echo "Running Docker setup script..."
DOCKER_SETUP_SCRIPT="$ROOT_DIR/Docker/setup_docker_ubuntu.sh"
if [ -f "$DOCKER_SETUP_SCRIPT" ]; then
    chmod +x "$DOCKER_SETUP_SCRIPT"
    "$DOCKER_SETUP_SCRIPT"
else
    echo "Docker setup script not found at $DOCKER_SETUP_SCRIPT, skipping."
fi

# Pull ROS2 Docker images (based on Ubuntu version)
if [ -n "$ROS2_DISTRO" ]; then
    echo "Pulling ROS2 Docker images for $ROS2_DISTRO..."
    PULL_ROS2_SCRIPT="$ROOT_DIR/Docker/pull_ros2_images.sh"
    if [ -f "$PULL_ROS2_SCRIPT" ]; then
        chmod +x "$PULL_ROS2_SCRIPT"
        ROS2_DISTRO="$ROS2_DISTRO" "$PULL_ROS2_SCRIPT"
    else
        echo "ROS2 Docker images pull script not found at $PULL_ROS2_SCRIPT, skipping."
    fi
else
    echo "Skipping ROS2 Docker images pull (no ROS2 distro selected)."
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

# Cursor (supports both x86_64 and ARM64)
echo "Running Cursor installer..."
CURSOR_SCRIPT="$ROOT_DIR/Applications/Cursor/install_cursor.sh"
if [ -f "$CURSOR_SCRIPT" ]; then
    chmod +x "$CURSOR_SCRIPT"
    ( cd "$HOME" && "$CURSOR_SCRIPT" )
else
    echo "Cursor installer not found at $CURSOR_SCRIPT, skipping."
fi


echo "All installers finished!"

