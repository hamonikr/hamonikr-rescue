#!/bin/bash
# Backup and Restore Program for HamoniKR Desktop Linux (HamoniKR)
# Copyright (C) 2015-2019 HamoniKR Team, Kevin Kim
# This file may be used under the terms of the GNU General Public License, version 2 or later.
# For more details see: https://www.gnu.org/licenses/gpl-2.0.html

# rescue check
RESCUE_CHECK=`cat /proc/cmdline | awk '{print $9}'`
if [ "$RESCUE_CHECK" != "install" ] && [ "$RESCUE_CHECK" != "backup" ] && [ "$RESCUE_CHECK" != "restore" ] && [ "$RESCUE_CHECK" != "server" ] && [ "$RESCUE_CHECK" != "client" ] && [ "$RESCUE_CHECK" != "Start" ] ; then
	exit 0
fi

# /isodevice umount
sudo umount -l -r -f /isodevice

## target OS mount
# /rescue 존재 유무 및 rescue mode 정보 확인
FSTAB_PATH=/cdrom/preseed/rescue/etc/fstab
CMDLINE_ACTION=`cat /proc/cmdline | awk '{print $9}'`
CMDLINE_ACTION_QUICK=`cat /proc/cmdline | awk '{print $10}'`
RESCUE=`sed -n '/rescue/p' $FSTAB_PATH | sed -n '/UUID/p' | awk '{ print $2 }'`
PART_ROOT=`sed -n '/installation/p' $FSTAB_PATH | sed -n '/\/ /p' | awk '{ print $5 }'`
PART_RESCUE=`sed -n '/installation/p' $FSTAB_PATH | sed -n '/\/rescue/p' | awk '{ print $5 }'`
PART_ROOT_HD=`sed -n '/\/ was on/p' $FSTAB_PATH | awk '{ print $5 }' | grep -o "sd[a-z]"`    # cf) sda
PART_BOOT_CHK=`sed -n '/installation/p' $FSTAB_PATH | sed -n '/\/boot /p' | awk '{ print $2 }'`
if [ "$PART_BOOT_CHK" != "/boot" ]; then
	PART_BOOT_FDISK=`sed -n '/installation/p' $FSTAB_PATH | sed -n '/\/ /p' | awk '{ print $5 }'`
else
	PART_BOOT_FDISK=`sed -n '/installation/p' $FSTAB_PATH | sed -n '/\/boot /p' | awk '{ print $5 }'`
fi
## Install exec
exec_install ()
{
	# installer start
	sudo sh -c 'ubiquity gtk_ui'

	# grub reset
        if [ ! -d /target ]; then
                sudo mkdir /target
        fi
	        sudo mount $PART_BOOT_FDISK /target
        if [ ! -d /target/boot ]; then
                sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/grub/grub.cfg
        else
        sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/boot/grub/grub.cfg
        fi
        sudo umount /target
        echo "--------------------------------------------"
        echo "Boot loader setting (set default=0)"
        echo "--------------------------------------------"
        sleep 2
	exit 0
#        sudo reboot
}

