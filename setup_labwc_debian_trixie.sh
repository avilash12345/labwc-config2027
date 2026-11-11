#!/usr/bin/env bash
# setup_labwc_debian_trixie.sh
# Generated from /home/debian/.config/labwc and current system state
# Target: Debian GNU/Linux 13 (trixie)

set -euo pipefail

echo "==> Labwc setup script for Debian Trixie"
echo "==> Updating package index..."
sudo apt update

echo "==> Installing required packages..."
sudo apt install -y \
  labwc \
  waybar \
  wofi \
  foot \
  alacritty \
  swaybg \
  swayidle \
  swaylock \
  mako-notifier \
  kanshi \
  wlr-randr \
  wlopm \
  nwg-look \
  arc-theme \
  papirus-icon-theme \
  adwaita-icon-theme \
  gnome-themes-extra \
  lxappearance \
  fonts-cantarell \
  fonts-font-awesome \
  fonts-noto-core \
  fonts-noto-color-emoji \
  xdg-utils \
  xdg-desktop-portal \
  xdg-desktop-portal-wlr \
  dbus-user-session \
  polkitd \
  pkexec \
  libnotify-bin \
  qtwayland5 \
  qt6-wayland \
  xcur2png \
  libgtk-3-bin \
  gir1.2-gtk-3.0 \
  gtk2-engines-murrine \
  gtk2-engines-pixbuf

echo "==> Ensuring theme/icon directories exist..."
mkdir -p "$HOME/.local/share/themes" "$HOME/.themes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/labwc"

echo "==> Applying current GTK settings from gsettings/gtk-3.0..."
GTK_THEME_NAME="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")"
ICON_THEME_NAME="$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")"
CURSOR_THEME_NAME="$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'")"
FONT_NAME="$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null | tr -d "'")"
COLOR_SCHEME="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")"

[ -z "${GTK_THEME_NAME:-}" ] && GTK_THEME_NAME="Arc-Dark"
[ -z "${ICON_THEME_NAME:-}" ] && ICON_THEME_NAME="Slot-Beauty-Dark-Icons-V-2"
[ -z "${CURSOR_THEME_NAME:-}" ] && CURSOR_THEME_NAME="Adwaita"
[ -z "${FONT_NAME:-}" ] && FONT_NAME="Cantarell 11"

echo "    gtk-theme:   $GTK_THEME_NAME"
echo "    icon-theme:  $ICON_THEME_NAME"
echo "    cursor:      $CURSOR_THEME_NAME"
echo "    font:        $FONT_NAME"
echo "    color-scheme: $COLOR_SCHEME"

cat > "$HOME/.config/gtk-3.0/settings.ini" <<INI
[Settings]
gtk-theme-name=$GTK_THEME_NAME
gtk-icon-theme-name=$ICON_THEME_NAME
gtk-font-name=$FONT_NAME
gtk-cursor-theme-name=$CURSOR_THEME_NAME
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
INI

cat > "$HOME/.config/gtk-4.0/settings.ini" <<INI
[Settings]
gtk-theme-name=$GTK_THEME_NAME
gtk-icon-theme-name=$ICON_THEME_NAME
gtk-font-name=$FONT_NAME
gtk-cursor-theme-name=$CURSOR_THEME_NAME
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
INI

echo "==> Applying gsettings..."
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" || true
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME" || true
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME_NAME" || true
gsettings set org.gnome.desktop.interface font-name "$FONT_NAME" || true
if [ "$COLOR_SCHEME" = "'prefer-dark'" ] || [ "$COLOR_SCHEME" = "prefer-dark" ]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
fi

echo "==> Notes:"
echo "  - Autostart uses $HOME/.local/bin/waybar. If missing, use /usr/bin/waybar or create a symlink."
echo "  - labwc Openbox themes go in ~/.local/share/themes/<NAME>/openbox-3/ or ~/.themes/<NAME>/openbox-3/ and set <name> in ~/.config/labwc/rc.xml."
echo "  - GTK4/libadwaita apps may ignore third-party themes; nwg-look/gsettings still affect many apps."
echo "  - Reload with 'labwc --reconfigure'."
echo "==> Done."
