docker run --entrypoint bash -it --gpus all --rm --network=host \
    nvcr.io/nvidia/isaac-sim:5.1.0 ./isaac-sim.compatibility_check.sh --/app/quitAfter=10 --no-window
