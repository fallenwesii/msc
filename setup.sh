#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Initial Setup ---
clear

show_header() {
  if command -v gum &>/dev/null; then
    gum style \
      --foreground 82 --border-foreground 82 --border double \
      --align center --width 50 --margin "1 2" --padding "2 4" \
      "minimal6 dotfiles" "Setup Wizard"
  else
    echo -e "${BLUE}"
    echo ""
    echo -e "${NC}"
  fi
}

show_header

# --- Package Lists ---
PACMAN_PKGS=(
  "swayidle" "gtklock" "gammastep"
  "xdg-desktop-portal-wlr" "waybar" "dunst" "wofi" "nwg-look"
  "fzf" "gum" "figlet" "grim" "slurp" "wl-clipboard" "cliphist"
  "brightnessctl" "pavucontrol" "polkit-gnome" "gvfs" "tuned" "jq"
  "xdg-utils" "git" "libnotify" "psmisc" "procps-ng" "iproute2"
  "pipewire" "wireplumber" "blueman" "bluez" "bluez-utils"
  "kitty" "alacritty" "nautilus" "yazi" "btop"
  "ttf-jetbrains-mono-nerd" "noto-fonts" "qt5-wayland" "qt5ct" "qt6ct"
  "networkmanager" "network-manager-applet" "base-devel" "xorg-xhost" "quickshell"
  "neovim" "kvantum" "ghostty" "awww"
  "python3" "python-pyfiglet" "matugen" "autotiling"
)

AUR_PKGS=(
  "swayfx"
  "wlogout" "wofi-emoji" "brave-bin" "nm-connection-editor"
  "bibata-cursor-theme"
)

# --- 2. Check for Build Tools and AUR Helper ---
echo -e "${YELLOW}Checking for build tools...${NC}"

check_package() {
  pacman -Qi "$1" &>/dev/null
}

install_if_missing() {
  local pkg=$1
  if ! check_package "$pkg"; then
    echo -n "Installing $pkg "
    sudo pacman -S --noconfirm "$pkg" &>/dev/null
    echo -e "${GREEN}*********.......... Done${NC}"
  else
    echo -e "${BLUE}$pkg is already installed.${NC}"
  fi
}

# Essential build tools for starting
# We need base-devel and git first
for tool in base-devel git; do
  install_if_missing "$tool"
done

# Check for AUR helper (yay)
if ! command -v yay &>/dev/null; then
  echo -e "${YELLOW}yay not found. Installing yay...${NC}"
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  cd /tmp/yay-bin || exit
  makepkg -si --noconfirm &>/dev/null
  cd - || exit
  echo -e "${GREEN}yay installed successfully.${NC}"
else
  echo -e "${BLUE}yay is already installed.${NC}"
fi

# Warning for important components
if ! command -v sddm &>/dev/null && ! command -v gdm &>/dev/null && ! command -v ly &>/dev/null; then
  echo -e "${RED}Warning: No Login Manager (SDDM/GDM/LY) detected.${NC}"
  echo -e "${YELLOW}Minimal6 installs only the required packages but a login manager is recommended for a seamless experience.${NC}"
  sleep 2
fi

# --- 3. Terms and Conditions ---
echo -e "\v"
echo -e "Wait! i almost forgot, i have realised you haven't read the terms and conditions 😂 "
sleep 5
clear
echo -e "\v\v\t\t${NC}Terms and conditions${NC} "
echo -e "\tAs a condition of using minimal6 dotfiles you agree to: "
echo -e "\t1. Tell everyone that you use linux"
echo -e "\t2. Hate windows 11 as much as you can"
echo -e "\v\v\v\v\v\v\v"
echo -e "\v\v\v\v"
echo -e "\v\v\v"
sleep 5

# --- 4. Installation Block ---
echo -e "${BLUE}Starting installation of dependencies...${NC}"

# Install Pacman packages
for pkg in "${PACMAN_PKGS[@]}"; do
  if ! check_package "$pkg"; then
    echo -e "${BLUE}Installing pacman package: $pkg${NC}"
    sudo pacman -S --noconfirm "$pkg"
  else
    echo -e "${GREEN}$pkg is already installed.${NC}"
  fi
done

