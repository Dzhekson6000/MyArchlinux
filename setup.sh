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
locale-gen
export LANG=ru_RU.UTF-8
mkinitcpio -p linux
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
echo "Введите пароль для root:"
passwd
echo "Введите имя компьютера:"
read newhostname
hostnamectl set-hostname $newhostname
timedatectl set-timezone Europe/Moscow
localectl set-keymap ru
setfont cyr-sun16
localectl set-locale LANG="ru_RU.UTF-8"
export LANG=ru_RU.UTF-8
cat <<EOF1
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF1 >> /etc/pacman.conf
chmod 777 /scripte/install.sh
./scripte/install.sh
EOF
