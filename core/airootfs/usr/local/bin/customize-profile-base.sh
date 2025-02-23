#!/bin/bash

# Executa o comando locale-gen para gerar as configurações de localização
locale-gen

# Executa o comando systemctl para habilitar o NetworkManager
systemctl enable NetworkManager

# Popula repositórios
#pacman-key --init
#pacman-key --populate


#set -e
##################################################################################################################
# Author 	: Erik Dubois
# Website   : https://www.erikdubois.be
# Website   : https://www.alci.online
# Website	: https://www.arcolinux.info
# Website	: https://www.arcolinux.com
# Website	: https://www.arcolinuxd.com
# Website	: https://www.arcolinuxb.com
# Website	: https://www.arcolinuxiso.com
# Website	: https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
#tput setaf 0 = black 
#tput setaf 1 = red 
#tput setaf 2 = green
#tput setaf 3 = yellow 
#tput setaf 4 = dark blue 
#tput setaf 5 = purple
#tput setaf 6 = cyan 
#tput setaf 7 = gray 
#tput setaf 8 = light blue
##################################################################################################################

Online=0

function check_connectivity() {

    local test_ip
    local test_count

    test_ip="8.8.8.8"
    test_count=1

    if ping -c ${test_count} ${test_ip} > /dev/null; then
       	tput setaf 2
       	echo 
       	echo "You are online"
       	echo
       	tput sgr0
       	Online=1
    else
    	tput setaf 1
    	echo
       	echo "You are not connected to the internet"
       	echo "We can not download the latest archlinux-keyring package"
       	echo
       	echo "Make sure you are online to retrieve packages"
       	echo
       	tput sgr0
       	Online=0
    fi
 }

check_connectivity

echo "###############################################################################"
echo "Removing the pacman databases at /var/lib/pacman/sync/*"
echo "###############################################################################"
echo
sudo rm /var/lib/pacman/sync/*
echo

echo "###############################################################################"
echo "Removing /etc/pacman.d/gnupg folder"
echo "###############################################################################"
echo
sudo rm -rf /etc/pacman.d/gnupg/*
echo

echo "###############################################################################"
echo "Initialize pacman keys with pacman-key --init"
echo "###############################################################################"
echo
pacman-key --init
echo

echo "###############################################################################"
echo "Populating keyring with pacman-key --populate"
echo "###############################################################################"
echo 
pacman-key --populate
echo

echo "###############################################################################"
echo "Adding Ubuntu keyserver to /etc/pacman.d/gnupg/gpg.conf"
echo "###############################################################################"
echo 
echo "
keyserver hkp://keyserver.ubuntu.com:80" | sudo tee --append /etc/pacman.d/gnupg/gpg.conf

# Habilita o SDDM para Plasma
systemctl enable sddm.service

# Habilita o Bluetooth
# systemctl enable bluetooth

## Script to perform several important tasks before `mkarchcraftiso` create filesystem image.

set -e -u

## -------------------------------------------------------------- ##

## Modify /etc/mkinitcpio.conf file
sed -i '/etc/mkinitcpio.conf' \
        -e "s/#COMPRESSION=\"zstd\"/COMPRESSION=\"zstd\"/g"


## Fix Initrd Generation in Installed System
cat > "/etc/mkinitcpio.d/linux.preset" <<- _EOF_
	# mkinitcpio preset file for the 'linux' package

	ALL_kver="/boot/vmlinuz-linux"
	ALL_config="/etc/mkinitcpio.conf"

	PRESETS=('default' 'fallback')

	#default_config="/etc/mkinitcpio.conf"
	default_image="/boot/initramfs-linux.img"
	#default_options=""

	#fallback_config="/etc/mkinitcpio.conf"
	fallback_image="/boot/initramfs-linux-fallback.img"
	fallback_options="-S autodetect"    
_EOF_

## Delete ISO specific init files
rm -rf /etc/mkinitcpio.conf.d
