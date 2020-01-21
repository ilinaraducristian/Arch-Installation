#!/bin/sh
SWAP_FILE_OFFSET=$(filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }' | sed 's/\.//g')
KERNEL_PARAMETERS="root=/dev/sda2 rw initrd=\\intel-ucode.img initrd=\\initramfs-linux.img intel_iommu=on iommu=pt resume=/dev/sda2 swap_file_offset=$SWAP_FILE_OFFSET"
efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader "\\vmlinuz-linux" --unicode "$KERNEL_PARAMETERS" --verbose
