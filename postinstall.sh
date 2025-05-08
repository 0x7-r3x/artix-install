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

# Fallback installer
echo "[+] Installing additional software packages with fallback (pacman -> yay)..."
PACKAGE_LIST=(
xorg base-devel libX11-devel libXft-devel libXinerama-devel chromium ffmpeg ntfs-3g ugrep noto-fonts-emoji noto-fonts-cjk feh lsd
webkit2gtk-devel gcr-devel gstreamer1-devel lxappearance neovim clipmenu mpv mpd alsa-utils ncmpcpp cava newsboat zathura mupdf ranger
ueberzug qutebrowser sakura w3m nodejs gimp bash-completion yt-dlp aria2 neofetch flameshot cmake ninja meson curl ImageMagick
NetworkManager arandr bat breeze clang cmatrix lolcat-c figlet colordiff timeshift flac fzf git gstreamer-vaapi harfbuzz-devel htop
imlib2-devel jq kdenlive libev-devel libjpeg-turbo-devel libmpc-devel linux-headers man-db mpc papirus-folders papirus-icon-theme
pcre-devel pkgconf-devel python3-adblock python3-pip rsync simple-mtpfs terminus-font v4l2loopback void-docs-browse
xdg-desktop-portal-wlr xdotool zathura-pdf-mupdf tmux xcb-util-renderutil-devel xcb-util-image-devel pkgconf uthash libconfig-devel
figlet-fonts dunst noto-fonts-ttf pass wkhtmltopdf audacity readline-devel readline file-devel plata-theme img2pdf pcmanfm cups
cups-pdf libinput-gestures river sway Waybar sandbar foot pamixer fcft-devel droidcam asciinema polybar bspwm sxhkd grim slop slurp
tor tint2 openbox xfce4 obmenu-generator obconf hplip-gui clipman nerd-fonts wireshark-qt wireshark nim passmenu cvs unbound
poppler-utils lf i3-gaps i3lock vim mupdf linux-lts scrot qemu virt-manager libvirt vte3 vde2 bridge-utils time screenkey
clang-analyzer cmatrix emacs ffplay gdb go zig gvim hugo inkscape instaloader intel-media-driver linux-lts-headers pandoc pdftag
rnnoise slop stow tcc texlive texlive-core wofi wbg Mousai NoiseTorch SDL2_gfx-devel SDL2_image-devel SDL2_ttf-devel SDL-devel
aircrack-ng WoeUSB alsa-rnnoise alsa-plugins-ffmpeg android-tools alsa-plugins-jack barrier-gui bluez-alsa catimg clang-tools-extra
cloc cool-retro-term cwm docker docbook dotool droidcam droidcam-obs-plugin farbfeld fff ffmpegthumbs ffscreencast flashrom
font-iosevka github-cli glade3 giflib-tools glances groff-doc hyperfine joe libmagick-devel linux-lts most mpv-mpris mutt nemo
newsraft nginx openvpn pass-import pass-otp patchutils progress python3-adblock qt5ct rnnoise rofi-emoji rtkit spice-vdagent termrec
tigervnc tty-clock typespeed unclutter virt-viewer waydroid weechat wf-recorder wine wlr-randr wlroots0.17-devel wlroots0.17
wayvnc xdg-desktop-portal-wlr xorg-server-xephyr xtools zig ack valgrind time linuxwave mako resynthesizer
)

for pkg in "${PACKAGE_LIST[@]}"; do
    if sudo pacman -Si "$pkg" >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$pkg"
    elif yay -Si "$pkg" >/dev/null 2>&1; then
        yay -S --noconfirm "$pkg"
    else
        echo "[!] Skipping not found: $pkg"
    fi
done

echo "[✓] Full post-installation setup complete."