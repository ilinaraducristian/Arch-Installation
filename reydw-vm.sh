#!/bin/sh

print() {
    printf '\e[1;31m%b\e[m' "[ $1 ]\n"
}

if [ $# -eq 0 ]; then

# print "Partition disk"
# printf "label: gpt\nlabel-id: 3DF407DD-3AF8-F14D-A77D-BF2C51A1F8A4\ndevice: /dev/vda\nunit: sectors\nfirst-lba: 2048\nlast-lba: 468862094\n/dev/vda1 : start=        2048, size=     2097152, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=765CD0DC-177F-194F-A709-839EDBD37998\n/dev/vda2 : start=     2099200, size=   466762895, type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709, uuid=56AC158C-E125-8849-9AB3-09A30943E6B4" | sfdisk /dev/vda
# mkfs.fat -F32 /dev/vda1
# mkfs.ext4 /dev/vda2

print "Mount /dev/vda2 root partition"
mount /dev/vda2 /mnt

print "Set NTP time"
timedatectl set-ntp true

print "Set Romanian mirrors"
printf "Server = http://archlinux.mirrors.linux.ro/\$repo/os/\$arch\nServer = http://mirrors.m247.ro/archlinux/\$repo/os/\$arch\nServer = http://mirrors.nav.ro/archlinux/\$repo/os/\$arch\nServer = http://mirrors.nxthost.com/archlinux/\$repo/os/\$arch\nServer = https://mirrors.nxthost.com/archlinux/\$repo/os/\$arch\nServer = http://mirrors.pidginhost.com/arch/\$repo/os/\$arch\nServer = https://mirrors.pidginhost.com/arch/\$repo/os/\$arch\n" > /etc/pacman.d/mirrorlist

print "Install arch"
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot
pacstrap /mnt base base-devel
umount /mnt/boot

print "Chroot to arch"
cp $0 /mnt
arch-chroot /mnt sh $0 1

elif [ $# -eq 1 ]; then

print "Mounting efi partition"
mount /dev/vda1 /boot

print "Set Bucharest timezone"
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc

print "Generate locale"
LOCALES[0]="en_US.UTF-8 UTF-8"
LOCALES[1]="ro_RO.UTF-8 UTF-8"

for i in {0..2}; do
    sed -i "s/#${LOCALES[$i]}/${LOCALES[$i]}/g" /etc/locale.gen
done

printf "LANG=en_US.UTF-8\nLC_NUMERIC=en_US.UTF-8\nLC_TIME=ro_RO.UTF-8\nLC_MONETARY=en_US.UTF-8\nLC_PAPER=ro_RO.UTF-8\nLC_MEASUREMENT=ro_RO.UTF-8\n" > /etc/locale.conf
locale-gen

print "Set hostname"
printf "reydw-vm\n" > /etc/hostname
printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\treydw-vm.localdomain\treydw-vm\n" > /etc/hosts

print "Generate fstab"
printf "# <device>\t<dir>\t<type>\t<options>\t<dump>\t<fsck>\ndev/vda1\t/boot\tvfat\tdefaults\t0\t0\n/dev/vda2\t/\text4\trw,relatime\t0\t1\n/swapfile\tnone\tswap\tsw\t\t0\t0\n" > /etc/fstab

print "Enable multilib repositories"
mv /etc/pacman.conf /etc/pacman.conf.bak
awk 'BEGIN{a=0}{if(a==1){sub("#","",$0);a=0}if($0=="#[multilib]"){sub("#","",$0);a=1}print $0}' /etc/pacman.conf.bak > /etc/pacman.conf
rm /etc/pacman.conf.bak

print "Install official packages"
pacman -Syy --noconfirm efibootmgr intel-ucode networkmanager gnome-shell-extensions gdm gnome-control-center gnome-terminal gnome-system-monitor gnome-tweaks gnome-disk-utility nautilus noto-fonts ttf-liberation ttf-dejavu chromium docker code qemu virt-manager ovmf wine xdg-user-dirs git go steam gimp docker jdk-openjdk libreoffice-fresh vim cups vlc eog okular autorandr cmake openssh gdb samba docker-compose file-roller

print "Make OS bootable"
KERNEL_PARAMETERS="root=/dev/vda2 rw initrd=\\intel-ucode.img initrd=\\initramfs-linux.img"
efibootmgr --disk /dev/vda --part 1 --create --label "Arch Linux" --loader "\\vmlinuz-linux" --unicode "$KERNEL_PARAMETERS" --verbose

print "Set root password"
passwd

print "Creating user reydw"
useradd -m -g users -G wheel reydw

print "Set reydw password"
passwd reydw

print "Enable wheel group"
sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers

fi
