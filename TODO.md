# SwayFX Dotfiles (~/msc) vs Hyprland Dotfiles (~/minimal6) - Full Comparison

## Root-Level Files

| File/Directory | ~/minimal6 (Hyprland) | ~/msc (SwayFX) | Status |
|----------------|----------------------|----------------|--------|
| `setup.sh` | ✅ Full installer (676 lines) | ✅ Sway installer (450 lines) | Both exist, different |
| `update.sh` | ✅ `git pull && ./setup.sh` | ❌ Missing | Need to add |
| `uninstall.sh` | ✅ Full uninstaller (142 lines) | ❌ Missing | Need to add |
| `minimal6` | ✅ Python quick settings (29KB) | ❌ Missing | Need to adapt/create |
| `net-speed.sh` | ✅ Network speed script | ✅ Same | OK |
| `packages.md` | ✅ Hyprland packages | ✅ Updated for Sway | OK |
| `README.md` | ✅ | ✅ | OK |
| `LICENSE` | ✅ | ✅ | OK |
| `.gitignore` | ✅ | ❌ Missing | Need to add |
| `.gitattributes` | ✅ | ✅ | OK |
| `.bashrc` | ✅ | ✅ | OK |
| `wallpapers/` | ✅ | ✅ | OK |
| `screenshots/` | ✅ | ✅ | OK |
| `.themes/` | ✅ | ✅ | OK |
| `.icons/` | ❌ | ✅ | msc has, minimal6 doesn't |
| `kvantum-themes/` | ✅ | ✅ | OK |
| `theme-fix.md` | ✅ | ✅ | OK |
| `SWAYFX_VS_HYPRLAND_COMPARISON.md` | ❌ | ✅ | msc has |
| `TODO.md` | ❌ | ✅ | msc has |

## Config Directories Comparison

### minimal6 has, msc missing:
- `gtk-3.0/` - GTK3 theme config (bookmarks, etc.)
- `gtk-4.0/` - GTK4 theme config
- `hypr/` - Hyprland config (complete)
- `gsimplecal/` - Calendar config

### msc has, minimal6 missing:
- `dunst/` - Dunst config (now removed, using swaync)
- `gtklock/` - GTKLock config
- `Kvantum/` - Kvantum theme config
- `sway/` - SwayFX config (modular, complete)
- `swaync/` - SwayNC config

### Both have:
- `alacritty/`, `btop/`, `cava/`, `ghostty/`, `kitty/`, `matugen/`, `nvim/`, `quickshell/`, `waybar/`, `wlogout/`, `wofi/`

## Setup.sh Differences (Critical)

### minimal6 setup.sh does (not in msc):
1. **Monitor auto-detection** - Python script detects monitors, generates `hypr/conf/monitors.conf`
2. **Icon theme download** - Downloads/installs FairyWren icons from GitHub releases
3. **Flatpak theming** - Configures flatpak filesystem overrides
4. **GTK symlinks** - Links `~/.themes/adw-gtk3-dark/gtk-4.0` → `~/.config/gtk-4.0`
5. **Path resolution** - Fixes hardcoded paths in:
   - `hypr/colors.conf` (wallpaper path)
   - `quickshell/shell.qml`
   - `wofi/style.css` (@import)
   - `wlogout/style.css` (icon paths)
6. **Tuned service** - Enables tuned, creates sudoers rule for passwordless `tuned-adm`
7. **Minimal6 binary** - Installs `~/.local/bin/minimal6` (quick settings)

### msc setup.sh does (not in minimal6):
1. **QT environment** - Creates `~/.config/environment.d/10-qt.conf` with `QT_QPA_PLATFORM=wayland`, `QT_QPA_PLATFORMTHEME=qt6ct`
2. **Different path fixes** - Fixes `gtklock/config.ini`, `sway/palette.conf`, `gtk-3.0/bookmarks`
3. **No monitor detection** - Sway doesn't need monitor config in dotfiles (handled by sway config)
4. **No icon theme download** - Assumes icons already present
5. **No flatpak theming in setup** (but has in theme setup section)

## Packages Differences

### minimal6 (Hyprland) - PACMAN:
```
hyprland hypridle hyprlock hyprsunset gammastep
xdg-desktop-portal-hyprland waybar wofi nwg-look
fzf gum figlet grim slurp wl-clipboard cliphist
brightnessctl pavucontrol polkit-gnome gvfs tuned jq
xdg-utils git libnotify psmisc procps-ng iproute2
pipewire wireplumber blueman bluez bluez-utils
kitty alacritty nautilus yazi btop
ttf-jetbrains-mono-nerd noto-fonts qt5-wayland qt5ct qt6ct
networkmanager base-devel xorg-xhost gamemode quickshell
neovim kvantum ghostty awww
python3 python-pyfiglet matugen
gsimplecal hyprpicker swaync
```

