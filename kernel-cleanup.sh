#!/bin/bash

get_package_name()
{
   echo "=sys-kernel/gentoo-sources-$1"
}

get_version_suffix()
{
   [[ $1 =~ -r[0-9]* ]]
   VER_SUFFIX=$BASH_REMATCH
   echo $VER_SUFFIX
}

get_version_prefix()
{
   VER_SUFFIX=$(get_version_suffix $1)
   VER_PREFIX="${1/$VER_SUFFIX/}"
   echo $VER_PREFIX
}

get_modules_dir()
{
   echo "/lib/modules/$(get_version_prefix $1)-gentoo$(get_version_suffix $1)"
}

get_kernel_image_path()
{
   echo "/boot/kernel-$(get_version_prefix $1)-gentoo$(get_version_suffix $1)"
}

get_kernel_src_path()
{
   echo "/usr/src/linux-$(get_version_prefix $1)-gentoo$(get_version_suffix $1)"
}

cleanup_kernel()
{
   PACKAGE_NAME=$(get_package_name $1)
   MODULES_DIR=$(get_modules_dir $1)
   KERNEL_IMAGE_PATH=$(get_kernel_image_path $1)
   KERNEL_SRC_PATH=$(get_kernel_src_path $1)

   echo "Unmerging kernel package for $1"
   echo "> emerge -C $PACKAGE_NAME"
   emerge -C $PACKAGE_NAME

   echo "Cleaning up source dir at $KERNEL_SRC_PATH"
   echo "> ionice -c3 rm -rf $KERNEL_SRC_PATH"
   ionice -c3 rm -rf $KERNEL_SRC_PATH

   echo "Deleting kernel image at $KERNEL_IMAGE_PATH"
   echo "> ionice -c3 rm $KERNEL_IMAGE_PATH"
   ionice -c3 rm $KERNEL_IMAGE_PATH

   echo "Removing modules at $MODULES_DIR"
   echo "> ionice -c3 rm -rf $MODULES_DIR"
   ionice -c3 rm -rf $MODULES_DIR
}

for i in $@; do cleanup_kernel $i;done

vi /boot/grub/grub.conf
