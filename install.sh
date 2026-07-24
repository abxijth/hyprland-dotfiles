#!/usr/bin/env bash
# Dotfiles Installer for Hyprland Wayland Desktop
# Run on a fresh Arch Linux minimal install
# Usage: curl -fsSL https://raw.githubusercontent.com/<user>/dotfiles/main/install.sh | bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; }
info() { echo -e "${BLUE}[i]${NC} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "Do not run as root. Run as your regular user."
    exit 1
fi

# Check if on Arch Linux
if ! command -v pacman &>/dev/null; then
    error "This script is for Arch Linux only."
    exit 1
fi

log "Starting dotfiles installation..."

# ------------------------------------------
# 1. System update & base packages
# ------------------------------------------
log "Updating system and installing base packages..."
sudo pacman -Syu --noconfirm

# Core packages from pacman
PACMAN_PKGS=(
    # Window manager & compositor
    hyprland hypridle hyprlock hyprpaper
    
    # Wayland utilities
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    qt5-wayland qt6-wayland
    
    # Bar & notifications
    swaync
    
    # Terminal & shell
    kitty zsh
    
    # Application launcher
    rofi-wayland
    
    # File manager & utilities
    yazi fd fzf ripgrep bat eza zoxide
    
    # Clipboard
    wl-clipboard cliphist
    
    # Screenshots
    grim slurp swappy
    
    # Screen recording
    wf-recorder
    
    # Audio
    pipewire pipewire-pulse wireplumber pavucontrol
    gst-plugin-pipewire
    
    # Network
    networkmanager network-manager-applet
    bluez bluez-utils
    
    # Fonts
    ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd noto-fonts noto-fonts-emoji
    
    # Themes & icons
    gtk3 gtk4 libadwaita
    adw-gtk-theme
    
    # Utilities
    brightnessctl playerctl
    polkit-kde-agent
    ufw
    
    # Development
    git base-devel github-cli
    npm
    
    # Browser (optional - zen-browser is AUR)
    firefox
    
    # Misc
    imagemagick jq
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# ------------------------------------------
# 2. AUR packages (yay)
# ------------------------------------------
log "Setting up yay and AUR packages..."
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd -
fi

AUR_PKGS=(
    # Browsers
    zen-browser-bin
    vesktop-bin  # Discord
    
    # Waybar with cava
    waybar-cava-git
    
    # Display manager
    ly
    
    # Terminal file manager themes
    awww  # wallpaper daemon for hyprpaper
    
    # Additional tools
    nwg-look  # GTK theme changer
    grimblast-git  # screenshot tool
    hyprshade-git  # blue light filter
    wlogout  # logout menu
    
    # Themes
    bibata-cursor-theme
)

yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# ------------------------------------------
# 3. Enable system services
# ------------------------------------------
log "Enabling system services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now ly@tty2  # display manager on tty2
sudo systemctl enable --now ufw
sudo ufw enable

# User services
systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user enable --now xdg-desktop-portal-hyprland

# ------------------------------------------
# 4. Install fonts
# ------------------------------------------
log "Installing fonts..."
mkdir -p ~/.local/share/fonts

# JetBrainsMono Nerd Font (already installed via pacman, but ensure)
# CaskaydiaCove Nerd Font (for swaync buttons)
if [[ ! -f ~/.local/share/fonts/CaskaydiaCoveNerdFont-Regular.ttf ]]; then
    info "Downloading CaskaydiaCove Nerd Font..."
    curl -fLo /tmp/CaskaydiaCove.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
    unzip -o /tmp/CaskaydiaCove.zip -d ~/.local/share/fonts/
    fc-cache -fv
fi

# ------------------------------------------
# 5. Deploy config files
# ------------------------------------------
log "Deploying configuration files..."

# Backup existing configs
backup_dir=~/.config.backup.$(date +%Y%m%d_%H%M%S)
mkdir -p "$backup_dir"
for dir in hypr waybar rofi kitty swaync cava; do
    [[ -d ~/.config/$dir ]] && mv ~/.config/$dir "$backup_dir/"
done
info "Backed up existing configs to $backup_dir"

# Copy new configs
mkdir -p ~/.config
cp -r "$DOTFILES_DIR/hypr" ~/.config/
cp -r "$DOTFILES_DIR/waybar" ~/.config/
cp -r "$DOTFILES_DIR/rofi" ~/.config/
cp -r "$DOTFILES_DIR/kitty" ~/.config/
cp -r "$DOTFILES_DIR/swaync" ~/.config/
cp -r "$DOTFILES_DIR/cava" ~/.config/ 2>/dev/null || true

# Scripts
mkdir -p ~/.local/bin
cp -r "$DOTFILES_DIR/scripts"/* ~/.local/bin/ 2>/dev/null || true
chmod +x ~/.local/bin/* 2>/dev/null || true

# ------------------------------------------
# 6. GTK Theme setup
# ------------------------------------------
log "Configuring GTK themes..."
# Use adw-gtk3 theme (matches catppuccin)
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11' 2>/dev/null || true

# Force GTK4 to use the theme
mkdir -p ~/.config/gtk-4.0
ln -sfn /usr/share/themes/adw-gtk3-dark/gtk-4.0/assets ~/.config/gtk-4.0/assets 2>/dev/null || true
ln -sfn /usr/share/themes/adw-gtk3-dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css 2>/dev/null || true
ln -sfn /usr/share/themes/adw-gtk3-dark/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css 2>/dev/null || true

# GTK3 settings
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=JetBrainsMono Nerd Font 11
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

# ------------------------------------------
# 7. Shell setup (zsh)
# ------------------------------------------
log "Setting up zsh..."
if [[ "$SHELL" != */zsh ]]; then
    chsh -s "$(which zsh)"
    info "Default shell changed to zsh. Log out and back in to take effect."
