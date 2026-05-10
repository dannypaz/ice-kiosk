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
  x11-utils \
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

cat > ~/.xinitrc <<'EOF'
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

surf -g 1920x1080+0+0 "$URL" &

sleep 10

while true; do
  WINDOW_ID=$(xdotool search --onlyvisible --class surf | head -n 1)

  if [ -n "$WINDOW_ID" ]; then
    xdotool key --window "$WINDOW_ID" F5 || true
  fi

  sleep 300
done
EOF

chmod +x ~/.xinitrc
sudo reboot
