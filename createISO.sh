#!/bin/sh

. ./config.sh
cd $ROOT

### Make ISO ###
GRUBCFG=iso/boot/grub/grub.cfg
mkdir -p iso/boot/grub
cp busybox/initramfs.cpio.gz iso/boot/initramfs
cp linux/arch/$ARCH/boot/bzImage iso/boot/
cat > $GRUBCFG << EOF
default=0
timeout=5

menuentry '$MENUNAME' --class os {
    insmod gzio
    insmod part_msdos
    linux /boot/bzImage newroot=/dev/sr0/rootfs.img
    initrd /boot/initramfs
}
EOF
genisoimage -r -o iso/rootfs.img $FILESYSTEMDIR/
if which sudo > /dev/null; then
    sudo grub-mkrescue -o $ISO iso/
else
    grub-mkrescue -o $ISO iso/
fi