fi

# ------------------------------------------
# 8. Set up wallpaper
# ------------------------------------------
log "Setting up wallpaper..."
mkdir -p ~/Pictures/Wallpapers
# Download a default catppuccin wallpaper if none exists
if [[ ! -f ~/Pictures/Wallpapers/wallpaper.jpg ]]; then
    curl -fLo ~/Pictures/Wallpapers/wallpaper.jpg \
        "https://github.com/catppuccin/wallpapers/raw/main/1920x1080/mocha/1920x1080_catppuccin_mocha_1.png" 2>/dev/null || true
fi

# ------------------------------------------
# 9. Apply Hyprland config (reload if running)
# ------------------------------------------
if command -v hyprctl &>/dev/null && hyprctl instances -j 2>/dev/null | grep -q .; then
    log "Reloading Hyprland config..."
    hyprctl reload
fi

# ------------------------------------------
# 10. Final steps
# ------------------------------------------
log "Installation complete!"
echo
info "=== NEXT STEPS ==="
echo "1. Reboot your system: sudo reboot"
echo "2. Log in via ly display manager"
echo "3. Press SUPER+Q to open terminal (kitty)"
echo "4. Press SUPER+SPACE for app launcher (rofi)"
echo "5. Press SUPER+E for file manager (yazi)"
echo "6. Press SUPER+W for browser (zen-browser)"
echo
info "Key bindings:"
echo "  SUPER + Q          - Terminal"
echo "  SUPER + E          - File manager (yazi)"
echo "  SUPER + W          - Browser"
echo "  SUPER + SPACE      - App launcher"
echo "  SUPER + 1-0        - Switch workspace"
echo "  SUPER + SHIFT + 1-0 - Move window to workspace"
echo "  SUPER + V          - Toggle float"
echo "  SUPER + SHIFT + R  - Resize mode (HJKL to resize, ESC to exit)"
echo "  SUPER + G          - Toggle window grouping"
echo "  SUPER + TAB        - Previous workspace"
echo "  SUPER + ALT + arrows - Swap windows"
echo "  SUPER + SHIFT + S  - Screenshot area"
echo "  SUPER + SHIFT + W  - Screenshot window"
echo
info "Config location: ~/.config/hypr/, ~/.config/waybar/, etc."
info "To customize: edit files in ~/.config/ and run 'hyprctl reload'"
echo
warn "IMPORTANT: Reboot to ensure all services start correctly!"