#!/bin/sh

. ./config.sh

### Build busybox ###
cd $ROOT/busybox

# Make default config file for busybox and make requisite updates
make defconfig
# NOTE: Trying to build TC causes build errors so disable them
sed -i "s|CONFIG_TC=.*|# CONFIG_TC is not set|" .config
sed -i "s|.*CONFIG_FEATURE_TC_INGRESS.*|# CONFIG_FEATURE_TC_INGRESS is not set|" .config

make -j `nproc`
make install

