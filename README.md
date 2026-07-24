# Hyprland Dotfiles

A complete, reproducible Hyprland setup for Arch Linux featuring Catppuccin Mocha theming.

## Screenshots

*Coming soon*

## Features

- **Window Manager**: Hyprland (v0.55+ with Lua config)
- **Bar**: Waybar with Cava visualizer
- **Notifications**: Swaync with control center
- **Launcher**: Rofi (type-2, style-15)
- **Terminal**: Kitty with Catppuccin Mocha
- **File Manager**: Yazi (in Kitty)
- **Browser**: Zen Browser (Wayland native)
- **Lockscreen**: Hyprlock with blur
- **Idle**: Hypridle (dim → lock → dpms → suspend)
- **Theme**: Catppuccin Mocha everywhere

## Quick Install (Fresh Arch)

```bash
# 1. Install base system (if not done)
# pacstrap -K /mnt base linux-zen linux-zen-headers linux-firmware \
#   networkmanager sudo git base-devel vim

# 2. Post-install, as root:
# systemctl enable NetworkManager

# 3. Reboot, login as user, then:
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Manual Package Install

If you prefer to install packages manually:

### Official Repos
```bash
sudo pacman -S hyprland waybar swaync rofi-wayland kitty \
  grim slurp wl-clipboard hypridle hyprlock \
  pipewire wireplumber pipewire-pulse pipewire-alsa \
  pavucontrol brightnessctl playerctl \
  ttf-jetbrains-mono-nerd noto-fonts-emoji \
  polkit-kde-agent xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk uwsm ly \
  yazi zoxide fzf fd bat \
  fastfetch jq resvg \
  wf-recorder cava \
  network-manager-applet blueman \
  cups cups-pk-helper system-config-printer \
  intel-media-driver libva-nvidia-driver \
  power-profiles-daemon smartmontools
```

### AUR (via yay)
```bash
yay -S zen-browser-bin vesktop-bin waybar-cava-git \
  aww hyprshutdown-git \
  ttf-cascadia-code-nerd \
  bibata-cursor-theme \
  themesw-git \
  caffeine-ng \
  mictoggle-git \
  powerprofile-git
```

## Key Bindings

| Key | Action |
|-----|--------|
| `SUPER + Q` | Terminal (Kitty) |
| `SUPER + E` | File Manager (Yazi) |
| `SUPER + W` | Browser (Zen) |
| `SUPER + SPACE` | App Launcher (Rofi) |
| `SUPER + 1-0` | Switch Workspace |
| `SUPER + SHIFT + 1-0` | Move Window to Workspace |
| `SUPER + V` | Toggle Float |
| `SUPER + P` | Toggle Pseudotile |
| `SUPER + SHIFT + R` | Resize Mode (HJKL, ESC to exit) |
| `SUPER + G` | Toggle Window Group |
| `SUPER + TAB` | Previous Workspace |
| `SUPER + ALT + ARROWS` | Swap Windows |
| `SUPER + SHIFT + S` | Screenshot Area |
| `SUPER + SHIFT + W` | Screenshot Window |
| `PRINT` | Screenshot Fullscreen |
| `SUPER + SHIFT + L` | Lock Screen |
| `SUPER + N` | Notification Center |
| `SUPER + C` | Close Window |

## Config Structure

```
~/.config/
├── hypr/
│   ├── hyprland.lua        # Main config (imports modules)
│   ├── hyprlock.conf       # Lock screen
│   ├── hypridle.conf       # Idle actions
│   └── modules/
│       ├── autostart.lua   # Startup apps
│       ├── binds.lua       # Key bindings
│       ├── decorations.lua # Blur, shadows, animations
│       ├── env.lua         # Environment variables
│       ├── input.lua       # Keyboard, touchpad, gestures
│       ├── layout.lua      # Dwindle/Master/Scrolling layouts
│       ├── misc.lua        # Misc settings (swallow, VRR, etc)
│       ├── monitors.lua    # Monitor config
│       └── windowrules.lua # Window & workspace rules
├── waybar/
│   ├── config.jsonc        # Bar config
│   ├── style.css           # Styling
│   └── colors/             # Catppuccin colors
├── rofi/
│   └── type-2/             # Launcher theme
├── kitty/
│   ├── kitty.conf          # Terminal config
│   └── colors/             # Catppuccin theme
├── swaync/
│   ├── config.json         # Notification daemon
│   ├── style.css           # Styling
│   └── colors/             # Catppuccin colors
└── cava/
    └── config              # Audio visualizer
```

## Customization

### Change Wallpaper
Edit `~/.config/hypr/hyprlock.conf` (background section) or use `swww`/`swaybg`.

### Add/Remove Keybinds
Edit `~/.config/hypr/modules/binds.lua`

### Window Rules
Edit `~/.config/hypr/modules/windowrules.lua`

### Waybar Modules
Edit `~/.config/waybar/config.jsonc` and `style.css`

### Colors
All apps use Catppuccin Mocha. Edit color files in respective `colors/` directories.

## Window Swallowing

Enabled by default. When you launch a GUI app from Kitty (e.g., `nvim`, `yazi`), the terminal hides until the app closes.

To exclude an app from swallowing, add to `swallow_exception_regex` in `misc.lua`:
```lua
swallow_exception_regex = "^(wev|htop|myapp)$"
```

## VRR (Variable Refresh Rate)

Enabled for fullscreen only (`vrr = 2`). Change in `misc.lua`:
- `0` = off
- `1` = always
- `2` = fullscreen only (recommended)
- `3` = fullscreen + game/video content

## Auto-Workspace Assignment

Apps auto-assign to workspaces (silent = no focus steal):
- Workspace 1: Terminals (Kitty)
- Workspace 2: Browser (Zen)
- Workspace 5: Chat (Vesktop/Discord)
- Workspace 6: Games (Steam)

Modify in `windowrules.lua`.

## Smart Gaps

Single tiled window = no gaps/borders. Multiple = your configured gaps.

## Troubleshooting

### Hyprland won't start
```bash
# Check logs
journalctl --user -u hyprland -f

# Or run directly for debug
Hyprland
```

### Waybar not showing
```bash
pkill waybar && waybar &
```

### Notifications not working
```bash
pkill swaync && swaync &
```

### Screen sharing not working
Ensure `xdg-desktop-portal-hyprland` is running:
```bash
systemctl --user status xdg-desktop-portal-hyprland
```

### NVIDIA issues
Add to kernel params: `nvidia_drm.modeset=1`
Ensure `nvidia-open-dkms` is installed (not `nvidia`)

## Backup & Restore

```bash
# Backup current config
cp -r ~/.config ~/config-backup-$(date +%Y%m%d)

# Restore from this repo
cd ~/dotfiles
rsync -av .config/ ~/.config/
hyprctl reload
```

## License

MIT - Feel free to use and modify.
