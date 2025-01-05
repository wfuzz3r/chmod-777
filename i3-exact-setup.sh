#!/bin/bash

# Error handling
set -euo pipefail
trap 'echo "Error on line $LINENO. Exit code: $?" >&2; exit 1' ERR

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${GREEN}[+]${NC} $1"
}

error() {
    echo -e "${RED}[!]${NC} $1" >&2
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root"
    exit 1
}

# Backup existing configurations
backup_dir="$HOME/.config/i3_backup_$(date +%Y%m%d_%H%M%S)"
log "Creating backup at $backup_dir"
mkdir -p "$backup_dir"
cp -r "$HOME/.config/i3" "$backup_dir/" 2>/dev/null || true
cp -r "$HOME/.config/polybar" "$backup_dir/" 2>/dev/null || true
cp -r "$HOME/.config/picom" "$backup_dir/" 2>/dev/null || true
cp -r "$HOME/.config/rofi" "$backup_dir/" 2>/dev/null || true

# Install required packages
log "Installing required packages..."
apt-get update
apt-get install -y \
    i3-wm \
    i3lock \
    i3status \
    polybar \
    rofi \
    dunst \
    picom \
    feh \
    pulseaudio \
    network-manager \
    network-manager-gnome \
    blueman \
    volumeicon-alsa \
    parcellite \
    xrandr \
    git \
    wget \
    unzip

# Install JetBrains Mono Nerd Font
log "Installing JetBrains Mono Nerd Font..."
mkdir -p "$HOME/.local/share/fonts"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d "$HOME/.local/share/fonts/"
rm JetBrainsMono.zip
fc-cache -f

# Create required directories
log "Creating configuration directories..."
mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/.config/polybar"
mkdir -p "$HOME/.config/picom"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/Pictures"

# Download Evangelion wallpaper (assuming it's needed)
log "Setting up wallpaper..."
wget -O "$HOME/Pictures/Evangelion.png" "https://yourserver.com/Evangelion.png" || \
    error "Failed to download wallpaper. Please manually place Evangelion.png in ~/Pictures/"

# Create i3 config
log "Creating i3 configuration..."
cat > "$HOME/.config/i3/config" << 'EOL'
# i3 config file
set $mod Mod4

# Font configuration
font pango:JetBrains Mono Nerd Font 10

# Colors
client.focused          #ff0000 #800000 #ffffff #400000 #ff0000
client.focused_inactive #400000 #400000 #ffffff #400000 #400000
client.unfocused       #400000 #400000 #888888 #400000 #400000
client.urgent          #ff0000 #ff0000 #ffffff #ff0000 #ff0000
client.placeholder     #400000 #400000 #ffffff #400000 #400000
client.background      #400000

# Window borders
for_window [class="^.*"] border pixel 2
gaps inner 10
gaps outer 5

# Monitor setup
exec_always --no-startup-id xrandr --output eDP-1 --primary --mode 1366x768 --output HDMI-1 --mode 1366x768 --left-of eDP-1

# Workspaces
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

# Key bindings
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"
bindsym $mod+b split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+space floating toggle

# Volume controls
bindsym F6 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym F7 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym F8 exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle

# Autostart
exec_always --no-startup-id ~/.config/polybar/launch.sh
exec_always --no-startup-id feh --bg-scale ~/Pictures/Evangelion.png
exec_always --no-startup-id picom -b
exec --no-startup-id nm-applet
exec --no-startup-id blueman-applet
exec --no-startup-id volumeicon
exec --no-startup-id parcellite
EOL

# Create polybar launch script
log "Creating polybar launch script..."
cat > "$HOME/.config/polybar/launch.sh" << 'EOL'
#!/bin/bash
killall -q polybar
polybar mybar 2>&1 | tee -a /tmp/polybar.log & disown
EOL
chmod +x "$HOME/.config/polybar/launch.sh"

# Set correct permissions
log "Setting permissions..."
chown -R "$SUDO_USER:$SUDO_USER" "$HOME/.config/i3"
chown -R "$SUDO_USER:$SUDO_USER" "$HOME/.config/polybar"
chown -R "$SUDO_USER:$SUDO_USER" "$HOME/.config/picom"
chown -R "$SUDO_USER:$SUDO_USER" "$HOME/.config/rofi"
chown -R "$SUDO_USER:$SUDO_USER" "$HOME/.local/share/fonts"

log "Installation complete! Please log out and log back in to i3"