# Install AUR packages
for pkg in "${AUR_PKGS[@]}"; do
  if ! yay -Qi "$pkg" &>/dev/null; then
    echo -e "${YELLOW}Installing AUR package: $pkg${NC}"
    yay -S --noconfirm "$pkg"
  else
    echo -e "${GREEN}$pkg (AUR) is already installed.${NC}"
  fi
done

# Optional: libadwaita-without-adwaita (allows theming of libadwaita apps)
if ! yay -Qi libadwaita-without-adwaita &>/dev/null; then
  echo -e "${YELLOW}libadwaita-without-adwaita allows proper theming of GNOME/libadwaita apps.${NC}"
  read -p "Install libadwaita-without-adwaita? (y/n): " install_libadwaita
  if [[ "$install_libadwaita" == "y" || "$install_libadwaita" == "Y" ]]; then
    yay -S --noconfirm libadwaita-without-adwaita
  else
    echo -e "${BLUE}Skipping libadwaita-without-adwaita.${NC}"
  fi
else
  echo -e "${GREEN}libadwaita-without-adwaita is already installed.${NC}"
fi

# --- 5. Make all scripts executable ---
echo -e "${YELLOW}Making scripts executable...${NC}"
find . -name "*.sh" -exec chmod +x {} +

# --- 6. Configuration & Symlinking ---
DOTFILES_DIR=$(pwd)
CONF_DIR="$HOME/.config"
mkdir -p "$HOME/.local/bin"

confirm_and_link() {
  local source=$1
  local target=$2
  local name=$3

  if [[ -e "$target" || -L "$target" ]]; then
    echo -e "${YELLOW}An existing configuration for $name was found.${NC}"
    read -p "Do you want to replace it? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      local link_dest
      link_dest=$(readlink -f "$target" 2>/dev/null || true)
      local real_source
      real_source=$(readlink -f "$source" 2>/dev/null || true)

      if [[ -L "$target" && ("$link_dest" == "$real_source" || "$link_dest" == "$DOTFILES_DIR"*) ]]; then
        echo "Updating symlink for $name (points to dotfiles)..."
        rm -rf "$target"
        ln -sf "$source" "$target"
      else
        echo "Backing up existing $name..."
        mv "$target" "${target}.bak_$(date +%Y%m%d_%H%M%S)"
        ln -sf "$source" "$target"
      fi
      echo -e "${GREEN}Linked $name${NC}"
    else
      echo "Skipping $name"
    fi
  else
    ln -sf "$source" "$target"
    echo -e "${GREEN}Linked $name${NC}"
  fi
}

confirm_and_copy() {
  local source=$1
  local target=$2
  local name=$3

  if [[ -e "$target" || -L "$target" ]]; then
    echo -e "${YELLOW}An existing file/directory for $name was found.${NC}"
    read -p "Do you want to replace it? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      echo "Backing up existing $name..."
      mv "$target" "${target}.bak_$(date +%Y%m%d_%H%M%S)"
      cp -r "$source" "$target"
      echo -e "${GREEN}Copied $name${NC}"
    else
      echo "Skipping $name"
    fi
  else
    cp -r "$source" "$target"
    echo -e "${GREEN}Copied $name${NC}"
  fi
}

