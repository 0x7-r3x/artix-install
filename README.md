# Artix Linux Minimal Install Script [runit] (No Encryption, No Autologin)

A simple, suckless-style install script for setting up a clean Artix Linux system using the `runit` init system. This script automates the essential steps while leaving full control over disk partitioning and configuration to the user.

> ⚠️ Warning: This script will **format the target disk**. Use it only in virtual machines or when you're ready to erase your system.

---

## ✅ Features

- No encryption or autologin
- Manual disk partitioning (`cfdisk`)
- Wi-Fi setup using `connmanctl` (only triggered if offline)
- Installs base system with `basestrap`
- Sets locale, timezone, hostname
- Creates root and user accounts
- Installs and configures GRUB for UEFI systems

---

## 🛠 Requirements

- Artix Linux base ISO (runit edition)
- Internet connection (via Wi-Fi or Ethernet)
- Target disk (e.g. `/dev/nvme0n1` or `/dev/sda`)

---

## 📦 Included Packages

Installed via `basestrap`:
- `base`, `base-devel`
- `linux`, `linux-firmware`
- `grub`, `efibootmgr`
- `networkmanager`, `networkmanager-runit`
- `elogind-runit`, `vim`, `bash-completion`

---

## 🚀 Usage

### 1. Boot into Artix Live ISO

Download runit init ISO from <a href="https://artixlinux.org/download.php" target="_blank">artixlinux.org</a> and boot in UEFI mode.

### 2. Download and run the script

```bash
curl -o https://codeberg.org/0xhaxk/artix-install/raw/branch/main/artix-linux.sh
chmod +x artix-linux.sh
./artix-linux.sh
