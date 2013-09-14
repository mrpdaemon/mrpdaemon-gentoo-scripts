#!/bin/bash

VERSION=$1

# Turn on echo
set -x verbose

echo "Upgrading to Linux $VERSION"

# Get version suffix
[[ $VERSION =~ -r[0-9]* ]]
VER_SUFFIX=$BASH_REMATCH

# And version prefix
VER_PREFIX="${VERSION/$VER_SUFFIX/}"

NEW_DIR=/usr/src/linux-$VER_PREFIX-gentoo$VER_SUFFIX

cp /usr/src/linux/.config $NEW_DIR/.config || { echo "Failed to copy config"; exit 1; }

cd $NEW_DIR

make oldconfig || { echo "Failed to make oldconfig"; exit 1; }

ionice -c3 nice -n19 make -j9 || { echo "Failed to build kernel"; exit 1; }

ionice -c3 nice -n19 make modules_install || { echo "Failed to install modules"; exit 1; }

cp arch/x86_64/boot/bzImage /boot/kernel-$VER_PREFIX-gentoo$VER_SUFFIX || { echo "Failed to copy kernel image to /boot"; exit 1; } 

vi /boot/grub/grub.conf

eselect kernel list

ESELECT_IDX=`eselect kernel list | grep "$VER_PREFIX"-gentoo"$VER_SUFFIX" | awk '{print $1}' | tail -c +2 | head -c +1`

eselect kernel set $ESELECT_IDX || { echo "Failed to set kernel via eselect"; exit 1; }

emerge @module-rebuild || { echo "Failed to build kernel modules"; exit 1; }
