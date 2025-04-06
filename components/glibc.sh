#!/bin/sh

. ./config.sh

### Build and Install GLIBC ###
cd $ROOT/glibc
# Configure GLIBC
if [ -d "build" ]; then
    rm -rf build # Start fresh
fi
mkdir build
cd build
../configure                                         \
    --prefix=                                        \
    --with-headers=$ROOT/linux_installed/usr/include \
    --without-gd                                     \
    --without-selinux                                \
    --disable-werror                                 \
    CFLAGS="-Os -s -fno-stack-protector -fomit-frame-pointer -U_FORTIFY_SOURCE"

# Override GCC Version OS Name
cp ../csu/version.c ../csu/version.c.bak
NEW_CC=$(gcc --version | awk 'NR == 1' | sed -E 's/gcc \(GCC\)(.*)\([^0-9]*(.*\))/\1('"$OSNAME "'\2/')
sed -Ei '/(.*) "__VERSION__"(.*)/s//\1'"$NEW_CC"'\2/' ../csu/version.c

# Build
make -j `nproc`

# If modified the OS GCC reports, revert the change
mv ../csu/version.c.bak ../csu/version.c
cd $ROOT/linux
mv scripts/mkcompile_h.bak scripts/mkcompile_h

## Install GLIBC
cd $ROOT/glibc/build
make install DESTDIR=$INSTALLDIR/ -j `nproc`

