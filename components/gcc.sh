#!/bin/sh

. ./config.sh

### Build GCC ###
cd $ROOT/gcc
if [ -d "build" ]; then
    rm -rf build # Start fresh
fi
mkdir build
cd build

# Configure GCC
../configure                             \
         --prefix=$FILESYSTEMDIR         \
         --without-headers               \
         --with-pkgversion="$OSNAME GCC" \
         --enable-languages=c,c++        \
         --disable-libquadmath           \
         --disable-libquadmath-support   \
         --disable-werror                \
         --disable-bootstrap             \
         --enable-gold                   \
         --disable-multilib
make -j `nproc`

## Install GCC
cd $ROOT/gcc/build
make install -j `nproc`

# Link C++ libs to the `lib/` directory so C++ programs can find them
cd $FILESYSTEMDIR && ln -f lib64/lib*c++* lib/ && ln -f lib64/libgcc* lib/

### Build and Install zstd ###
cd $ROOT/gcc/gcc_utils/zstd
make -j `nproc` && make prefix=$FILESYSTEMDIR install -j `nproc`
cd $FILESYSTEMDIR && ln -f lib/libzstd* lib64/

### Build and install binutils ###
cd $ROOT/binutils
if [ -d "build" ]; then
    rm -rf build # Start fresh
fi
mkdir build
cd build
../configure --prefix=$FILESYSTEMDIR

make all -j `nproc` && make install -j `nproc`
