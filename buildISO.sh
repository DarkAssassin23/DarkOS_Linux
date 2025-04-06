#!/bin/bash

######################################################
# NOTE: Assumes all required packages are installed  #
######################################################
SCRIPT_DIR=$PWD
. ./config.sh

# Repos that checked out to a specific version
checked_out=()

# Check if linux source exists
cd $ROOT
if [ ! -d "linux" ]; then
    git clone https://github.com/torvalds/linux.git --depth=1
else
    cd linux && git pull
fi
if [ -n "$KERNELV" ]; then
    if [ $(git rev-parse --verify "$KERNELV") ]; then
        echo Using kernel version: $KERNELV
        echo Checking out $KERNELV.
        git checkout "$KERNELV" > /dev/null 2>&1
        checked_out+="linux"
        echo done.
    fi
fi
cd $ROOT

# Check if busybox source exists
if [ ! -d "busybox" ]; then
    git clone https://github.com/mirror/busybox.git --depth=1
else
    cd busybox && git pull
fi
if [ -n "$BUSYBOXV" ]; then
    if [ $(git rev-parse --verify "$BUSYBOXV") ]; then
        echo Using Busybox version: $BUSYBOXV
        echo Checking out $BUSYBOXV.
        git checkout "$BUSYBOXV" > /dev/null 2>&1
        checked_out+="busybox"
        echo done.
    fi
fi
cd $ROOT

# Check if glibc source exists
if [ ! -d "glibc" ]; then
    git clone https://github.com/bminor/glibc.git --depth=1
else
    cd glibc && git pull
fi
if [ -n "$GLIBCV" ]; then
    if [ $(git rev-parse --verify "glibc-$GLIBCV") ]; then
        echo Using glibc version: $GLIBCV
        echo Checking out glibc-$GLIBCV.
        git checkout "glibc-$GLIBCV" > /dev/null 2>&1
        checked_out+="glibc"
        echo done.
    fi
fi
cd $ROOT

# Only needed if GCC should be included
if [ ! -z $INCLUDE_GCC_BUILD ]; then
    # Check if GCC source exists
    if [ ! -d "gcc" ]; then
        git clone https://gcc.gnu.org/git/gcc.git --depth=1
    else
        cd gcc && git pull
    fi
    if [ -n "$GCCV" ]; then
        if [ $(git rev-parse --verify "releases/gcc-$GCCV") ]; then
            echo Using GCC version: $GCCV
            echo Checking out $GCCV.
            git checkout "releases/gcc-$GCCV" > /dev/null 2>&1
            checked_out+="gcc"
            echo done.
        fi
    fi
    ./contrib/download_prerequisites

    # Check if Zstd source exists
    mkdir -p gcc_utils && cd gcc_utils
    if [ ! -d "zstd" ]; then
        git clone https://github.com/facebook/zstd.git --depth=1
    else
        cd zstd && git pull
    fi
    if [ -n "$ZSTDV" ]; then
        if [ $(git rev-parse --verify "$ZSTDV") ]; then
            echo Using zstd version: $ZSTDV
            echo Checking out $ZSTDV.
            git checkout $ZSTD > /dev/null 2>&1
            checked_out+="gcc/gcc_utils/zstd"
            echo done.
        fi
    fi

    cd $ROOT
    # Check if binutils source exists
    if [ ! -d "binutils" ]; then
        git clone https://sourceware.org/git/binutils-gdb.git  binutils --depth=1
    else
        cd binutils && git pull
    fi
    if [ -n "$BINUTILSV" ]; then
        if [ $(git rev-parse --verify "binutils-$BINUTILSV") ]; then
            echo Using binutils version: $BINUTILSV
            echo Checking out $BINUTILSV.
            git checkout "binutils-$BINUTILSV" > /dev/null 2>&1
            checked_out+="binutils"
            echo done.
        fi
    fi
fi

### Build and install OS Components ###
# Build busybox
cd $SCRIPT_DIR
. ./components/busybox.sh

# Build and Install Kernel
cd $SCRIPT_DIR
. ./components/kernel.sh

# Build and Install GLIBC
cd $SCRIPT_DIR
. ./components/glibc.sh

# Build and install GCC Utils
if [ ! -z $INCLUDE_GCC_BUILD ]; then
    cd $SCRIPT_DIR
    . ./components/gcc.sh
fi

cd $INSTALLDIR
# Make script aliases
echo "#!/bin/sh" > bin/shutdown
echo "poweroff -f" >> bin/shutdown
chmod +x bin/shutdown

## Make init script
mkdir -p dev proc sys lib lib64
# Copy link glibc libs to lib64 so busybox can find them
ln -f lib/ld* lib64/
ln -f lib/lib* lib64/

cat > init << EOF
#!/bin/sh
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

mkdir -p mnt/iso
mkdir  mnt/rootfs
mkdir -p newroot
losetup /dev/loop0 /dev/sr0
mount -o loop dev/loop0 mnt/iso
mount -o loop /mnt/iso/rootfs.img /newroot
mkdir oldroot

mount --move /dev newroot/dev
mount --move /proc newroot/proc
mount --move /sys newroot/sys
clear
hostname $OSNAME
echo "Welcome to $PRETTY_NAME!"
export PATH=\$PATH:/libexec/gcc/$(arch)-pc-linux-gnu/$GCCV/
chroot /newroot /bin/sh

poweroff -f
EOF
chmod +x init

## Make sure busybox utils are in the filesystem ##
if [ ! -d $FILESYSTEMDIR ]; then
    mkdir -p $FILESYSTEMDIR
fi
cp -r $INSTALLDIR/* $FILESYSTEMDIR/

### Add additional programs ###
if [ ! -z $PROGDIRS ]; then
    for i in "${PROGDIRS[@]}"
    do
        make -C $USRPROGROOT"$i"
        make -C $USRPROGROOT"$i" install INSTALL_PATH=$FILESYSTEMDIR/usr/bin
    done
fi

### Generate os-release file
OSREL=$FILESYSTEMDIR/etc/os-release
cat > $OSREL << EOF
NAME="$NAME"
VERSION="$VERSION"
ID="$ID"
ID_LIKE="$ID_LIKE"
VERSION_ID="$VERSION_ID"
PRETTY_NAME="$PRETTY_NAME"

HOME_URL="$HOME_URL"
EOF

# Create initramfs
cd $INSTALLDIR
find . -print0 | cpio --null -ov --format=newc | pigz -9 > ../initramfs.cpio.gz

### Make iso ###
cd $SCRIPT_DIR
. ./createISO.sh

if [ ! -z $ISO_DEST ]; then
    cp $ISO $ISO_DEST
fi

### Clean up ###
# Reset branch back to master
if [ ${#checked_out[@]} ]; then
    for dir in ${checked_out[@]}
    do
        echo Checking out $dir back to master branch
        cd $ROOT/$dir && git switch - > /dev/null 2>&1
        echo done.
    done
fi
