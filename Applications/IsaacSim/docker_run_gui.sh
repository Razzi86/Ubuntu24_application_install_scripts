xhost +local:
docker run --entrypoint bash -it --gpus all --rm --network=host \
    -e "PRIVACY_CONSENT=Y" \
    -v $HOME/.Xauthority:/isaac-sim/.Xauthority \
    -e DISPLAY \
    nvcr.io/nvidia/isaac-sim:5.1.0 ./isaac-sim.compatibility_check.sh
