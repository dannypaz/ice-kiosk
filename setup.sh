#!/bin/bash

set -e

URL="https://ice.bayareacurling.org"
HOSTNAME="kiosk"

sudo apt update

sudo apt install --no-install-recommends -y \
  xserver-xorg \
  xinit \
  x11-xserver-utils \
  openbox \
  unclutter \
  xdotool \
  surf

sudo hostnamectl set-hostname "$HOSTNAME"

sudo sed -i "s/127.0.1.1.*/127.0.1.1    $HOSTNAME/" /etc/hosts

sudo raspi-config nonint do_boot_behaviour B2

echo "Updating config.txt with settings"
sudo sed -i '/vc4-kms-v3d/d' /boot/firmware/config.txt || true
sudo sed -i '/vc4-fkms-v3d/d' /boot/firmware/config.txt || true
grep -q '^hdmi_force_hotplug=1' /boot/firmware/config.txt || \
echo 'hdmi_force_hotplug=1' | sudo tee -a /boot/firmware/config.txt
grep -q '^framebuffer_width=1920' /boot/firmware/config.txt || \
echo 'framebuffer_width=1920' | sudo tee -a /boot/firmware/config.txt
grep -q '^framebuffer_height=1080' /boot/firmware/config.txt || \
echo 'framebuffer_height=1080' | sudo tee -a /boot/firmware/config.txt
grep -q '^hdmi_group=2' /boot/firmware/config.txt || \
echo 'hdmi_group=2' | sudo tee -a /boot/firmware/config.txt
grep -q '^hdmi_mode=82' /boot/firmware/config.txt || \
echo 'hdmi_mode=82' | sudo tee -a /boot/firmware/config.txt

echo "Updating cmdline.txt to allow gadget mode"
sudo grep -q 'modules-load=dwc2,g_ether' /boot/firmware/cmdline.txt || sudo sed -i 's/\brootwait\b/& modules-load=dwc2,g_ether/' /boot/firmware/cmdline.txt

cat > "$HOME/.bash_profile" <<'EOF'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && ! pgrep -x Xorg >/dev/null; then
  startx
fi
EOF

mkdir -p "$HOME/.surf/styles"
touch "$HOME/.surf/styles/default.css"

cat > ~/.xinitrc <<'EOF'
#!/bin/sh

URL="https://ice.bayareacurling.org"

export DISPLAY=:0
export LIBGL_ALWAYS_SOFTWARE=1
export WEBKIT_DISABLE_COMPOSITING_MODE=1

xset -dpms || true
xset s off || true
xset s noblank || true

openbox-session &
unclutter -idle 0 &

# Give HDMI / framebuffer / monitor time to settle
sleep 15

while true; do
  surf "$URL" &

  # Give surf time to create its window
  sleep 10

  WINDOW_ID=$(xdotool search --onlyvisible --class surf | head -n 1)

  if [ -n "$WINDOW_ID" ]; then
    xdotool windowmove "$WINDOW_ID" 0 0 || true
    xdotool windowsize "$WINDOW_ID" 1920 1080 || true
  fi

  sleep 290

  pkill surf || true
  sleep 2
done
EOF

chmod +x ~/.xinitrc
sudo reboot