# Link config directories
for dir in "$DOTFILES_DIR/config"/*; do
  dir_name=$(basename "$dir")
  confirm_and_link "$dir" "$CONF_DIR/$dir_name" "$dir_name"
done

# Handle special files/dirs
confirm_and_link "$DOTFILES_DIR/.themes" "$HOME/.themes" ".themes"
confirm_and_link "$DOTFILES_DIR/.icons" "$HOME/.icons" ".icons"

# .bashrc does not work with symlinks: copy instead
confirm_and_copy "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc" ".bashrc"

# Kvantum themes
if command -v kvantummanager &>/dev/null; then
  confirm_and_link "$DOTFILES_DIR/kvantum-themes" "$HOME/.config/Kvantum" "kvantum-themes"
fi

# --- 7. Paths and Assets ---
echo -e "${YELLOW}Setting up scripts and wallpapers...${NC}"

# net-speed.sh does not work with symlinks: copy instead
if [ -f "$HOME/.local/bin/net-speed.sh" ]; then
  read -p "Overwrite existing ~/.local/bin/net-speed.sh? (y/n): " choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    cp "$DOTFILES_DIR/net-speed.sh" "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/net-speed.sh"
    echo -e "${GREEN}Updated net-speed.sh${NC}"
  else
    echo "Skipping net-speed.sh"
  fi
else
  cp "$DOTFILES_DIR/net-speed.sh" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/net-speed.sh"
  echo -e "${GREEN}Installed net-speed.sh${NC}"
fi

# --- 8. Resolve Hardcoded Paths ---
# Fix hardcoded paths for the current user in configs
echo -e "${YELLOW}Resolving hardcoded paths for your system...${NC}"

sed_inplace() {
  sed -i "$1" "$2"
}

# -- gtk-3.0/bookmarks --
BOOKMARKS="$CONF_DIR/gtk-3.0/bookmarks"
if [ -f "$BOOKMARKS" ] || [ -L "$BOOKMARKS" ]; then
  REAL_BOOKMARKS=$(realpath "$BOOKMARKS" 2>/dev/null || echo "$BOOKMARKS")
  sed_inplace "s|__HOME__|$HOME|g" "$REAL_BOOKMARKS"
  sed_inplace "s|/home/[a-zA-Z0-9_-]*|$HOME|g" "$REAL_BOOKMARKS"
  echo -e "${GREEN}Fixed paths in gtk-3.0/bookmarks${NC}"
fi

# -- quickshell/shell.qml --
SHELL_QML="$CONF_DIR/quickshell/shell.qml"
if [ -f "$SHELL_QML" ] || [ -L "$SHELL_QML" ]; then
  REAL_SHELL=$(realpath "$SHELL_QML" 2>/dev/null || echo "$SHELL_QML")
  sed_inplace "s|__HOME__|$HOME|g" "$REAL_SHELL"
  sed_inplace "s|/home/[a-zA-Z0-9_-]*/.config/quickshell|$HOME/.config/quickshell|g" "$REAL_SHELL"
  echo -e "${GREEN}Fixed paths in quickshell/shell.qml${NC}"
fi

# -- gtklock colors and config --
GTKLOCK_COLORS="$CONF_DIR/gtklock/colors.css"
if [ -f "$GTKLOCK_COLORS" ] || [ -L "$GTKLOCK_COLORS" ]; then
  REAL_GL_COLORS=$(realpath "$GTKLOCK_COLORS" 2>/dev/null || echo "$GTKLOCK_COLORS")
  sed_inplace "s|/home/[a-zA-Z0-9_-]*/Pictures/wallpapers|$HOME/Pictures/wallpapers|g" "$REAL_GL_COLORS"
  echo -e "${GREEN}Fixed wallpaper path in gtklock/colors.css${NC}"
fi

GTKLOCK_CONF="$CONF_DIR/gtklock/config.ini"
if [ -f "$GTKLOCK_CONF" ] || [ -L "$GTKLOCK_CONF" ]; then
  REAL_GL_CONF=$(realpath "$GTKLOCK_CONF" 2>/dev/null || echo "$GTKLOCK_CONF")
  sed_inplace "s|/home/[a-zA-Z0-9_-]*/.config/gtklock|$HOME/.config/gtklock|g" "$REAL_GL_CONF"
  echo -e "${GREEN}Fixed style path in gtklock/config.ini${NC}"
fi

# -- sway/palette.conf --
SWAY_PALETTE="$CONF_DIR/sway/palette.conf"
if [ -f "$SWAY_PALETTE" ] || [ -L "$SWAY_PALETTE" ]; then
  REAL_PALETTE=$(realpath "$SWAY_PALETTE" 2>/dev/null || echo "$SWAY_PALETTE")
  sed_inplace "s|/home/[a-zA-Z0-9_-]*/Pictures/wallpapers|$HOME/Pictures/wallpapers|g" "$REAL_PALETTE"
  echo -e "${GREEN}Fixed \$image path in sway/palette.conf${NC}"
fi

# -- wofi/style.css --
WOI_CSS="$CONF_DIR/wofi/style.css"
ABS_PATH="$HOME/.config/wofi/colors.css"
if [ -f "$WOI_CSS" ] || [ -L "$WOI_CSS" ]; then
  REAL_WOI=$(realpath "$WOI_CSS" 2>/dev/null || echo "$WOI_CSS")
  sed_inplace "s|/home/[a-zA-Z0-9_-]*/.config/wofi/colors.css|$ABS_PATH|g" "$REAL_WOI"
  echo -e "${GREEN}Fixed @import path in wofi/style.css to $ABS_PATH${NC}"
fi

