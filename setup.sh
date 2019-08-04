#!/bin/sh

if [ $(pgrep asterisk) ]; then
	/etc/init.d/asterisk stop
fi

if [ -n "$1" ]; then
	if [ "$1" == "remove" ]; then
		/etc/init.d/asterisk stop
		/etc/init.d/asterisk disable

		opkg remove --force_remove asterisk18-app-system
		opkg remove --force_remove asterisk18-res-agi
		opkg remove --force_remove asterisk18
		opkg remove --force_remove asterisk13-format-pcm
		opkg remove --force_remove asterisk13-res-rtp-asterisk
		opkg remove --force_remove asterisk13-chan-sip
		opkg remove --force_remove asterisk13-res-agi
		opkg remove --force_remove asterisk13-app-system
		opkg remove --force_remove --force-removal-of-dependent-packages asterisk13-bridge-softmix
		opkg remove --force_remove --force-removal-of-dependent-packages asterisk13
		
		rm -rf /etc/asterisk
		rm -rf /usr/lib/asterisk
		rm -rf /usr/share/asterisk
		rm /etc/init.d/asterisk
		
		if [ -f /www/docroot/modals/mmpbx-contacts-modal.lp.orig ]; then
			cp /www/docroot/modals/mmpbx-contacts-modal.lp.orig /www/docroot/modals/mmpbx-contacts-modal.lp
			rm /www/docroot/modals/mmpbx-contacts-modal.lp.orig
		fi

		rm /usr/share/transformer/scripts/refresh-blacklist.lp

		exit 0
	fi
fi

opkg update
opkg install asterisk13
opkg install asterisk13-app-system
opkg install asterisk13-res-agi
opkg install asterisk13-chan-sip
opkg install asterisk13-res-rtp-asterisk
opkg install asterisk13-format-pcm

cp ./sip.conf /etc/asterisk
cp ./music.* /etc/asterisk
if [ ! -d /usr/share/asterisk/agi-bin ]; then
	mkdir /usr/share/asterisk/agi-bin
fi
cp ./smooth /usr/share/asterisk/agi-bin
cp ./sorter /etc/asterisk
PASSWORD=$(uci get mmpbxrvsipnet.sip_profile_0.password)
URI=$(uci get mmpbxrvsipnet.sip_profile_0.uri)
PRIMARY_PROXY=$(uci get mmpbxrvsipnet.sip_net.primary_proxy)
PORT=$(uci get mmpbxrvsipnet.sip_net.primary_registrar_port)
DOMAIN=$(uci get mmpbxrvsipnet.sip_net.domain_name)
USERNAME=$(uci get mmpbxrvsipnet.sip_profile_0.user_name)
sed -i 's#URI#'"$URI"'#' /etc/asterisk/sip.conf
sed -i 's#USERNAME#'"$USERNAME"'#' /etc/asterisk/sip.conf
sed -i 's#PASSWORD#'"$PASSWORD"'#' /etc/asterisk/sip.conf
sed -i 's#PRIMARY_PROXY#'"$PRIMARY_PROXY"'#' /etc/asterisk/sip.conf
sed -i 's#DOMAIN#'"$DOMAIN"'#' /etc/asterisk/sip.conf
sed -i 's#PORT#'"$PORT"'#' /etc/asterisk/sip.conf
sed -i 's#EXTENSION#'"$URI"'#' /etc/asterisk/sip.conf
#sed -i 's#;live_dangerously = no#live_dangerously = no#' /etc/asterisk/asterisk.conf
if [ ! -f /www/docroot/modals/mmpbx-contacts-modal.lp.orig ]; then
	cp /www/docroot/modals/mmpbx-contacts-modal.lp /www/docroot/modals/mmpbx-contacts-modal.lp.orig
fi

chmod +x ./refresh-blacklist.lp
cp refresh-blacklist.lp /usr/share/transformer/scripts/
cp mmpbx-contacts-modal.lp /www/docroot/modals/

sed -i 's#EXTENSION#'"$URI"'#' /usr/share/transformer/scripts/refresh-blacklist.lp 
/etc/init.d/asterisk enable   
/etc/init.d/asterisk restart                              
/usr/share/transformer/scripts/refresh-blacklist.lp

if [ -n "$1" ]; then
	if [ "$1" == "empty" ]; then
		echo Blacklist installation completed successfully: the app is active and running
		echo To import the blacklist phonebook, digit ‘./import-blacklist.sh’ from the shell
		EXTENSION="${URI/+/%2B}"
		h=$(curl -s "http://blacklist.satellitar.it/ispro.php?exten=$EXTENSION") 
		echo "$h"
	fi
fi

chmod +x ./import-blacklist.lp
./import-blacklist.lp
