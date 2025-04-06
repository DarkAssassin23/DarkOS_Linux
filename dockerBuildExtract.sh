#!/bin/sh

# Create the environmnet and build the ISO
docker build -t linux-build .

# Extract the ISO
container=$(docker create linux-build)
docker container run $container
docker cp "$container:/server/tmp/darkos_linux.iso" .

# Clean up
docker rm "$container"
docker image rm linux-build

