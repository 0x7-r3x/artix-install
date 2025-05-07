#!/bin/bash

# Minimal Post-Install Setup for Artix (runit)

set -e

echo "[+] Launching nmtui to configure network..."
nmtui

echo "[+] Enabling Arch Linux repositories..."
sudo pacman -S --noconfirm artix-archlinux-support
sudo pacman-key --populate archlinux
sudo pacman -S --noconfirm archlinux-mirrorlist

echo "[+] Appending [extra] repo to the end of pacman.conf..."
sudo bash -c 'echo -e "\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch" >> /etc/pacman.conf'

echo "[+] Syncing pacman..."
sudo pacman -Sy --noconfirm

echo "[+] Updating system and installing essential packages..."
sudo pacman -Syu --noconfirm base-devel go git \
  xf86-video-amdgpu xorg --ignore xorg-server-xdmx firefox mpd dunst \
  network-manager-applet redshift feh blueman pasystray gnupg xbindkeys \
  xsettingsd

echo "[+] Installing yay (AUR helper)..."
cd /tmp/
if [ ! -d yay ]; then
    git clone https://aur.archlinux.org/yay
fi
cd yay
makepkg -si --noconfirm
cd ~

echo "[+] Installing AUR packages with yay..."
yay -Sy --noconfirm brave-bin alsa-utils xhidecursor

echo "[✓] Post-installation setup complete."
