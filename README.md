# Ice Kiosk

This repository contains setup notes and scripts for a Raspberry Pi kiosk used by the San Francisco Bay Area Curling Club. The kiosk opens the club ice schedule at <https://ice.bayareacurling.org> so the daily schedule can be shown on an attached display.

## What this sets up

The setup script configures a Raspberry Pi OS Lite installation to boot into a minimal X session and show the daily curling schedule in a lightweight browser. It is intended for an HDMI display where the Pi is used only as an unattended schedule kiosk.

## Raspberry Pi setup

1. Flash the SD card with **Raspberry Pi OS Lite**.
   - Use the Lite image with no desktop environment.
   - Raspberry Pi Imager is the easiest way to write the image to the SD card.

2. Boot the Raspberry Pi and complete the first-run prompts.
   - Create the kiosk username and password when prompted.
   - These instructions assume the username is `kiosk`.

3. Make sure Wi-Fi is enabled on the Raspberry Pi:
   ```bash
   sudo nmcli radio wifi on
   ```

4. Configure Wi-Fi on the Raspberry Pi:
   ```bash
   sudo raspi-config
   ```
   - Open **System Options**.
   - Choose **Wireless LAN**.
   - Enter the Wi-Fi network name and password.
   - Exit `raspi-config` when finished.

5. From your host machine, copy the setup script to the Raspberry Pi home directory:
   ```bash
   scp scripts/setup-kiosk.sh kiosk@kiosk.local:/home/kiosk/setup.sh
   ```

   If `kiosk.local` does not resolve on your network, use the Pi's IP address instead:
   ```bash
   scp scripts/setup-kiosk.sh kiosk@<pi-ip-address>:/home/kiosk/setup.sh
   ```

6. SSH into the Raspberry Pi and run the setup script:
   ```bash
   ssh kiosk@kiosk.local
   bash setup.sh
   ```

   The script installs the kiosk packages, configures the display startup files, and reboots the Raspberry Pi when setup is complete.

## After setup

After the reboot, the Raspberry Pi should automatically start the kiosk on the attached display and show the San Francisco Bay Area Curling Club daily ice schedule.
