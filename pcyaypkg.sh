#!/bin/bash

# Packages for pacman
PACMAN_PACKAGES=(
    base-devel libx11 libxft libxinerama ffmpeg ntfs-3g noto-fonts-emoji
    noto-fonts-cjk feh webkit2gtk gstreamer lxappearance neovim mpv mpd
    alsa-utils ncmpcpp cava newsboat zathura mupdf ranger sakura nodejs
    bash-completion yt-dlp gtk-engine-murrine ttf-roboto marco aria2 neofetch stow flameshot cmake ninja meson
    curl imagemagick networkmanager arandr bat breeze clang cmatrix lolcat
    figlet colordiff timeshift flac fzf git gstreamer-vaapi harfbuzz htop
    imlib2 jq libev libjpeg-turbo libmpc linux-headers man-db mpc
    papirus-icon-theme pcre pkgconf python-adblock python-pip rsync mtpfs
    ttf-hack ttf-hack-nerd v4l2loopback-dkms v4l2loopback-utils
    xdg-desktop-portal-wlr xdotool zathura-pdf-mupdf tmux
    xcb-util-renderutil xcb-util-image uthash libconfig dunst pass audacity
    readline file img2pdf cups cups-pdf wmctrl
    # Hyprland & deps (official repos)
    hyprland wayland wayland-protocols wlroots xdg-desktop-portal-hyprland
    xdg-desktop-portal xdg-desktop-portal-gtk seatd polkit dbus pipewire
    pipewire-pulse pipewire-alsa pipewire-jack wireplumber wl-clipboard
    xorg-xwayland playerctl alacritty waybar network-manager-applet
    nm-connection-editor
)

# Packages for yay (AUR)
YAY_PACKAGES=(
    ugrep lsd gcr clipmenu-git ueberzugpp-nogl wkhtmltopdf-bin plata-theme libinput-gestures
    kitty waybar-hyprland swaybg swaylock-effects wofi wlogout mako thunar
    ttf-jetbrains-mono-nerd polkit-gnome python-requests starship
    swappy pamixer gvfs bluez bluez-utils xfce4-settings
    dracula-gtk-theme dracula-icons-git
)

# Install pacman packages
echo "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# Install yay packages (AUR)
echo "Installing yay packages..."
yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"

echo "Installation complete!"
