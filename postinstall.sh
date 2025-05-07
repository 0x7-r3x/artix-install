#!/bin/bash
# Minimal Post-Install Setup for Artix (runit)

set -e

echo "[+] Launching nmtui to configure network..."
nmtui

echo "[+] Enable Arch Linux repositories..."
sudo pacman -S --noconfirm artix-archlinux-support
sudo pacman-key --populate archlinux
sudo pacman -Sy --noconfirm

echo "[+] Inserting [extra] repo after [galaxy] in pacman.conf..."
sudo sed -i '/^\[galaxy\]/a \
[extra]\nInclude = /etc/pacman.d/mirrorlist-arch\n' /etc/pacman.conf

echo "[+] Updating system and installing essential packages..."
sudo pacman -Syu --noconfirm base-devel go git \
  xf86-video-amdgpu xorg --ignore xorg-server-xdmx firefox mpd dunst \
  nm-applet redshift feh blueman pasystray gpg-agent xbindkeys \
  xsettingsd barrier xhidecursor

echo "[+] Installing yay (AUR helper)..."
cd /tmp/
git clone https://aur.archlinux.org/yay
cd yay
makepkg -si --noconfirm
cd ~

echo "[+] Installing AUR packages with yay..."
yay -Sy --noconfirm brave-bin alsa-utils

echo "[✓] Post-installation setup complete."
