#!/bin/bash

# Minimalist Artix Linux Install Script (No Encryption, Suckless Philosophy)

# If not running as root, re-execute as root using su
if [ "$EUID" -ne 0 ]; then
  echo "[!] Not running as root. Asking for root password..."
  exec su -c "bash '$0'"
fi

# --- From here, the script is running as root ---
echo "[+] Running as root. Continuing..."

set -e

echo "[+] Checking internet connection..."
ping -c 1 archlinux.org >/dev/null 2>&1 || {
    echo "[!] No internet. Launching connmanctl to connect WiFi..."
    connmanctl
}

echo "[+] Internet connected."

# Disk selection
lsblk -d -e 7,11 -o NAME,SIZE,MODEL
read -p "[?] Enter your target disk (e.g., /dev/nvme0n1, /dev/sda, /dev/vda): " DISK
[ ! -b "$DISK" ] && echo "[!] Invalid disk." && exit 1

echo "[!] Partitioning $DISK (EFI: 400M, Root: 128G, Home: remaining)"
read -p "    Press Enter to launch cfdisk..."
cfdisk "$DISK"

# Handle partition suffix (p for nvme)
P=; [[ "$DISK" == *"nvme"* ]] && P="p"
EFI="${DISK}${P}1"
ROOT="${DISK}${P}2"
HOME="${DISK}${P}3"

echo "[+] Formatting partitions..."
mkfs.fat -F32 "$EFI"
mkfs.ext4 -F "$ROOT"
mkfs.ext4 -F "$HOME"

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

# Set root password
echo "[+] Set root password:"
passwd

# Create new user
read -p "[?] Enter new username: " USERNAME
useradd -mG wheel "$USERNAME" || { echo "[!] Failed to create user."; exit 1; }

echo "[+] Set password for user '$USERNAME':"
passwd "$USERNAME"

# Enable sudo for wheel group
echo "[+] Opening visudo. Uncomment this line to allow sudo for wheel group:"
echo "    %wheel ALL=(ALL:ALL) ALL"
read -p "    Press Enter to open visudo..."
EDITOR=vim visudo

# Fonts (optional)
echo "[+] Installing fonts..."
pacman -S --noconfirm ttf-hack ttf-hack-nerd

# GRUB Bootloader installation
echo "[+] Installing GRUB bootloader..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

exit

echo "[✓] Install complete. You may now exit and reboot."
reboot