#!/bin/bash

# Minimalist Artix Linux Install Script (No Encryption, Suckless Philosophy)

set -e

echo "[+] Checking internet connection..."
ping -c 1 archlinux.org >/dev/null 2>&1 || {
    echo "[!] No internet. Launching connmanctl to connect WiFi..."
    connmanctl
}

echo "[+] Internet connected."

# Disk selection
DISK="/dev/nvme0n1"
echo "[!] You will now manually partition $DISK with cfdisk."
echo "    Layout: 400M EFI, 128G root, remaining for /home"
read -p "    Press Enter to launch cfdisk..."
cfdisk "$DISK"

# Format partitions
EFI="${DISK}p1"
ROOT="${DISK}p2"
HOME="${DISK}p3"

echo "[+] Formatting partitions..."
mkfs.fat -F32 "$EFI"
mkfs.ext4 -F "$ROOT"
mkfs.ext4 -F "$HOME"

# Mounting
echo "[+] Mounting filesystems..."
mount "$ROOT" /mnt
mkdir -p /mnt/boot/efi /mnt/home
mount "$EFI" /mnt/boot/efi
mount "$HOME" /mnt/home

# Base install
echo "[+] Installing base system..."
basestrap -i /mnt base base-devel linux linux-firmware grub \
  networkmanager networkmanager-runit runit elogind-runit vim \
  efibootmgr bash-completion

fstabgen -U /mnt >> /mnt/etc/fstab

# Enter chroot
echo "[+] Entering chroot..."
artix-chroot /mnt /bin/bash <<'EOF'
set -e

# Time settings
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Locale
sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "0X" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       0X.localdomain 0X
EOL

# Root password
echo "[+] Set root password:"
passwd root

# User creation
USERNAME=username
useradd -mG wheel "$USERNAME"
echo "[+] Set password for user '$USERNAME':"
passwd "$USERNAME"

# Enable sudo
EDITOR=vim visudo  # uncomment: %wheel ALL=(ALL:ALL) ALL

# Autologin (runit getty service)
#sed -i '/noclear/ --autologin '$USERNAME /etc/runit.d/tty1

# Fonts
pacman -S --noconfirm ttf-hack ttf-hack-nerd

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

EOF

echo "[✓] Install complete. Rebooting..."
reboot

