#!/bin/bash

# firewall on
sudo sed -i 's/ENABLED=no/ENABLED=yes/g' /target/etc/ufw/ufw.conf

# Add Korean language variable  
sed -i '/^#/ d' /target/etc/default/locale
lang_kr='LANG="ko_KR.UTF-8"'
lang_val=$(cat /target/etc/default/locale)

if [ "$lang_val" == "$lang_kr" ]; then
  echo 'LANGUAGE=ko_KR:ko' >> /target/etc/default/locale;
  echo 'LC_NUMERIC=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_TIME=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_MONETARY=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_PAPER=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_IDENTIFICATION=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_NAME=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_ADDRESS=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_TELEPHONE=ko_KR.UTF-8' >> /target/etc/default/locale;
  echo 'LC_MEASUREMENT=ko_KR.UTF-8' >> /target/etc/default/locale;
fi

# ME launchpad  APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3B587A9C; \
sudo sh -c 'echo "deb [arch=amd64] http://ppa.launchpad.net/hamonikr/me/ubuntu bionic main" > /etc/apt/sources.list.d/hamonikr-lp.list'; \
sudo sh -c 'echo "deb-src [arch=amd64] http://ppa.launchpad.net/hamonikr/me/ubuntu bionic main" >> /etc/apt/sources.list.d/hamonikr-lp.list'

# QT 5.12  APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E9977759; \
sudo sh -c 'echo "deb http://ppa.launchpad.net/beineri/opt-qt-5.12.3-bionic/ubuntu bionic main " > /etc/apt/sources.list.d/qt512.list'; \
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/beineri/opt-qt-5.12.3-bionic/ubuntu bionic main" >> /etc/apt/sources.list.d/qt512.list'

# 한글입력기 nimf APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 91F9381B; \
sudo sh -c 'echo "deb http://ppa.launchpad.net/hodong/nimf/ubuntu bionic main " > /etc/apt/sources.list.d/nimf.list'; \
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/hodong/nimf/ubuntu bionic main" >> /etc/apt/sources.list.d/nimf.list'

# boot-repair  APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 60D8DA0B; \
sudo sh -c 'echo "deb http://ppa.launchpad.net/yannubuntu/boot-repair/ubuntu bionic main " > /etc/apt/sources.list.d/boot-repair.list'; \
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/yannubuntu/boot-repair/ubuntu bionic main" >> /etc/apt/sources.list.d/boot-repair.list'

# visual studio  APT
sudo curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg; \
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/; \
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# ME 저장소 추가
sudo wget -q -O - http://ppa.hamonikr.org/ME/KEY.gpg | sudo apt-key add -; \
sudo sh -c 'echo "deb http://ppa.hamonikr.org/ME/ /" > /etc/apt/sources.list.d/hamonikr-me.list'

# SE 저장소 추가
sudo wget -q -O - http://ppa.hamonikr.org/SE/KEY.gpg | sudo apt-key add -; \
sudo sh -c 'echo "deb http://ppa.hamonikr.org/SE/ /" > /etc/apt/sources.list.d/hamonikr-se.list'

sudo apt update

# 각종 프로그램 설치
sudo apt-get install localepurge
# apt install qt512base qt512scxml qt512webengine qt512multimedia qt512tools qt512translations qt512x11extras qt512xmlpatterns -y
apt install boot-repair apt-transport-https code nimf nimf-libhangul htop clamav-daemon clamav-freshclam clamav xclip -y; \
apt install simplescreenrecorder kodi fsarchiver udpcast vim tree nmon nemo-filename-repairer -y; \
im-config -n nimf
sed -i 's/Exec=clamtk %F/Exec=env CL_TIME=c clamtk %F/g' /usr/share/applications/clamtk.desktop
# firefox 패키지 업그레이드 - security patch
# 2019.05.04 일에 발생한 버그 https://blog.mozilla.org/addons/2019/05/04/update-regarding-add-ons-in-firefox/
sudo apt-get --only-upgrade install firefox -y; \
sudo apt-get --only-upgrade install firefox-locale-ko -y

# other apps
sudo apt install default-jdk mint-meta-codecs -y
sudo apt install speedtest-cli iptraf nmap -y
sudo apt install wireshark tshark -y
sudo apt install frei0r-plugins -y
sudo apt install dvdauthor -y
sudo apt install vlc -y
sudo apt install kdenlive -y

# shutter
# 키보트 단축키로 shutter -s 설정하면 원하는 영역 스크린샷
apt install shutter -y
# 캡쳐 후 편집이 되도록 하기 위해서 아래 링크 참고
# https://itsfoss.com/shutter-edit-button-disabled/
wget https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas-common_1.0.0-1_all.deb; \
wget https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas3_1.0.0-1_amd64.deb; \
wget https://launchpad.net/ubuntu/+archive/primary/+files/libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb; \
sudo dpkg -i libgoocanvas-common_1.0.0-1_all.deb; \
sudo dpkg -i libgoocanvas3_1.0.0-1_amd64.deb; \
sudo dpkg -i libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb; \
sudo apt install -f; \
sudo killall shutter; \
sudo apt install libappindicator-dev; \
sudo cpan -i Gtk2::AppIndicator; \
sudo killall shutter

# dist-upgrade after clean
sudo apt-get clean
sudo rm -r /var/lib/apt/lists/*
sudo apt-get update

# wide screen
echo "GRUB_GFXMODE=1024×576" > /etc/default/grub

# firefox homepae change
cp -a /cdrom/preseed/rescue/distribution.ini /usr/share/ubuntu-system-adjustments/firefox/distribution.ini
cp -a /cdrom/preseed/rescue/distribution.ini /usr/lib/firefox/distribution/distribution.ini

# Delete useless files
rm /target/home/*/.dmrc
rm /target/etc/skel/.dmrc