## Rescue exec
exec_backup ()
{
        echo "++++++++++++++++++++++++++++++++++++++++++++"
        echo "[Backup] root(/) 파티션의 백업을 시작합니다."
        echo "   백업이 종료되면 자동으로 재시작됩니다."
        echo "   작업이 종료될때까지 터미널을 닫지 마세요."
        echo "++++++++++++++++++++++++++++++++++++++++++++"
	sleep 5

        # backup
        sudo mkdir /rescue
        sudo mount $PART_RESCUE /rescue
        if [ ! -d /rescue/backup ]; then
                sudo mkdir /rescue/backup
        fi

        # TUI 구성 및 backup 수행
	if [ "$CMDLINE_ACTION_QUICK" != "quick" ]; then
        dialog --backtitle "HamoniKR Rescue v1.0" \
                --title "하모니카 백업 안내" \
                --infobox "\n현재 시스템은 아래 설정으로 자동 백업됩니다.\n
백업이 종료되면 자동으로 재시작됩니다.\n
작업이 종료될때까지 프로그램을 닫지 마십시오.\n
기타 세부 사항은 매뉴얼을 참고바랍니다.\n
\n
  - 백업 대상 : root(/) 파티션 ($PART_ROOT)\n
  - 백업 저장 : /rescue 파티션 ($PART_RESCUE)\n
  - 저장 경로 : /rescue/backup/hamonikr.fsa\n
\n
※ 주의 사항\n
  - 기존 백업파일이 있는 경우, 동일한 이름으로 덮어씁니다.\n
    ( 5초 후에 자동으로 백업을 시작합니다. )" 16 70 ; sleep 5
        sudo fsarchiver savefs /rescue/backup/hamonikr.fsa $PART_ROOT -v -o 2>&1 | \
	grep -o ".[0-9]0%" | cut -f1 -d '%' | \
        dialog --backtitle "HamoniKR Rescue v1.0" \
                --title "하모니카 백업 진행 현황" \
                --gauge "\n  [$PART_ROOT] 파티션 백업 중..." 8 60
        dialog --backtitle "HamoniKR Rescue v1.0" \
                --title "백업 완료" \
                --infobox "\n백업이 완료되었습니다.\n
5초 후 프로그램이 종료됩니다." 5 60 ; sleep 5
	else
		sudo fsarchiver savefs /rescue/backup/hamonikr.fsa $PART_ROOT -o
	fi
        sudo umount /rescue

        # grub reset
        if [ ! -d /target ]; then
                sudo mkdir /target
        fi
        sudo mount $PART_BOOT_FDISK /target
	if [ ! -d /target/boot ]; then
                sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/grub/grub.cfg
        else
        sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/boot/grub/grub.cfg
	fi
        sudo umount /target
        echo "--------------------------------------------"
        echo "백업이 완료되었습니다. 5초 후 재부팅 합니다."
        echo "--------------------------------------------"
	sleep 5
        sudo reboot
}

exec_restore ()
{
        echo "+++++++++++++++++++++++++++++++++++++++++++++"
        echo "[Restore] root(/) 파티션의 복구를 시작합니다."
        echo "   복구가 종료되면 자동으로 재시작됩니다."
        echo "   작업이 종료될때까지 터미널을 닫지 마세요."
        echo "+++++++++++++++++++++++++++++++++++++++++++++"
	sleep 5
        # restore
        sudo mkdir /rescue
        sudo mount $PART_RESCUE /rescue
        if [ ! -d /rescue/backup ] && [ ! test -e /rescue/backup/hamonikr.fsa ] ; then
                echo "--------------------------------------------"
                echo "백업한 데이터가 존재하지 않습니다."
                echo "정상 부팅한 뒤, 백업 명령을 실행해 주십시오."
                echo "예: $ hamonikr_rescue backup"
                echo "--------------------------------------------"
		sleep 5
        	if [ ! -d /target ]; then 
                	sudo mkdir /target
	        fi
        	sudo mount $PART_ROOT /target
	        sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/boot/grub/grub.cfg
	        sudo umount /target
        	sudo reboot
        fi

        # TUI 구성
	if [ "$CMDLINE_ACTION_QUICK" != "quick" ]; then
        dialog --backtitle "HamoniKR Rescue v1.0" \
                --title "하모니카 복구 안내" \
                --infobox "\n현재 시스템은 아래 설정으로 자동 복구됩니다.\n
복구가 종료되면 자동으로 재시작됩니다.\n
작업이 종료될때까지 프로그램을 닫지 마십시오.\n
기타 세부 사항은 매뉴얼을 참고바랍니다.\n
\n
  - 복구 대상 : root(/) 파티션 ($PART_ROOT)\n
  - 복구 원본 : /rescue/backup/hamonikr.fsa\n
\n
※ 주의 사항\n
  - root 파티션의 기존 데이터는 모두 삭제되며,\n
  - 과거 백업받은 시점의 데이터로 복구됩니다.\n
    ( 5초 후에 자동으로 복구를 시작합니다. )" 16 70 ; sleep 5 
        sudo fsarchiver restfs /rescue/backup/hamonikr.fsa id=0,dest=$PART_ROOT -v 2>&1 | \
	grep -o ".[0-9]0%" | cut -f1 -d '%' | \
        dialog --backtitle "HamoniKR Rescue v1.0" \
                --title "하모니카 복구 진행 현황" \
                --gauge "\n  [$PART_ROOT] 파티션 복구 중..." 8 60
        dialog --backtitle "HamoniKR Rescue v1.0" \
                --title "복구 완료" \
                --infobox "\n복구가 완료되었습니다.\n
5초 후 프로그램이 종료됩니다." 5 60 ; sleep 5
	else
		sudo fsarchiver restfs /rescue/backup/hamonikr.fsa id=0,dest=$PART_ROOT
	fi
        sudo umount /rescue

        # grub reset
        if [ ! -d /target ]; then
                sudo mkdir /target
        fi
        sudo mount $PART_BOOT_FDISK /target
	if [ ! -d /target/boot ]; then
                sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/grub/grub.cfg
        else
        sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/boot/grub/grub.cfg
	fi
        sudo umount /target
        echo "--------------------------------------------"
        echo "복구가 완료되었습니다. 5초 후 재부팅 합니다."
        echo "--------------------------------------------"
	sleep 5
        sudo reboot
}