# -- GTK symlinks: Recreate gtk-4.0 and gtk-3.0 symlinks --
echo -e "${YELLOW}Recreating GTK theme symlinks...${NC}"
ADW_GTK4="$HOME/.themes/adw-gtk3-dark/gtk-4.0"
ADW_GTK3="$HOME/.themes/adw-gtk3-dark/gtk-3.0"
GTK4_CONF="$CONF_DIR/gtk-4.0"
GTK3_CONF="$CONF_DIR/gtk-3.0"

if [ -d "$HOME/.themes/adw-gtk3-dark" ]; then
  # Symlink ~/.themes/adw-gtk3-dark/gtk-4.0 to ~/.config/gtk-4.0
  rm -rf "$GTK4_CONF"
  ln -sf "$ADW_GTK4" "$GTK4_CONF"
  echo -e "  ${GREEN}Linked gtk-4.0 directory${NC}"

  # gtk-3.0/colors.css symlink
  GTK3_COLORS="$GTK3_CONF/colors.css"
  THEME_GTK3_COLORS="$ADW_GTK3/colors.css"
  if [ -e "$THEME_GTK3_COLORS" ]; then
    rm -f "$GTK3_COLORS"
    ln -sf "$THEME_GTK3_COLORS" "$GTK3_COLORS"
    echo -e "  ${GREEN}Linked gtk-3.0/colors.css${NC}"
  fi
else
  echo -e "  ${YELLOW}~/.themes/adw-gtk3-dark not found yet — GTK symlinks will be created after theme setup.${NC}"
fi

echo -e "${GREEN}Hardcoded path resolution complete.${NC}"

# --- 9. Wallpapers ---
echo -e "${YELLOW}Setting up wallpapers...${NC}"
WALLPAPERS_DEST="$HOME/Pictures/wallpapers"

if [ -d "$WALLPAPERS_DEST" ]; then
  echo -e "${YELLOW}A wallpapers directory already exists at $WALLPAPERS_DEST.${NC}"
  echo -e "${YELLOW}This setup will NOT overwriting your existing wallpapers .${NC}"
  echo ""
  read -p "Would you like to back it up first before adding new wallpapers? (y/n): " backup_choice
  if [[ "$backup_choice" == "y" || "$backup_choice" == "Y" ]]; then
    BACKUP_PATH="${WALLPAPERS_DEST}.bak_$(date +%Y%m%d_%H%M%S)"
    cp -r "$WALLPAPERS_DEST" "$BACKUP_PATH"
    echo -e "${GREEN}Backed up your wallpapers to: $BACKUP_PATH${NC}"
    echo ""
    read -p "Now copy new wallpapers from dotfiles into $WALLPAPERS_DEST? (y/n): " copy_choice
    if [[ "$copy_choice" == "y" || "$copy_choice" == "Y" ]]; then
      mkdir -p "$WALLPAPERS_DEST"
      cp "$DOTFILES_DIR/wallpapers/"* "$WALLPAPERS_DEST/" 2>/dev/null
      echo -e "${GREEN}Copied new wallpapers into $WALLPAPERS_DEST${NC}"
    else
      echo -e "${BLUE}Skipping wallpaper copy. Your existing wallpapers are untouched.${NC}"
    fi
  else
    echo -e "${BLUE}Skipping wallpaper setup. Your existing wallpapers are safe.${NC}"
  fi
else
  mkdir -p "$WALLPAPERS_DEST"
  cp "$DOTFILES_DIR/wallpapers/"* "$WALLPAPERS_DEST/"
  echo -e "${GREEN}Wallpapers installed to $WALLPAPERS_DEST${NC}"
fi

# --- 10. Final Verification ---
echo -e "${YELLOW}Verifying important Sway packages...${NC}"
SWAY_PKGS=("swayfx" "swayidle" "gtklock" "waybar")
for pkg in "${SWAY_PKGS[@]}"; do
  if ! check_package "$pkg" && ! yay -Qi "$pkg" &>/dev/null; then
    echo -e "${RED}$pkg is missing! Attempting to install...${NC}"
    if [[ "$pkg" == "swayfx" ]]; then
      yay -S --noconfirm "$pkg"
    else
      sudo pacman -S --noconfirm "$pkg"
    fi
  fi
done

