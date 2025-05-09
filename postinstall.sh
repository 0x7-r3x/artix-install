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
  network-manager-applet meson cmake redshift feh blueman pasystray gnupg xbindkeys \
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
PACMAN_PACKAGES=(
    ffmpeg ntfs-3g ugrep noto-fonts-emoji noto-fonts-cjk feh lsd lxappearance neovim 
    clipmenu mpv mpd alsa-utils ncmpcpp cava newsboat zathura mupdf ranger ueberzug 
    qutebrowser sakura w3m nodejs gimp bash-completion yt-dlp aria2 neofetch flameshot 
    cmake ninja meson curl arandr bat breeze clang cmatrix figlet colordiff timeshift 
    flac fzf git gstreamer-vaapi htop imlib2 jq kdenlive libjpeg-turbo linux-headers 
    man-db mpc papirus-icon-theme pcre pkgconf rsync xdg-desktop-portal-wlr xdotool 
    zathura-pdf-mupdf tmux pkgconf uthash dunst pass wkhtmltopdf audacity img2pdf 
    pcmanfm cups cups-pdf river sway waybar foot pamixer polybar bspwm sxhkd grim 
    slop slurp tor tint2 openbox clipman wireshark-qt nim cvs unbound lf i3lock vim 
    mupdf linux-lts scrot virt-manager libvirt vte3 vde2 bridge-utils time screenkey 
    cmatrix emacs gdb go zig gvim hugo inkscape intel-media-driver linux-lts-headers 
    slop stow tcc wofi mousai aircrack-ng alsa-plugins-jack catimg cool-retro-term 
    docker github-cli hyperfine libjpeg-turbo linux-lts most mpv-mpris mutt nemo nginx 
    openvpn pass-otp patchutils progress qt5ct rnnoise rofi-emoji rtkit spice-vdagent 
    tigervnc virt-viewer wine xdg-desktop-portal-wlr xorg-server-xephyr valgrind time 
    linuxwave mako libx11 libxft libxinerama webkit2gtk gcr imagemagick networkmanager 
    lolcat harfbuzz imlib2 libev libmpc pcre pkgconf xcb-util-renderutil xcb-util-image 
    readline file
)

# Packages for yay (AUR)
YAY_PACKAGES=(
    gstreamer1 papirus-folders simple-mtpfs v4l2loopback void-docs-browse 
    xcb-util-renderutil-devel xcb-util-image-devel libconfig-devel figlet-fonts 
    plata-theme libinput-gestures sandbar fcft-devel droidcam xfce4 obmenu-generator 
    obconf hplip-gui clipman nerd-fonts wireshark passmenu poppler-utils i3-gaps qemu 
    clang-analyzer ffplay instaloader pandoc pdftag texlive texlive-core wbg noisetorch 
    sdl2_gfx-devel sdl2_image-devel sdl2_ttf-devel sdl-devel woeusb alsa-rnnoise 
    alsa-plugins-ffmpeg alsa-plugins-jack barrier-gui bluez-alsa clang-tools-extra 
    cwm docbook dotool droidcam droidcam-obs-plugin farbfeld ffscreencast font-iosevka 
    glade3 giflib-tools groff-doc joe libmagick-devel newsraft pass-import python3-adblock 
    termrec tty-clock typespeed waydroid wlroots0.17-devel xtools resynthesizer
)

# Install pacman packages
echo "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

# Install yay packages (AUR)
echo "Installing yay packages..."
yay -S --needed --noconfirm "${YAY_PACKAGES[@]}"

echo "Installation complete!"
echo "[✓] Full post-installation setup complete."