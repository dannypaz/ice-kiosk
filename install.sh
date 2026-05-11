#!/bin/bash

set -e

scp setup.sh wpa_supplicant.conf kiosk@kiosk.local:/home/kiosk/
ssh kiosk@kiosk.local "sudo cp /home/kiosk/wpa_supplicant.conf /etc/wpa_supplicant/"
