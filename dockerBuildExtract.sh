#!/bin/sh

. ./config.sh

# Create the environmnet and build the ISO
docker build -t linux-build .

# Extract the ISO
container=$(docker create linux-build)
docker cp "$container:/server/tmp/$ISO" .

# Clean up
docker rm "$container"
docker image rm linux-build
docker system prune -f