### msc (SwayFX) - PACMAN:
```
swayidle gtklock gammastep
xdg-desktop-portal-wlr waybar dunst wofi nwg-look
fzf gum figlet grim slurp wl-clipboard cliphist
brightnessctl pavucontrol polkit-gnome gvfs tuned jq
xdg-utils git libnotify psmisc procps-ng iproute2
pipewire wireplumber blueman bluez bluez-utils
kitty alacritty nautilus yazi btop
ttf-jetbrains-mono-nerd noto-fonts qt5-wayland qt5ct qt6ct
networkmanager network-manager-applet base-devel xorg-xhost quickshell
neovim kvantum ghostty awww
python3 python-pyfiglet matugen autotiling
```

### AUR (both similar):
```
minimal6: wlogout wofi-emoji brave-bin nm-connection-editor bibata-cursor-theme
msc:      swayfx wlogout wofi-emoji brave-bin nm-connection-editor bibata-cursor-theme
```

### Missing in msc packages:
- `gum` (for UI in setup)
- `hyprpicker` (color picker - hyprland specific)
- `swaync` (added recently)
- `gsimplecal` (added recently)
- `xorg-xhost` (for root apps)
- `gamemode` (gaming optimization)

## Scripts Differences

### minimal6 scripts (not in msc):
- `toggle-compact.sh` - Toggles compact mode (no borders/gaps/rounding)
- `toggle-grayscale.sh` - Toggles grayscale filter

### msc scripts (not in minimal6):
- `reload-config.sh` - Comprehensive reload (added)
- `scratchpad-toggle.sh` - Ghostty scratchpad toggle (added)
- `light-mode.sh` - Ported from hyprland (added)
- `media-idle.sh` - Ported from hyprland (added)
- `toggle-compact.sh` ❌ MISSING
- `toggle-grayscale.sh` ❌ MISSING

### Different implementations:
- `wallpaper-switcher.sh` - msc has optimized version (hyprland's improvements ported)
- `help.sh` - Different (msc 5KB vs minimal6 6KB)
- `notifications.sh` - Different (msc opens kitty, minimal6 uses swaync-client)
- `brightness.sh` - Same
- `centered-floating-window.sh` - Different (msc 1KB vs minimal6 234B)
- `clipboard.sh` - Different
- `toggle-waybar.sh` - Same

## What Needs to Be Done for Full Parity

### High Priority (Setup/Install):
1. [ ] Add `update.sh` (simple: `git pull && ./setup.sh`)
2. [ ] Add `uninstall.sh` (adapt for sway: remove sway configs, gtklock, etc.)
3. [ ] Add `.gitignore` (copy from minimal6)
4. [ ] Add `gum`, `xorg-xhost`, `gamemode` to packages.md and setup.sh
5. [ ] Add `gsimplecal`, `swaync` to setup.sh PACMAN_PKGS (already in packages.md)

### High Priority (Setup.sh Features):
6. [ ] Add **monitor detection** to msc setup.sh (optional for sway, but good for docs)
7. [ ] Add **icon theme download** (FairyWren icons)
8. [ ] Add **flatpak theming** section
9. [ ] Add **GTK symlinks** (`~/.themes/adw-gtk3-dark/gtk-4.0` → `~/.config/gtk-4.0`)
10. [ ] Add **path resolution** for sway configs (palette.conf, gtklock, etc.)
11. [ ] Add **tuned service** setup + sudoers rule
12. [ ] Create **minimal6 quick settings binary** equivalent for sway

### Medium Priority (Scripts):
13. [ ] Create `toggle-compact.sh` for sway
14. [ ] Create `toggle-grayscale.sh` for sway (use wlr-randr or shader?)
15. [ ] Improve `help.sh` to match hyprland features
16. [ ] Improve `notifications.sh` to use swaync-client

### Medium Priority (Config Parity):
17. [ ] Add missing window rules (15+ from hyprland)
18. [ ] Add `misc.conf` with mouse scroll_factor
19. [ ] Add `monitors.conf` template (even if not auto-generated)
20. [ ] Sync appearance settings (gaps, borders, rounding, shadows)
21. [ ] Add cursor theme, QT theme env vars
22. [ ] Add nautilus preload to startup
23. [ ] Add follow_mouse=1 equivalent

### Low Priority:
24. [ ] Create `minimal6` equivalent (quick settings TUI)
25. [ ] Document sway-specific differences
26. [ ] Test multi-monitor

## Already Done ✅
- [x] Modular config structure (conf/)
- [x] Webapp keybinds (Perplexity, ChatGPT, Claude)
- [x] Zoom workaround (output scale)
- [x] Scratchpad toggle script
- [x] Wallpaper switcher (hyprland optimizations ported)
- [x] swaync implementation (config, style, matugen)
- [x] Waybar ported to sway modules
- [x] Battery watcher script
- [x] gsimplecal window rule
- [x] Comprehensive reload script (`$mod+Ctrl+r`)
- [x] light-mode.sh toggle
- [x] media-idle.sh (video-aware idle)
- [x] Correct exec vs exec_always in startup.conf
- [x] Packages.md updated (swaync, gsimplecal)
- [x] Notification keybinds use swaync-client
- [x] Notification icon theming in waybar