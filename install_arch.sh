#!/bin/sh

print() {
    printf '\e[1;31m$1\e[m\n'
}

if [ $1 -eq 0 ]; then
print "Set NTP time"
timedatectl set-ntp true
print "Set Romanian mirror"
printf "Server = http://mirrors.nxthost.com/archlinux/\$repo/os/\$arch\n" > /etc/pacman.d/mirrorlist
print "Install arch"
pacstrap /mnt base-devel
print "Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab
cp install_arch.sh /mnt
print "Root into arch"
arch-chroot /mnt sh install_arch.sh 1

elif [ $1 -eq 1 ]; then

print "Set timezone"
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc
print "Generate locale"
LOCALES[0]="en_US.UTF-8 UTF-8"
LOCALES[1]="ro_RO.UTF-8 UTF-8"
LOCALES[2]="ja_JP.UTF-8 UTF-8"
for i in {0..2}; do
    sed -i "s/printf${LOCALES[$i]}/${LOCALES[$i]}/g" /etc/locale.gen
done
printf "LANG=en_US.UTF-8
LC_NUMERIC=ro_RO.UTF-8
LC_TIME=ro_RO.UTF-8
LC_MONETARY=ro_RO.UTF-8
LC_PAPER=ro_RO.UTF-8
LC_MEASUREMENT=ro_RO.UTF-8
" > /etc/loca8le.conf
locale-gen
print "Set hostname"
printf "reydw-0
" > /etc/hostname
printf "127.0.0.1\tlocalhost
::1\t\tlocalhost
192.168.1.4\treydw-0.localdomain\treydw-0
" > /etc/hosts
print "Make swapfile"
fallocate -l 12G /swapfile
chmod 600 /swapfile
mkswap /swapfile
printf "$(cat /etc/fstab)\n\n# /swapfile\n/swapfile\tnone\tswap\tdefaults\t0\t0\n" > /etc/fstab
print "Install Microcode"
pacman -Syy intel-ucode --noconfirm
mount /dev/sda1 /boot
print "Make OS bootable"
pacman -S linux efibootmgr --noconfirm
SWAP_FILE_OFFSET=$(filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }' | sed 's/[^0-9]*//g')
ROOT_PARTUUID=$(blkid /dev/sda2 --output value | awk "{ if (NR==3) print $0 }")
KERNEL_PARAMETERS='root=PARTUUID=$ROOT_PARTUUID rw initrd=\initramfs-linux.img initrd=/intel-ucode.img initrd=/initramfs-linux.img resume=/dev/sda2 swap_file_offset=$SWAP_FILE_OFFSET'
efibootmgr --disk /dev/sda --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode $KERNEL_PARAMETERS --verbose
print "Set root password"
passwd
print "Creating user reydw"
useradd -m reydw
print "Set reydw password"
passwd reydw
print "Install packages"
fi