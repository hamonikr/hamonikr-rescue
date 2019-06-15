#!/bin/bash
# Backup and Restore Program for HamoniKR Desktop Linux (HamoniKR)
# Copyright (C) 2015-2019 HamoniKR Team, Kevin Kim
# This file may be used under the terms of the GNU General Public License, version 2 or later.
# For more details see: https://www.gnu.org/licenses/gpl-2.0.html

# preseed/late_command 미동작 시, 본 script 수동 실행
# /rescue 존재 유무 확인
RESCUE=`sed -n '/rescue/p' /target/etc/fstab | sed -n '/UUID/p' | awk '{ print $2 }'`

# autostart remove (target)
sudo rm -rf /target/etc/skel/.config/.hamonikr_live_rescue.sh \
            /target/etc/skel/.config/autostart/hamonikr_rescue.desktop \
            /target/usr/share/applications/hamonikr_rescue.desktop \
            /target/home/*/.config/autostart/hamonikr_rescue.desktop \
            /target/home/*/.config/.hamonikr_live_rescue.sh \
            /target/bin/hamonikr_multicast

### ubiquity/success_command
# rescue check
if [ x"$RESCUE" = x"/rescue" ]; then

	# /etc/apt/sources.list change
	# sudo cp -af /cdrom/preseed/rescue/etc/apt/sources.list /target/etc/apt/sources.list

	sudo install -D -m 755 /cdrom/preseed/rescue/bin/hamonikr_rescue -t /target/bin
	sudo install -D -m 755 /cdrom/preseed/rescue/bin/hamonikr_live_rescue.sh -t /target/bin
	sudo install -D -m 755 /cdrom/preseed/rescue/bin/hamonikr_multicast -t /target/bin
	sudo install -D -m 755 /cdrom/preseed/rescue/usr/share/applications/hamonikr_rescue.desktop -t /target/usr/share/applications
	sudo install -D -m 755 /cdrom/preseed/rescue/usr/share/applications/hamonikr_rescue.desktop -t /target/etc/skel/.config/autostart

	# add install-user to vboxsf group, sudoers(nopasswd)
	INSTALL_USERNAME=`ls /target/home/`
	# sudo sed -i '/vboxsf/s/vboxsf:x:111:hamonikr/vboxsf:x:111:'$INSTALL_USERNAME'/' /etc/group
	sudo touch /target/etc/sudoers.d/$INSTALL_USERNAME
	sudo echo "$INSTALL_USERNAME   ALL=NOPASSWD: /bin/hamonikr_rescue, /usr/sbin/update-grub, /bin/sed, /sbin/reboot" > /target/etc/sudoers.d/$INSTALL_USERNAME	
	sudo chmod 440 /target/etc/sudoers.d/$INSTALL_USERNAME

	# iso image copy
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "++++++++++++  HamoniKR 복구 매니저 설치  ++++++++++++"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "(1) Live 이미지를 하드디스크에 생성하고 있습니다."
	echo "    시스템에 따라 1~5분 정도 소요될 수 있습니다."
	echo "    잠시 기다려 주세요...."

	sudo mkdir -p /target/rescue/cd-image
	sudo cp -rT /cdrom /target/rescue/cd-image

	# /etc/fstab : copy to iso image
	sudo cp -af /target/etc/fstab /target/rescue/cd-image/preseed/rescue/etc/
	# iso image create
	sudo mkdir -p /target/rescue/iso
	sudo mkisofs -r -V "HamoniKR Install CD" \
	-cache-inodes -J -l -b isolinux/isolinux.bin \
	-c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
	-o /target/rescue/iso/hamonikr.iso /target/rescue/cd-image/

	# iso image copy directory remove
	sudo rm -rf /target/rescue/cd-image/ \

	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "(2) 복구 모드 부팅을 위한 부트로더를 설정합니다...."
	## grub config
	# /etc/grub.d/10_linux : HamoniKR 시작 이름 변경
	# sudo sed -i '/Linux Mint 17.3 MATE ..-bit/s/Linux Mint 17.3 MATE ..-bit/HamoniKR Start/g' /target/etc/grub.d/10_linux
	sudo sed -i '/Start Linux Mint 19 Cinnamon 64-bit/s/Start Linux Mint 19 Cinnamon 64-bit/HamoniKR Start/g' /target/boot/grub/grub.cfg	
	# /etc/default/grub : grub 보기(3초)
	#sudo sed -i '/GRUB_HIDDEN_TIMEOUT=0/s/GRUB_HIDDEN_TIMEOUT=0/#GRUB_HIDDEN_TIMEOUT=0/g' /target/etc/default/grub
	#sudo sed -i '/GRUB_HIDDEN_TIMEOUT_QUIET=true/s/GRUB_HIDDEN_TIMEOUT_QUIET=true/#GRUB_HIDDEN_TIMEOUT_QUIET=true/g' /target/etc/default/grub
	#sudo sed -i '/GRUB_TIMEOUT=../s/GRUB_TIMEOUT=../GRUB_TIMEOUT=3/g' /target/etc/default/grub
	#sudo sed -i '/#GRUB_DISABLE_RECOVERY="true"/s/#GRUB_DISABLE_RECOVERY="true"/GRUB_DISABLE_RECOVERY="true"/g' /target/etc/default/grub
	#sudo sed -i '/TUNE/a\GRUB_DISABLE_SUBMENU=y\' /target/etc/default/grub
	## /etc/grub.d/40_custom : 백업/복구/복제 모드 추가
	sudo cp -af /cdrom/preseed/rescue/etc/grub.d/40_custom /target/etc/grub.d/
	sudo chmod 755 /target/etc/grub.d/40_custom

	PART_RESCUE_HD=`sed -n '/\/rescue was on/p' /target/etc/fstab | awk '{ print $5 }' | grep -o "sd[a-z]"`    # cf) sda
	PART_RESCUE_NO=`sed -n '/\/rescue was on/p' /target/etc/fstab | awk '{ print $5 }' | sed 's/\/dev\/sd.//'` # cf) 1
	HD_NO=hd0

        if [ $PART_RESCUE_HD = "" ]; then
       	        exit 0
	elif [ $PART_RESCUE_HD = "sda" ]; then
               	HD_NO=hd0
        elif [ $PART_RESCUE_HD = "sdb" ]; then
       	        HD_NO=hd1
        elif [ $PART_RESCUE_HD = "sdc" ]; then
       	        HD_NO=hd2
        elif [ $PART_RESCUE_HD = "sdd" ]; then
       	        HD_NO=hd3
	fi
	sudo sed -i "/hd0,1/s/hd0,1/$HD_NO,$PART_RESCUE_NO/" /target/etc/grub.d/40_custom
	## /etc/grub.d/20_memtest86+ : memtest 항목 비활성화
	sudo chmod -x /target/etc/grub.d/20_memtest86+
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "복구 모드 설정이 완료되었습니다."
	echo "시스템을 재부팅하시면 하모니카를 바로 사용하실 수 있습니다."
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

else
	echo "+++++++++++++++++++++++++++++++++++++++++"
	echo "복구 파티션(/rescue)이 존재하지 않습니다."
	echo "설치 시 복구 파티션을 생성한 경우에만"
	echo "복구 모드를 사용할 수 있습니다."
	echo "+++++++++++++++++++++++++++++++++++++++++"
fi

# reboot
#reboot
