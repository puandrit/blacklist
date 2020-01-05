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
			mv /www/docroot/modals/mmpbx-contacts-modal.lp.orig /www/docroot/modals/mmpbx-contacts-modal.lp
		fi

		rm /usr/share/transformer/scripts/refresh-blacklist.lp
		rm /usr/share/transformer/mappings/rpc/mmpbx.blacklist.map

		sed -i '/nobody ALL=(root) NOPASSWD: \/usr\/bin\/lua/d' /etc/sudoers

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
PASSWORD=$(uci get mmpbxrvsipnet.@profile[0].password)
URI=$(uci get mmpbxrvsipnet.@profile[0].uri)
USERNAME=$(uci get mmpbxrvsipnet.@profile[0].user_name)
PRIMARY_PROXY=$(uci get mmpbxrvsipnet.@network[0].primary_proxy)
REGISTRAR=$(uci get mmpbxrvsipnet.@network[0].primary_registrar)
REALM=$(uci get mmpbxrvsipnet.@network[0].realm)
PORT=$(uci get mmpbxrvsipnet.@network[0].primary_registrar_port)
DOMAIN=$(uci get mmpbxrvsipnet.@network[0].domain_name)
sed -i 's#URI#'"$URI"'#g' /etc/asterisk/sip.conf
sed -i 's#USERNAME#'"$USERNAME"'#g' /etc/asterisk/sip.conf
sed -i 's#PASSWORD#'"$PASSWORD"'#g' /etc/asterisk/sip.conf
sed -i 's#PRIMARY_PROXY#'"$PRIMARY_PROXY"'#g' /etc/asterisk/sip.conf
sed -i 's#REGISTRAR#'"$REGISTRAR"'#g' /etc/asterisk/sip.conf
sed -i 's#REALM#'"$REALM"'#g' /etc/asterisk/sip.conf
sed -i 's#DOMAIN#'"$DOMAIN"'#g' /etc/asterisk/sip.conf
sed -i 's#PORT#'"$PORT"'#g' /etc/asterisk/sip.conf
#sed -i 's#;live_dangerously = no#live_dangerously = no#g' /etc/asterisk/asterisk.conf
if [ ! -f /www/docroot/modals/mmpbx-contacts-modal.lp.orig ]; then
	cp /www/docroot/modals/mmpbx-contacts-modal.lp /www/docroot/modals/mmpbx-contacts-modal.lp.orig
fi

cp mmpbx.blacklist.map /usr/share/transformer/mappings/rpc/
cp refresh-blacklist.lp /usr/share/transformer/scripts/
chmod +x /usr/share/transformer/scripts/refresh-blacklist.lp

cp mmpbx-contacts-modal.lp /www/docroot/modals/

sed -i 's#EXTENSION#'"$URI"'#g' /usr/share/transformer/scripts/refresh-blacklist.lp
/etc/init.d/asterisk enable
/etc/init.d/asterisk restart

if [ -n "$1" ]; then
	if [ "$1" == "empty" ]; then
		echo Blacklist installation completed successfully: the app is active and running
		echo To import the blacklist phonebook, digit './import-blacklist.sh' from the shell
		EXTENSION="${URI/+/%2B}"
		h=$(curl -s "http://blacklist.satellitar.it/ispro.php?exten=$EXTENSION") 
		echo "$h"
	fi
fi

chmod +x ./import-blacklist.lp
./import-blacklist.lp

bash -c "sleep 10; /etc/init.d/transformer restart" & /etc/init.d/nginx restart
