#!/bin/bash

set -e

BACKUP_DIR="$HOME/.config/i3_backup_$(date +%Y%m%d_%H%M%S)"

if [ -d "$HOME/.config/i3" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.config/i3/"* "$BACKUP_DIR/"
fi

read -p "This will install i3 and related packages. Continue? [y/N] " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    exit 1
fi

sudo apt update
sudo apt install -y i3 i3lock-fancy polybar picom rofi feh dunst network-manager-gnome blueman volumeicon-alsa numlockx parcellite gnome-keyring xautolock xbacklight python3-pip
pip install i3-auto-layout

mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/Pictures"

cat > "$HOME/.config/i3/config" << 'EOL'
set $mod Mod4

font pango:JetBrains Mono Nerd Font 10

floating_modifier $mod

bindsym $mod+Return exec warp-terminal
bindsym $mod+Shift+q kill
bindsym $mod+d exec rofi -show drun

bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

bindsym $mod+b split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle

bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

bindsym $mod+a focus parent

bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6
bindsym $mod+7 workspace 7
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9
bindsym $mod+0 workspace 10

bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+6 move container to workspace 6
bindsym $mod+Shift+7 move container to workspace 7
bindsym $mod+Shift+8 move container to workspace 8
bindsym $mod+Shift+9 move container to workspace 9
bindsym $mod+Shift+0 move container to workspace 10

bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

mode "resize" {
    bindsym h resize shrink width 10 px
    bindsym j resize grow height 10 px
    bindsym k resize shrink height 10 px
    bindsym l resize grow width 10 px
    
    bindsym Return mode "default"
    bindsym Escape mode "default"
    bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"

client.focused          #FF0000 #FF0000 #FFFFFF #FF0000
client.focused_inactive #333333 #5F676A #FFFFFF #484E50
client.unfocused        #333333 #222222 #888888 #292D2E
client.urgent           #2F343A #900000 #FFFFFF #900000

gaps inner 10
gaps outer 5
smart_gaps on

exec_always --no-startup-id $HOME/.config/polybar/launch.sh
exec_always --no-startup-id feh --bg-scale $HOME/Pictures/Evangelion.png
exec_always --no-startup-id i3-auto-layout

workspace 1 output eDP-1
workspace 2 output HDMI-1

bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym $mod+F6 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym $mod+F7 exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym $mod+F8 exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
EOL

cat > "$HOME/.config/i3/autostart.sh" << 'EOL'
#!/bin/bash

pulseaudio --start
picom -b
dunst &
nm-tray &
blueman-applet &
volumeicon &
numlockx on
parcellite &
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

xinput set-prop "DELL097D:00 04F3:311C Touchpad" "libinput Tapping Enabled" 1
xinput set-prop "DELL097D:00 04F3:311C Touchpad" "libinput Natural Scrolling Enabled" 1
EOL

cat > "$HOME/.config/i3/brightness.sh" << 'EOL'
#!/bin/bash

current=$(cat /sys/class/backlight/intel_backlight/brightness)
max=$(cat /sys/class/backlight/intel_backlight/max_brightness)
step=$((max / 20))

case $1 in
    up)
        new=$((current + step))
        if [ $new -gt $max ]; then
            new=$max
        fi
        ;;
    down)
        new=$((current - step))
        if [ $new -lt 0 ]; then
            new=0
        fi
        ;;
esac

echo $new > /sys/class/backlight/intel_backlight/brightness
EOL

cat > "$HOME/.config/i3/lock.sh" << 'EOL'
#!/bin/bash

xset dpms 5 5 5
i3lock-fancy
xset dpms 600 600 600
EOL

cat > "$HOME/.config/i3/i3status.conf" << 'EOL'
general {
    colors = true
    interval = 5
    color_good = "#2AA198"
    color_bad = "#586E75"
    color_degraded = "#DC322F"
}

order += "wireless _first_"
order += "battery all"
order += "cpu_usage"
order += "memory"
order += "tztime local"

wireless _first_ {
    format_up = "W: (%quality at %essid) %ip"
    format_down = "W: down"
}

battery all {
    format = "%status %percentage %remaining"
}

cpu_usage {
    format = "CPU: %usage"
}

memory {
    format = "MEM: %used | %available"
    threshold_degraded = "1G"
    format_degraded = "MEMORY < %available"
}

tztime local {
    format = "%Y-%m-%d %H:%M:%S"
}
EOL

chmod +x "$HOME/.config/i3/autostart.sh"
chmod +x "$HOME/.config/i3/brightness.sh"
chmod +x "$HOME/.config/i3/lock.sh"

echo "i3 setup complete. Please log out and select i3 at the login screen."

