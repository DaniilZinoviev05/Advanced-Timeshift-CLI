#! /bin/bash

###
PACKAGES="timeshift grub-btrfs cronie viu mailutils mailx"  
USER=$(whoami)
###
#echo "Текущий пользователь: $USER"

echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER

install_libraries_arch() {
	sudo pacman -S $1 --noconfirm
}

for package in $PACKAGES; do
	if ldconfig -p | grep -q $package; then
		echo "библиотека $package установлена."
	else
		install_libraries_arch $package
	fi
done

sudo rm /etc/sudoers.d/$USER

