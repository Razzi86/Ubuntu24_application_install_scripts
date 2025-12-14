#!/bin/sh


DOCKER_IMAGE="$1"  # docker image name
ROS2_WS_NAME="$2"    # ros2 workspace name
CONTAINER_NAME="$3"  # container name

HOST_WS_PATH="/home/$USER/$ROS2_WS_NAME/src"  # path to workspace on host

# get the docker user from the image
DOCKER_USER=$(docker inspect "$DOCKER_IMAGE" --format '{{.Config.User}}')
if [ -z "$DOCKER_USER" ]; then
    DOCKER_USER="ubuntu"  # fallback if not set
fi

xhost +local:docker

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
XAUTH_DOCKER=/tmp/.docker.xauth

# create xauth file if needed
if [ ! -f "$XAUTH" ]; then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]; then
        echo "$xauth_list" | xauth -f "$XAUTH" nmerge -
    else
        touch "$XAUTH"
    fi
    chmod a+r "$XAUTH"
fi

# check for nvidia gpu
if nvidia-smi | grep -q NVIDIA; then
    echo "NVIDIA GPU detected, initializing container with GPU support"
    docker run -it --network host \
        --privileged \
        --name "$CONTAINER_NAME" \
        --gpus all \
        --runtime nvidia \
        --env="DISPLAY=$DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --env="NVIDIA_DRIVER_CAPABILITIES=all" \
        --volume="/etc/timezone:/etc/timezone:ro" \
        --volume="/etc/localtime:/etc/localtime:ro" \
        --volume="$XSOCK:$XSOCK:rw" \
        --volume="$XAUTH:$XAUTH_DOCKER:rw" \
        --volume="$HOST_WS_PATH:/home/$DOCKER_USER/$ROS2_WS_NAME/src" \
        "$DOCKER_IMAGE" \
        bash
else
    echo "NVIDIA GPU NOT detected, initializing container without GPU support"
    docker run -it --network host \
        --privileged \
        --name "$CONTAINER_NAME" \
        --env="DISPLAY=$DISPLAY" \
        --volume="$XSOCK:$XSOCK:rw" \
        --volume="$XAUTH:$XAUTH_DOCKER:rw" \
        --volume="/dev:/dev" \
        --volume="/etc/timezone:/etc/timezone:ro" \
        --volume="/etc/localtime:/etc/localtime:ro" \
        --volume="$HOST_WS_PATH:/home/$DOCKER_USER/$ROS2_WS_NAME/src" \
        "$DOCKER_IMAGE" \
        bash
fi
