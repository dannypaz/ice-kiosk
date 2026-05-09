# Pi Zero W Ice Kiosk Plan From macOS

## Summary

Build the kiosk on the existing Raspberry Pi Zero W with an HDMI display, optimized for unattended daily display of `https://ice.bayareacurling.org`.

Use **Raspberry Pi OS Legacy Lite 32-bit** because the original Pi Zero W needs the 32-bit Legacy image. Do the imaging and first configuration from your Mac, then finish setup over SSH.

## Mac Setup Steps

1. Install Raspberry Pi Imager on macOS.
   - Download from <https://www.raspberrypi.com/software/>.
   - Insert the microSD card using a USB adapter.

2. Flash the card with:
   - OS: **Raspberry Pi OS Legacy Lite 32-bit**
   - Hostname: `ice-kiosk`
   - Enable SSH
   - Set username/password
   - Configure Wi-Fi SSID/password
   - Set locale/timezone: `America/Los_Angeles`

3. Boot the Pi, then connect from the Mac:
   ```bash
   ssh <username>@ice-kiosk.local
   ```

   If `.local` does not resolve, find the IP from your router and use:
   ```bash
   ssh <username>@<pi-ip-address>
   ```

## Pi Implementation Steps

1. Update the Pi:
   ```bash
   sudo apt update
   sudo apt -y full-upgrade
   sudo reboot
   ```

2. Install a minimal kiosk stack:
   ```bash
   sudo apt install --no-install-recommends xserver-xorg xinit openbox chromium-browser unclutter x11-xserver-utils
   ```

3. Create a kiosk startup script that:
   - Disables screen blanking and DPMS.
   - Hides the mouse cursor.
   - Starts Chromium in fullscreen kiosk mode at:
     ```text
     https://ice.bayareacurling.org
     ```
   - Restarts Chromium if it crashes.

4. Create a `systemd` service that:
   - Starts after network is online.
   - Runs the kiosk script as the normal user.
   - Restarts on failure.
   - Starts automatically on boot.

5. Add unattended reliability:
   - Schedule a daily reboot around `4:00 AM`.
   - Keep SSH enabled for maintenance.
   - Use a solid power supply and decent SD card.
   - Only force HDMI resolution if the display does not auto-detect correctly.

## Test Plan

- From your Mac, reboot the Pi:
  ```bash
  ssh <username>@ice-kiosk.local 'sudo reboot'
  ```
- Confirm the HDMI display opens the site automatically.
- Kill Chromium over SSH and confirm it relaunches.
- Check resource use:
  ```bash
  ssh <username>@ice-kiosk.local 'free -h && top -b -n1 | head'
  ```
- Leave it running for several hours and confirm the page remains visible.

## Assumptions

- You are flashing/configuring the SD card from macOS.
- The kiosk is HDMI landscape.
- The site does not need login.
- If Chromium is too slow on the original Zero W, the practical fix is upgrading to a Zero 2 W or newer Pi.
