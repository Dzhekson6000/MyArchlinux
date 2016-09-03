#!/bin/bash

# Проверяем, что скрипт запущен из под рута
if [[ "$(whoami)" != "root" ]]; then
	echo "Скрипт запущен не от суперпользователя. Запустите от root!";
	exit;
fi

#Загрузка ракладки
loadkeys ru
setfont cyr-sun16

cp ./etc/locale.gen /etc/locale.gen
locale-gen
export LANG=ru_RU.UTF-8

#Установка приоритетного репозитория
echo "Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist

#Установка системы
pacstrap -i /mnt base base-devel
arch-chroot /mnt pacman -S grub efibootmgr --noconfirm
genfstab -p /mnt /mnt/etc/fstab

#Копирование скрипта установки
cp -r . /mnt/scripte_tmp

arch-chroot /mnt /scripte_tmp/install.sh
