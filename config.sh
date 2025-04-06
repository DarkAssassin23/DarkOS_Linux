#!/bin/sh

## Root directory where linux, busybox, glibc, and gcc source should be/are
## NOTE: DO NOT modify these if you are building with the Docker method
ROOT=$PWD
INSTALLDIR=$ROOT/busybox/_install
FILESYSTEMDIR=$ROOT/rootfs
# ISO_DEST=./ # Where to copy the iso to after its built


OSNAME=DarkOS 
ISONAME=$OSNAME # The hostname for the system once it boots
MENUNAME=darkos_linux # Name for the OS in GRUB
LINUXNAME=$OSNAME'_Linux'

ISO=$MENUNAME.iso
ARCH=x86 # Architecture directory where the bzImage will be

# Build and include GCC as part of the ISO
# export INCLUDE_GCC_BUILD=yes

# Are we building in a docker container?
export DOCKER_OS_BUILD=yes

# Kernel version to use (e.g., v6.12) if blank, use master
# KERNELV='v6.13'

# Busybox version to use (e.g., 1_36_1) if blank, use master
# BUSYBOXV='1_36_1'

# GLIBC version to use (e.g., 2.40) if blank, use master
# NOTE: Don't prepend 'glibc-' since that will be done by the script
# GLIBCV='2.40'

# GCC version to use (e.g., 14.2.0) if blank, use master
# NOTE: Version should be a release, not basepoint
# NOTE: Don't prepend 'releases/gcc-' since that will be done by the script
# GCCV='14'

# Zstandard version to use (e.g., v1.5.6) if blank, use master
# ZSTDV='v1.5.6'

# GNU binutils version to use (e.g., 2_43_1) if blank, use master
# NOTE: Don't prepend 'binutils-' since that will be done by the script
# BINUTILSV='2_43_1'

# Directory and list of projects you want to be included in the OS
# NOTE: Each of these projects should have a `make install` rule and take
# in a `INSTALL_PATH` argument to specify where to install the binary(s) to.
# If you are using a different variable name, like DESTDIR, update the
# `buildISO.sh` script accordingly
# USERPROGROOT=
# PROGDIRS=("prog1" "prog2" "prog3")

## Release information
NAME=$OSNAME' Linux'
VERSION_ID='1.0'
VERSION_NAME='(Darkness)'
VERSION=$VERSION_ID' '$VERSION_NAME
ID=$OSNAME
ID_LIKE=$MENUNAME
PRETTY_NAME=$NAME' '$VERSION
HOME_URL='https://'$MENUNAME'.com' # Doesn't exist lol

