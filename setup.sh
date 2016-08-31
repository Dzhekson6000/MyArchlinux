#!/bin/bash

# Проверяем, что скрипт запущен из под рута
if [[ "$(whoami)" != "root" ]]; then
	echo "Скрипт запущен не от суперпользователя. Запустите от root!";
	exit;
fi

#Загрузка ракладки
loadkeys ru
setfont cyr-sun16

#---- тут должно быть копирование etc
cp ./etc/locale.gen /etc/locale.gen
locale-gen
export LANG=ru_RU.UTF-8

# Проверяем, что интернет есть
errorscount="$(ping -c 3 google.com 2<&1| grep -icE 'unknown|expired|unreachable|time out')"
if [["$errorscount" != 0]]; then
	echo "Нет подключения к интернету";
	exit;
fi

#Установка приоритетного репозитория
echo "Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist

#Установка системы
pacstrap -i /mnt base base-devel
arch-chroot /mnt pacman -S grub efibootmgr --noconfirm
genfstab -p /mnt /mnt/etc/fstab

#Копирование скрипта установки
cp ./ /mnt/scripte

cp ./etc/locale.gen /mnt/etc/locale.gen

arch-chroot /mnt /bin/bash <<EOF
chmod 777 /scripte/install.sh
./scripte/install.sh
EOF
