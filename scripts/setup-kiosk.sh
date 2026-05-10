#!/bin/bash

set -e

URL="https://ice.bayareacurling.org"
HOSTNAME="kiosk"

sudo apt update

sudo apt install --no-install-recommends -y \
  xserver-xorg \
  xinit \
  x11-xserver-utils \
  x11-utils \
  openbox \
  unclutter \
  xdotool \
  surf

sudo hostnamectl set-hostname "$HOSTNAME"

sudo sed -i "s/127.0.1.1.*/127.0.1.1    $HOSTNAME/" /etc/hosts

sudo raspi-config nonint do_boot_behaviour B2

sudo sed -i '/vc4-kms-v3d/d' /boot/firmware/config.txt || true
sudo sed -i '/vc4-fkms-v3d/d' /boot/firmware/config.txt || true

grep -q '^hdmi_force_hotplug=1' /boot/firmware/config.txt || \
echo 'hdmi_force_hotplug=1' | sudo tee -a /boot/firmware/config.txt

grep -q '^framebuffer_width=1920' /boot/firmware/config.txt || \
echo 'framebuffer_width=1920' | sudo tee -a /boot/firmware/config.txt

grep -q '^framebuffer_height=1080' /boot/firmware/config.txt || \
echo 'framebuffer_height=1080' | sudo tee -a /boot/firmware/config.txt

cat > "$HOME/.bash_profile" <<'EOF_BASH_PROFILE'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && ! pgrep -x Xorg >/dev/null; then
  startx
fi
EOF_BASH_PROFILE

mkdir -p "$HOME/.surf/styles"
touch "$HOME/.surf/styles/default.css"

cat > "$HOME/.xinitrc" <<'EOF_XINITRC'
#!/bin/sh

URL="https://ice.bayareacurling.org"

export DISPLAY=:0
export LIBGL_ALWAYS_SOFTWARE=1
export WEBKIT_DISABLE_COMPOSITING_MODE=1

xset -dpms
xset s off
xset s noblank

openbox-session &
unclutter -idle 0 &

surf "$URL" &

WINDOW_ID=""

for i in $(seq 1 30); do
  WINDOW_ID=$(xdotool search --onlyvisible --class surf | head -n 1)
  if [ -n "$WINDOW_ID" ]; then
    break
  fi
  sleep 1
done

SCREEN_SIZE=$(xdpyinfo | awk '/dimensions:/ {print $2}')
WIDTH=$(echo "$SCREEN_SIZE" | cut -d'x' -f1)
HEIGHT=$(echo "$SCREEN_SIZE" | cut -d'x' -f2)

xdotool windowmove "$WINDOW_ID" 0 0
xdotool windowsize "$WINDOW_ID" "$WIDTH" "$HEIGHT"

while true; do
  xdotool windowmove "$WINDOW_ID" 0 0 || true
  xdotool windowsize "$WINDOW_ID" "$WIDTH" "$HEIGHT" || true
  xdotool key --window "$WINDOW_ID" F5 || true
  sleep 300
done
EOF_XINITRC

chmod +x "$HOME/.xinitrc"

sudo reboot
