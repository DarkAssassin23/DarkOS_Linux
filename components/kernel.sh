#!/bin/sh

. ./config.sh

### Build kernel ###
cd $ROOT/linux

## Customize build info ##
# Make sure version of is always #1
rm .version 2>/dev/null

# Optional: exports to set the desired username and host
export KBUILD_BUILD_USER=shadows
export KBUILD_BUILD_HOST=$LINUXNAME

# Optional: Change OS GCC reports
NEW_CC=$(gcc --version | awk 'NR == 1' | sed -E 's/(.*)\([^0-9]*(.*\))/\1('"$OSNAME"' \2/')
cp scripts/mkcompile_h scripts/mkcompile_h.bak
sed -Ei '/(.*)\$\{CC_VERSION\}(.*)/s//\1'"$NEW_CC"'\2/' scripts/mkcompile_h

# Make default config file
make defconfig
make bzImage -j `nproc`

# Install Headers
if [ ! -d "../linux_installed" ]; then
    mkdir -p ../linux_installed
fi
make INSTALL_HDR_PATH=../linux_installed/usr headers_install
# Copy linux headers so g++ can find them
cp -r ../linux_installed/usr/ $INSTALLDIR

