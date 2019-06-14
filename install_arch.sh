#!/bin/sh
# Set NTP time
timedatectl set-ntp true
# Set Romanian mirror
printf "Server = http://mirrors.nxthost.com/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist
# Install arch
pacstrap /mnt base-devel
# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
# Root into arch
arch-chroot /mnt