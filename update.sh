#!/bin/bash

moonraker_file="/home/pi/printer_data/config/moonraker.conf"

text="https://github.com/Spectoda/spectoda-bridge-pws400k.git"

slozka="/home/pi/Klipper_IP"

if ! command -v zip &> /dev/null; then
    sudo apt-get update
    sudo apt-get install zip -y

    if [ $? -eq 0 ]; then
        echo "ZIP utility installed successfully."
    else
        echo "Failed to install ZIP utility."
        exit 1
    fi
fi

if [ ! -d "$slozka" ]; then
    git clone https://github.com/PrintWithSmile/Klipper_IP.git
	cd Klipper_IP
	chmod +x install.sh
	./install.sh
fi


if [ -f "$moonraker_file" ]; then
    if grep -q "$text" "$moonraker_file"; then
		rm -r -f spectoda-bridge-pws400k/
		wait
		git clone https://github.com/PrintWithSmile/spectoda-bridge-pws400k.git 
		wait
		cd spectoda-bridge-pws400k && npm i
		wait
		sed -i 's#https://github.com/Spectoda/spectoda-bridge-pws400k.git#https://github.com/PrintWithSmile/spectoda-bridge-pws400k.git#g' ~/printer_data/config/moonraker.conf
		wait
		systemctl restart spectoda-bridge-pws400k
	fi
fi

echo "Creating backup"

cd /home/pi/printer_data/config

zip -r "zaloha_$(date +"%d-%m-%Y").zip" /home/pi/printer_data/config/* -x "/home/pi/printer_data/config/Archive/*" -x "/home/pi/printer_data/config/Archive"

mv "zaloha_$(date +"%d-%m-%Y").zip" /home/pi/printer_data/config/Archive

cp -f /home/pi/PWS/PWS_400K_EN_RAPTOR/Configurations/* /home/pi/printer_data/config/PWS_config/

service klipper restart

echo "Successfully updated"
