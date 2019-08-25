#!/bin/bash

###################################################################
#Script Name	: Auto-LiME.sh
#Description	: Automates the process of creating linux kernel profile, memory dump in order to investigate with Volatility.
#       	  Run this script with sudo permission.
#Args           : sudo ./Auto-LiME.sh -x
#Author       	: Siva
###################################################################


echo -e "\e[91m                _              _      _ __  __ ______     "
echo -e "\e[91m     /\        | |            | |    (_)  \/  |  ____|    "
echo -e "\e[97m    /  \  _   _| |_ ___ ______| |     _| \  / | |__   	 "
echo -e "\e[97m   / /\ \| | | | __/ _ \______| |    | | |\/| |  __|  	 "
echo -e "\e[92m  / ____ \ |_| | || (_) |     | |____| | |  | | |____ 	 "
echo -e "\e[92m /_/    \_\__,_|\__\___/      |______|_|_|  |_|______|	 "

echo -e "\e[97m"
#	Install and Update all necessary dependencies
printf "\n\n*Installtion of dependencies in progress..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y install build-essential > /dev/null 2>&1
sudo apt-get -y install linux-headers-`uname -r` > /dev/null 2>&1
sudo apt-get -y install dwarfdump > /dev/null 2>&1
sudo apt-get -y install git zip libelf-dev python > /dev/null 2>&1
sudo apt-get -y install yara > /dev/null 2>&1
sudo apt-get -y install python-pip > /dev/null 2>&1
sudo -H pip install --upgrade pip  > /dev/null 2>&1
sudo -H pip install distorm3 pycrypto openpyxl Pil > /dev/null 2>&1
printf "completed."

printf "\n*Downloading LiME and making kernel object..."
#	Download LiME and creating kernel object
git clone https://github.com/504ensicsLabs/LiME > /dev/null 2>&1
cd LiME/src/
make > /dev/null 2>&1
printf "completed."

printf "\n*Creating memory dump under /tmp/volevidence.mem..."
#	Creating memory dump at tmp folder
sudo insmod lime-$(uname -r).ko "path=/tmp/volevidence.mem format=lime" > /dev/null 2>&1
printf "completed."

printf "\n*Downloading Volatility and creating dwarf file...\n"
#	Downloading Volatility and creating dwarf file
cd ../../
git clone https://github.com/volatilityfoundation/volatility > /dev/null 2>&1
cd volatility
sudo python setup.py install > /dev/null 2>&1
cd tools/linux/
sudo make -C /lib/modules/$(uname -r)/build CONFIG_DEBUG_INFO=y M=$PWD modules 
sudo dwarfdump -di ./module.o > module.dwarf
mpath="$(pwd)"
cd ../../../
printf "completed."

printf "\n*Creating Linux profile by combining dwarf and system map file...\n"
#	Creating Kernel profile and moving it to volatility
sudo zip $(uname -r).zip $mpath/module.dwarf /boot/System.map-$(uname -r)
sudo mv $(uname -r).zip volatility/volatility/plugins/overlays/linux/
printf "completed."

printf "\n\nBelow results indicate vol.py linux profile created. \n\n"
echo -e "\e[92m"
#	Confirming the profile reflects in vol profile lits
cd volatility/
printf "python vol.py --info|grep $(uname -r)\n\n"
python vol.py --info |grep $(uname -r)


echo -e "\e[97m"


printf "\n\nReady for memory investigation!\n\n"

