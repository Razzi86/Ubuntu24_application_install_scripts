#!/usr/bin/env bash
set -e

echo "Pulling ROS2 Docker images..."

# ROS2 Jazzy images
echo "Pulling ROS2 Jazzy desktop..."
docker pull osrf/ros:jazzy-desktop-full

# ROS2 Humble images
echo "Pulling ROS2 Humble desktop..."
docker pull osrf/ros:humble-desktop-full

echo "All requested ROS2 Docker images pulled successfully!"

