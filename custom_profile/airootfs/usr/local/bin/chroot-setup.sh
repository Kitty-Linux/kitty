#!/bin/bash
set -e

if [[ "${TARGET_DRIVE: -1}" =~ [0-9] ]]; then
    ROOT_PART="${TARGET_DRIVE}p3"
else
    ROOT_PART="${TARGET_DRIVE}3"
fi

echo "--> Setting system clock and hardware alignment..."
ln -sf /usr/share/zoneinfo/America/Santiago /etc/localtime
hwclock --systohc

echo "--> Generating system localization configurations..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "--> Configuring Hostname: $MY_HOSTNAME"
echo "$MY_HOSTNAME" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$MY_HOSTNAME.localdomain\t$MY_HOSTNAME" > /etc/hosts

echo "--> Setting up users..."
echo "root:$ROOT_PASS" | chpasswd
useradd -m -G wheel -s /bin/bash "$MY_USERNAME"
echo "$MY_USERNAME:$USER_PASS" | chpasswd

echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "--> Setting up systemd services..."
systemctl enable NetworkManager

echo "--> Finalizing OS Branding..."
cat <<EOF > /etc/os-release
NAME="Kitty Linux"
PRETTY_NAME="Kitty Linux"
ID=kitty
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://github.com/yourusername"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://github.com/yourusername/issues"
LOGO=archlinux
EOF

cat <<EOF > /etc/lsb-release
DISTRIB_ID=KittyLinux
DISTRIB_RELEASE=rolling
DISTRIB_CODENAME=rolling
DISTRIB_DESCRIPTION="Kitty Linux"
EOF

echo "--> Deploying Bootloader..."
bootctl install

TARGET_PARTUUID=$(blkid -s PARTUUID -o value "$ROOT_PART")

cat <<EOF > /boot/loader/entries/arch.conf
title   Kitty Linux (stable)
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$TARGET_PARTUUID rw rootflags=subvol=@
EOF

cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 3
console-mode max
editor  no
EOF

echo "--> Chroot configuration lifecycle finished successfully!"
exit