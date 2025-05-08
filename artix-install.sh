#!/bin/bash

# Minimalist Artix Linux Install Script (No Encryption, Suckless Philosophy)

# If not running as root, re-execute as root using su
if [ "$EUID" -ne 0 ]; then
  echo "[!] Not running as root. Asking for root password..."
  exec su -c "bash '$0'"
fi

set -e

echo "[+] Running as root. Continuing..."

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
read -p "    Press Enter to launch cfdisk..." _ && cfdisk "$DISK"

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
  networkmanager networkmanager-runit runit elogind-runit vim git \
  efibootmgr bash-completion

fstabgen -U /mnt >> /mnt/etc/fstab

# Get user info
read -s -p "[?] Enter root password: " ROOTPASS && echo
read -p "[?] Enter new username: " USERNAME
read -s -p "[?] Enter password for user '$USERNAME': " USERPASS && echo

# Write chroot config script
cat > /mnt/setup_inside_chroot.sh <<EOF
#!/bin/bash
set -e

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

sed -i '/en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "0X" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       0X.localdomain 0X
EOL

echo "[+] Setting root password..."
echo "root:$ROOTPASS" | chpasswd

echo "[+] Creating user '$USERNAME'..."
useradd -mG wheel "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd

echo "[+] Enabling sudo for wheel group..."
sed -i 's/^# %wheel/%wheel/' /etc/sudoers

echo "[+] Installing fonts..."
pacman -S --noconfirm ttf-hack ttf-hack-nerd

echo "[+] Installing liked packages..."
pacman -S --noconfirm neofetch

echo "[+] Installing GRUB bootloader..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "[✓] Setup complete inside chroot."
EOF

chmod +x /mnt/setup_inside_chroot.sh

# Run chroot setup
echo "[+] Entering chroot to complete installation..."
artix-chroot /mnt /setup_inside_chroot.sh

# Clean up
rm /mnt/setup_inside_chroot.sh

echo "[✓] Installation complete. Reboot now."
reboot