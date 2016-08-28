#!/bin/bash
echo "Введите имя пользователя которого хотите создать: "
# Считываем имя пользователя
read user
# Проверяем, что скрипт запущен из под рута
if [[ "$(whoami)" != "root" ]]; then
	echo "Скрипт запущен не от суперпользователя. Запустите от root!";
	exit;
fi

#Установка гит, базовый пакет разработчика, регулятор громкости alsa, терминал, шрифт1, шрифт2,
#просмотрщик картинок, браузер, Flash-плагин для браузера, росмотрщик изображений, видео плеер,
#скриншоттер, LightDM, менеджер сетей, виджет раскладки, файловый менеджер
#диспечер задач, офисный пакет, русский язык для офисного пакета, i3status
pacman -S git base-devel alsa-utils rxvt-unicode ttf-droid ttf-dejavu feh firefox flashplugin sxiv vlc shutter Lightdm network-manager-applet sbxkb ranger htop libreoffice-fresh libreoffice-fresh-ru i3status --noconfirm

#устанавиваем иксы
pacman -S xorg-xrandr --noconfirm

#устанавливаем yaourt
mkdir /tmp && cd /tmp && git clone https://aur.archlinux.org/yaourt.git && su -c 'cd /tmp/yaourt && makepkg -sri' $user

#Устанавивание пакеты из AUR: оконный менеджер, запуск приложений, редактор видео, текстовый редактор, торрент-качалка
su -c 'yaourt -S i3-gaps j4-dmenu-desktop-git flowblade atom-editor rtorrent-color --noconfirm' $user

# Заканчиваем выполнение
echo -e "Готово! Можно перезагружать компьютер.\n© Ilya Chizanov, 2016"