exec_server ()
{
        echo "++++++++++++++++++++++++++++++++++++++++++++"
        echo "[Multicast] Server 모드로 복제를 전송합니다."
	echo "--------------------------------------------"
        echo "Client가 모두 준비되면 아무키나 누르세요."
	echo "--------------------------------------------"

        # udp-sender
	if [ "$CMDLINE_ACTION_QUICK" != "all" ]; then
	        sudo udp-sender --full-duplex --pipe "lzop" --file $PART_ROOT		# / partition transfer
		#sudo mkdir /rescue
		#sudo mount $PART_RESCUE /rescue
        	#sudo udp-sender --full-duplex --file /rescue/backup/hamonikr.fsa	# backup image transfer
		#sudo umount /rescue
	else
		sudo fdisk -l | sed -n '/Disk \/dev/p' | grep -o "/dev/sd[a-z]" > /tmp/device_name
		PART_HD=`cat /tmp/device_name | sed -n '1p'`			# cf) /dev/sda
		sudo udp-sender --full-duplex --pipe "lzop" --file $PART_HD	# all partition transfer
	fi

        # grub reset
        if [ ! -d /target ]; then
                sudo mkdir /target
        fi
        sudo mount $PART_BOOT_FDISK /target
	if [ ! -d /target/boot ]; then
                sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/grub/grub.cfg
        else
        sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/boot/grub/grub.cfg
	fi
        sudo umount /target
        echo "--------------------------------------------"
        echo "복제가 완료되었습니다. 5초 후 재부팅 합니다."
        echo "--------------------------------------------"
        sleep 5
        sudo reboot
}

exec_client ()
{
        echo "++++++++++++++++++++++++++++++++++++++++++++"
        echo "[Multicast] Client 모드로 복제를 수행합니다."
	echo "--------------------------------------------"
	echo "Server에서 복제를 시작할때까지 기다려주세요."
	echo "--------------------------------------------"

        # udp-receiver
        if [ "$CMDLINE_ACTION_QUICK" != "all" ]; then
	        sudo udp-receiver --pipe "lzop -d" --file $PART_ROOT               # / partition receiver
		#sudo mkdir /rescue
		#sudo mount $PART_RESCUE /rescue
        	#sudo udp-receiver --pipe --file /rescue/backup/hamonikr.fsa       # backup image receiver
		#sudo umount /rescue
        else
		sudo fdisk -l | sed -n '/Disk \/dev/p' | grep -o "/dev/sd[a-z]" > /tmp/device_name
                PART_HD=`cat /tmp/device_name | sed -n '1p'`		# cf) /dev/sda
	        sudo udp-receiver --pipe "lzop -d" --file $PART_HD	# all partition receiver
        fi

        # grub reset
        if [ ! -d /target ]; then
                sudo mkdir /target
        fi
        sudo mount $PART_BOOT_FDISK /target
	if [ ! -d /target/boot ]; then
                sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/grub/grub.cfg
        else
        sudo sed -i '/set default="."/s/set default="."/set default="0"/g' /target/boot/grub/grub.cfg
	fi
        sudo umount /target
        echo "--------------------------------------------"
        echo "복제가 완료되었습니다. 5초 후 재부팅 합니다."
        echo "--------------------------------------------"
        sleep 5
        sudo reboot
}

if [ x"$RESCUE" == x"/rescue" ]; then
        echo "++++++++++++++++++++++++++++++++++++++++++++"
	echo "하모니카 Rescue mode를 시작합니다."
	
	if   [ x"$CMDLINE_ACTION" == x"" ]; then
		exit 0
	elif [ x"$CMDLINE_ACTION" == x"install" ]; then
		exec_install
	elif [ x"$CMDLINE_ACTION" == x"backup" ]; then
		exec_backup
	elif [ x"$CMDLINE_ACTION" == x"restore" ]; then
		exec_restore
	elif [ x"$CMDLINE_ACTION" == x"server" ]; then
		exec_server
	elif [ x"$CMDLINE_ACTION" == x"client" ]; then
		exec_client
	fi
else
	exit 0
fi
