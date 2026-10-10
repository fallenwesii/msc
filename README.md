# msc

My swayfx configuration(msc).
This is a port of my [minimal6](https://github.com/fallenwesii/minimal6) dotfiles to sway(swayfx), so if you value eye candy with flashy animation, it's worth checking it out.

## ✨ Features

- Dynamic wallpaper-based theming
- wallpaper switcher
- GTK3, GTK4, Qt5, Qt6 & Kvantum support
- Waybar integration
- Wofi launcher 
- Swaync notifications
- Terminal theming
- Consistent desktop styling
- System wide blur via a toggle
- Automatic theme reload
- Fast installation

## Screenshots

 ![msc](/screenshots/desktop.png)

## Setup

```bash
git clone https://github.com/fallenwesii/msc.git
cd msc
chmod +x setup.sh && ./setup.sh
```

Installs packages (pacman + AUR), links configs, applies wallpaper and generates colors based on matugen .

## Uninstall

To undo the symlinks, scripts, and theme overrides set up by msc (without uninstalling any applications):

```bash
./uninstall.sh
```

## Keybinds

 `Super + H`  to view all keybindings.   
