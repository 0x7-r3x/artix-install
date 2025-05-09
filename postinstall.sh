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
  xf86-video-amdgpu xorg --ignore xorg-server-xdmx xorg-server xorg-xinit libx11 libxinerama libxft webkit2gtk firefox mpd dunst \
  network-manager-applet meson cmake libev libconfig uthash redshift feh blueman pasystray gnupg xbindkeys \
  xsettingsd

echo "[+] Installing yay (AUR helper)..."
if ! command -v yay >/dev/null 2>&1; then
    cd /tmp/
    if [ ! -d yay ]; then
        git clone https://aur.archlinux.org/yay
    fi
    cd yay
    makepkg -si --noconfirm
    cd ~
else
    echo "[i] yay is already installed. Skipping..."
fi

echo "[+] mkdir new _folders"
mkdir -p Videos Images Downloads Documents Music

echo "[+] Installing AUR packages with yay..."
yay -Sy --noconfirm brave-bin alsa-utils xhidecursor sxwm

echo "[+] Cloning and installing custom picom fork..."
cd /tmp/
if [ ! -d picom ]; then
    git clone https://github.com/pijulius/picom
fi
cd picom
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install

# Packages for pacman
PACMAN_PACKAGES=( \
    base-devel libx11 libxft libxinerama ffmpeg ntfs-3g noto-fonts-emoji \
    noto-fonts-cjk feh webkit2gtk gstreamer lxappearance neovim mpv mpd \
    alsa-utils ncmpcpp cava newsboat zathura mupdf ranger sakura nodejs \
    bash-completion yt-dlp aria2 neofetch stow flameshot cmake ninja meson \
    curl imagemagick networkmanager arandr bat breeze clang cmatrix lolcat \
    figlet colordiff timeshift flac fzf git gstreamer-vaapi harfbuzz htop \
    imlib2 jq libev libjpeg-turbo libmpc linux-headers man-db mpc \
    papirus-icon-theme pcre pkgconf python-adblock python-pip rsync mtpfs \
    ttf-hack ttf-hack-nerd v4l2loopback-dkms v4l2loopback-utils \
    xdg-desktop-portal-wlr xdotool zathura-pdf-mupdf tmux \
    xcb-util-renderutil xcb-util-image uthash libconfig dunst pass audacity \
    readline file img2pdf cups cups-pdf \
)

# Packages for yay (AUR)
YAY_PACKAGES=(
    ugrep lsd gcr clipmenu-git ueberzugpp-nogl wkhtmltopdf-bin plata-theme libinput-gestures
)

# Install pacman packages
echo "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# Install yay packages (AUR)
echo "Installing yay packages..."
yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"

echo "Installation complete!"
echo "[✓] Full post-installation setup complete."