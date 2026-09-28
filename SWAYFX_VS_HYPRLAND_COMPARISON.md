# SwayFX vs Hyprland Dotfiles Comparison

## Config Structure
- **Hyprland** (`~/minimal6`): Modular with `source` includes (11 separate files in `conf/`)
- **SwayFX** (current): Single monolithic `config` file (344 lines)

---

## Keybindings Comparison

| Feature | Hyprland | SwayFX | Notes |
|---------|----------|--------|-------|
| Webapps | Perplexity, ChatGPT, Claude, WhatsApp, Gemini | WhatsApp, Gemini only | Hyprland has 5 webapps |
| Cursor zoom | `Super+Z` / `Super+Shift+Z` | Commented out | Hyprland native zoom |
| Scratchpad | Special workspace `special:term` with `Super+Alt+Return` | Basic `$mod+minus` | Hyprland more robust |
| Notifications | `swaync-client` toggle/DND | Opens in kitty | Hyprland uses swaync |
| Gestures | 3-finger horizontal/up | Same | Parity |
| Layout toggles | `pseudo`, `togglesplit` | `splith`, `splitv`, `stacking`, `tabbed` | Sway has more layout options |

---

## Appearance Settings

| Setting | Hyprland | SwayFX |
|---------|----------|--------|
| Gaps | `in=3, out=11` | `inner=3, outer=0` |
| Border | `size=3` | `pixel=2` |
| Rounding | `9` | `5` |
| Blur | `size=10, passes=4` | `passes=5, radius=8` |
| Shadows | Enabled (range=35, render_power=3) | Disabled (csd only) |
| Dim inactive | N/A | `0.22` |

---

## Startup Applications

**Hyprland:**
- `hypridle` (with config)
- `swaync` notification daemon
- `media-idle.sh` (prevents screenlock during media)
- Nautilus preload (`nautilus --gapplication-service`)
- `xhost +local:root` (fix for root apps)
- `qs -d` (quick settings daemon)
- Polkit agent

**SwayFX:**
- `swayidle` + `gtklock` (locker)
- Duplicate `cliphist` entries (4 lines vs 2)
- `qs -d`
- `awww-daemon` (wallpaper daemon)
- Polkit agent
- Autotiling (`autotiling --limit 2`)

---

## Window Rules

**Hyprland (15+ rules):**
- xwaylandvideobridge fixes
- Notification history (swaync)
- Polkit elevation fix
- XDG portal file choosers (GTK + fallback)
- Center-floating help menu
- Quick settings
- Wallpaper picker (custom border/rounding)
- GNOME Calculator
- Frog OCR
- Pomotroid
- VideoDownloader
- Qalculate-GTK
- Ghostty scratchpad (special workspace)
- Gsimplecal dropdown

**SwayFX (3 rules):**
- Wallpaper picker (floating, centered, sized)
- Sway help (floating, centered, sized)
- Notifications (floating, centered, sized)

---

## Environment & Input

| Setting | Hyprland | SwayFX |
|---------|----------|--------|
| Cursor theme | Bibata-Modern-Classic (24/64) | Not set |
| QT theme | qt6ct | Not set |
| GBM backend | nvidia-drm | Not set |
| XDG session | Hyprland | sway |
| Follow mouse | `1` | Not set |
| Touchpad natural scroll | `false` | `enabled` |
| Touchpad tap | Not set | `enabled` |
| Touchpad dwt | Not set | `enabled` |
| Touchpad middle emulation | Not set | `enabled` |

---

## Scripts (Hyprland has more)

**Extra in Hyprland:**
- `light-mode.sh`
- `media-idle.sh`
- `toggle-compact.sh`
- `toggle-grayscale.sh`

**Shared (both have):**
- `brightness.sh`
- `centered-floating-window.sh`
- `help.sh`
- `notifications.sh`
- `toggle-waybar.sh`
- `wallpaper-switcher.sh` (Hyprland: 15KB, Sway: 13KB)

---

## Waybar
- Both have similar structure: `config.jsonc`, `style.css`, `colors.css`, `scripts/`
- Hyprland config is larger (5045 vs 3908 bytes)

---

## Notes
- SwayFX is a fork of Sway with eye candy (blur, shadows, rounded corners)
- Some Hyprland features don't translate directly to SwayFX
- Hyprland config is more mature and feature-complete
- SwayFX config is behind and missing parity features