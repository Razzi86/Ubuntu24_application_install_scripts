#!/bin/sh

CONTAINER_NAME="$1" # name of the container to remove

# stop and remove the container
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
