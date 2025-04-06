#!/bin/sh

. ./config.sh
cd $ROOT

# Check if linux source exists
if [ -d "linux" ]; then
    cd linux
    make mrproper
    cd ..
fi
rm -rf linux_installed

# Check if busybox source exists
if [ -d "busybox" ]; then
    cd busybox
    make mrproper
    rm -rf initramfs.cpio.gz
    rm -rf _install
    cd ..
fi

# Check if glibc source exists
if [ -d "glibc/build" ]; then
    rm -rf glibc/build
fi

# Check if GCC source exists
if [ -d "gcc/build" ]; then
    rm -rf gcc/build
fi

# Check if zstd source exists
if [ -d "gcc/gcc_utils/zstd" ]; then
    cd gcc/gcc_utils/zstd
    make clean
    cd $ROOT
fi

# Check if GNU binutils source exists
if [ -d "binutils/build" ]; then
    rm -rf binutils/build
fi

# Clean all user program directories
for i in "${PROGDIRS[@]}"
do
    make -C $USRPROGROOT"$i" clean
done

# Remove temp filesystem
rm -rf $FILESYSTEMDIR 

if [ -d "iso" ]; then
    rm -rf iso
fi
rm -rf $ISO initramfs.cpio.gz