# --- 11. Setting up themes ---
echo -e "${YELLOW}Setting up themes...${NC}"
read -p "Apply adw-gtk3 theme and generate dynamic colors with matugen? (y/n): " setup_themes
if [[ "$setup_themes" == "y" || "$setup_themes" == "Y" ]]; then

  # Flatpak theming
  if command -v flatpak &>/dev/null; then
    echo -e "${YELLOW}Allowing Flatpak apps to access themes, icons, and GTK 4.0 configuration...${NC}"
    flatpak override --user --filesystem="$HOME"/.themes
    flatpak override --user --filesystem="$HOME"/.icons
    flatpak override --user --filesystem="$HOME"/.config/gtk-4.0
    echo -e "${GREEN}Flatpak apps can now access themes, icons, and GTK 4.0 configuration.${NC}"
  fi

  # Set adw-gtk3 theme and icons via gsettings
  echo -e "${BLUE}Applying adw-gtk3-dark theme and FairyWren_adwaita_Dark icons via gsettings...${NC}"
  gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
  gsettings set org.gnome.desktop.interface icon-theme "FairyWren_adwaita_Dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  echo -e "${GREEN}adw-gtk3-dark theme and FairyWren_adwaita_Dark icons applied.${NC}"

  # Run matugen for dynamic coloring
  MATUGEN_WALLPAPER="$HOME/Pictures/wallpapers/building.png"
  if [ -f "$MATUGEN_WALLPAPER" ]; then
    echo -e "${BLUE}Generating dynamic colors with matugen...${NC}"
    matugen -m dark image "$MATUGEN_WALLPAPER" --source-color-index 0
    echo -e "${GREEN}Dynamic colors applied via matugen.${NC}"

    # Re-run GTK symlinks now that .themes is in place and matugen has written colors
    echo -e "${BLUE}Re-linking GTK theme files...${NC}"
    ADW_GTK4="$HOME/.themes/adw-gtk3-dark/gtk-4.0"
    ADW_GTK3="$HOME/.themes/adw-gtk3-dark/gtk-3.0"
    GTK4_CONF="$CONF_DIR/gtk-4.0"
    GTK3_CONF="$CONF_DIR/gtk-3.0"
    mkdir -p "$GTK4_CONF" "$GTK3_CONF"
    if [ -d "$HOME/.themes/adw-gtk3-dark" ]; then
      rm -rf "$GTK4_CONF"
      ln -sf "$ADW_GTK4" "$GTK4_CONF"
      if [ -e "$ADW_GTK3/colors.css" ]; then
        rm -f "$GTK3_CONF/colors.css"
        ln -sf "$ADW_GTK3/colors.css" "$GTK3_CONF/colors.css"
      fi
      echo -e "${GREEN}GTK theme symlinks updated.${NC}"
    fi
  else
    echo -e "${YELLOW}Warning: $MATUGEN_WALLPAPER not found.${NC}"
    echo -e "${YELLOW}You can run matugen manually with: matugen -m dark image <path-to-wallpaper> --source-color-index 0${NC}"
    sleep 8
  fi

else
  echo -e "${BLUE}Skipping theme setup.${NC}"
fi

# --- 12. QT/Kvantum Environment configuration ---
echo -e "${YELLOW}Setting up QT/Kvantum environment...${NC}"
mkdir -p "$HOME/.config/environment.d"
QT_CONF="$HOME/.config/environment.d/10-qt.conf"
if [ -f "$QT_CONF" ]; then
  # Remove existing wayland/qt6ct lines if any to avoid duplication
  sed -i '/QT_QPA_PLATFORM=/d' "$QT_CONF"
  sed -i '/QT_QPA_PLATFORMTHEME=/d' "$QT_CONF"
fi
echo "QT_QPA_PLATFORM=wayland" >>"$QT_CONF"
echo "QT_QPA_PLATFORMTHEME=qt6ct" >>"$QT_CONF"
systemctl --user daemon-reload
echo -e "${GREEN}QT/Kvantum environment configured and systemd user manager reloaded.\nA reboot is recommended for Qt/Kvantum theming${NC}"

# --- 13. Final Message ---
clear
show_header
if command -v gum &>/dev/null; then
  gum style --foreground 82 --border-foreground 82 --border normal --align center --width 50 \
    "Setup Complete!" "Press Super + H for Keybinds Help"
else
  echo -e "${GREEN}Setup Complete!${NC}"
  echo -e "${YELLOW}Press Super + H for Keybinds Help${NC}"
fi
