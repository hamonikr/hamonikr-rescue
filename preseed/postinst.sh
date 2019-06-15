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


# wide screen
echo "GRUB_GFXMODE=1024×576" > /etc/default/grub

# firefox homepae change
cp -a /cdrom/preseed/rescue/distribution.ini /usr/share/ubuntu-system-adjustments/firefox/distribution.ini
cp -a /cdrom/preseed/rescue/distribution.ini /usr/lib/firefox/distribution/distribution.ini

# Delete useless files
rm /target/home/*/.dmrc
rm /target/etc/skel/.dmrc
