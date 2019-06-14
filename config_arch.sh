#!/bin/sh
# Set timezone
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc
# Generate locale
LOCALES[0]="en_US.UTF-8 UTF-8"
LOCALES[1]="ro_RO.UTF-8 UTF-8"
LOCALES[2]="ja_JP.UTF-8 UTF-8"
for i in {0..2}; do
    sed -i "s/#${LOCALES[$i]}/${LOCALES[$i]}/g" /etc/locale.gen
done
printf "LANG=en_US.UTF-8
LC_NUMERIC=ro_RO.UTF-8
LC_TIME=ro_RO.UTF-8
LC_MONETARY=ro_RO.UTF-8
LC_PAPER=ro_RO.UTF-8
LC_MEASUREMENT=ro_RO.UTF-8
" /etc/locale.conf
locale-gen
# Set hostname
printf "reydw-0" /etc/hostname
printf "127.0.0.1\tlocalhost
::1\t\tlocalhost
192.168.1.4\treydw-0.localdomain\treydw-0
" /etc/hosts
# Set root password
passwd
# Creating user reydw
useradd -m reydw
# Set reydw password
passwd reydw
# Make OS bootable

# Install packages