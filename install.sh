#!/bin/bash

# Проверяем, что скрипт запущен из под рута
if [[ "$(whoami)" != "root" ]]; then
	echo "Скрипт запущен не от суперпользователя. Запустите от root!";
	exit;
fi


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

# Проверяем, что интернет есть
errorscount="$(ping -c 3 google.com 2<&1| grep -icE 'unknown|expired|unreachable|time out')"
if [["$errorscount" != 0]]; then
	echo "Нет подключения к интернету";
	exit;
fi

echo "Введите имя пользователя которого хотите создать: "
# Считываем имя пользователя
read newusername

useradd -m -g users -G audio,games,lp,optical,power,scanner,storage,video,wheel -s /bin/bash $newusername
echo "Введите пароль пользователя: "
passwd $newusername

#обновляем список зеркал
pacman -Syu

#Установка iw, зашифрованное соединение, прошифки для вайфая, гит, просмотр гит папки, регулятор громкости alsa, терминал, шрифт1, шрифт2,
#просмотрщик картинок, браузер, Flash-плагин для браузера, росмотрщик изображений, видео плеер,
#скриншоттер, LightDM, менеджер сетей, виджет раскладки, файловый менеджер
#диспечер задач, офисный пакет, русский язык для офисного пакета, i3status, трансляции, просмотр изображений
pacman -S iw wpa_supplicant dialog git tig alsa-utils rxvt-unicode ttf-droid ttf-dejavu feh firefox flashplugin sxiv vlc shutter Lightdm network-manager-applet sbxkb ranger htop libreoffice-fresh libreoffice-fresh-ru i3status obs-studio sxiv --noconfirm

#устанавиваем иксы
pacman -S xorg-xrandr --noconfirm

#устанавливаем yaourt
mkdir /tmp && cd /tmp && git clone https://aur.archlinux.org/yaourt.git && su -c 'cd /tmp/yaourt && makepkg -sri' $user

#Устанавивание пакеты из AUR: lightdm greeter, оконный менеджер, запуск приложений, редактор видео, текстовый редактор, торрент-качалка, Slack клиент, Telegram клиент
su -c 'yaourt -S lightdm-webkit-greeter i3-gaps j4-dmenu-desktop-git flowblade atom-editor rtorrent-color slack-desktop telegram-desktop-bin --noconfirm' $user

# Заканчиваем выполнение
echo -e "Готово! Можно перезагружать компьютер.\n© Ilya Chizanov, 2016"
