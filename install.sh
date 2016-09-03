#!/bin/bash

# Проверяем, что скрипт запущен из под рута
if [[ "$(whoami)" != "root" ]]; then
	echo "Скрипт запущен не от суперпользователя. Запустите от root!";
	exit;
fi

#копирование etc и usr
cp -r /scripte_tmp/etc /etc
cp -r /scripte_tmp/usr /usr

#локали
locale-gen
echo LANG=ru_RU.UTF-8 > /etc/locale.conf
export LANG=ru_RU.UTF-8

ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

#grub
mkinitcpio -p linux
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

#root пользователь
echo "Введите пароль для root:"
passwd
echo "Введите имя компьютера:"

read newhostname
echo "$newhostname" > /etc/hostname

echo "[multilib]\nInclude = /etc/pacman.d/mirrorlist"  >> /etc/pacman.conf

echo "Введите имя пользователя которого хотите создать(только символы латинского алфавита и _): "
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
pacman -S iw wpa_supplicant dialog git tig alsa-utils rxvt-unicode ttf-droid ttf-dejavu feh firefox flashplugin sxiv vlc shutter lightdm network-manager-applet sbxkb ranger htop libreoffice-fresh libreoffice-fresh-ru i3status obs-studio sxiv --noconfirm

#устанавиваем иксы
pacman -S xorg-xrandr --noconfirm

#устанавливаем yaourt
mkdir /scripte_tmp/tmp && cd /scripte_tmp/tmp && git clone https://aur.archlinux.org/yaourt.git && cd /scripte_tmp/tmp/yaourt && makepkg -sri && cd /

#Устанавивание пакеты из AUR: lightdm greeter, оконный менеджер, запуск приложений, редактор видео, текстовый редактор, торрент-качалка, Slack клиент, Telegram клиент
su -c 'yaourt -S lightdm-webkit-greeter i3-gaps j4-dmenu-desktop-git flowblade atom-editor rtorrent-color slack-desktop telegram-desktop-bin clion --noconfirm' $newusername

#копирование конфигураций пользователя
cp -r /scripte_tmp/home /home/$newusername/

#запускаем сервис lightdm
systemctl enable lightdm

echo "#!/bin/sh\nfeh  —bg-scale '/home/$newusername/Images/wallpaper.png'" >> /home/$newusername/.fehbg

#очистка
rm -r /scripte_tmp

# Заканчиваем выполнение
echo -e "Готово! Можно перезагружать компьютер.\n© Ilya Chizanov, 2016"
