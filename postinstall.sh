#!/bin/bash
# Minimal Post-Install Setup for Artix (runit)

set -e

echo "[+] Linking runit services..."
sudo ln -sf /etc/runit/sv/NetworkManager /run/runit/service/NetworkManager
sudo ln -sf /etc/runit/sv/bluetoothd /run/runit/service/bluetoothd

echo "[+] Launching nmtui to configure network..."
nmtui

echo "[+] Updating system and installing essential packages..."
sudo pacman -Syu --noconfirm base-devel artix-archlinux-support go git \
  xf86-video-amdgpu xorg --ignore xorg-server-xdmx firefox mpd dunst \
  nm-applet redshift feh blueman pasystray gpg-agent xbindkeys \
  xsettingsd barrier xhidecursor

echo "[!] Review or modify pacman.conf (optional)..."
read -p "    Press Enter to open /etc/pacman.conf with vim..."
sudo vim /etc/pacman.conf

echo "[+] Installing yay (AUR helper)..."
cd /tmp/
git clone https://aur.archlinux.org/yay
cd yay
makepkg -si --noconfirm
cd ~

echo "[+] Installing AUR packages with yay..."
yay -Sy --noconfirm brave-bin alsa-utils

echo "[✓] Post-installation setup complete."
