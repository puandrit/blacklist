#!/bin/sh
if [ $(pgrep asterisk) ]; then
	/etc/init.d/asterisk stop
fi
MODEM=$(uci get env.var.prod_friendly_name)
if [ ! -f /www/docroot/modals/mmpbx-contacts-modal.lp ]; then
        if [ "$1" != "gui" ]; then
		echo An unblocked GUI is required: launch ‘./install.sh gui’ to install it
                exit 0
        else
		echo An unblocked GUI is required: I’m installing it...
                if [ "$MODEM" == "DGA4130" ]; then
                    wget -P /tmp http://dga4132.tk/dga4130_unlocked.tar.gz
                    tar -zxvf /tmp/dga4130_unlocked.tar.gz -C /
                else
                    wget -P /tmp http://dga4132.tk/dga4132_unlocked.tar.gz
                    tar -zxvf /tmp/dga4132_unlocked.tar.gz -C /
                fi
        fi
fi
if [ ! -f /etc/opkg/customfeeds.conf.orig ]; then
	cp /etc/opkg/customfeeds.conf /etc/opkg/customfeeds.conf.orig
fi
cp ./customfeeds.conf /etc/opkg/customfeeds.conf
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
if [ ! -f /etc/sudoers.orig ]; then
	cp /etc/sudoers /etc/sudoers.orig
fi
cp mmpbx-blacklist.lp /www/docroot/modals/
cp mmpbx-contacts-modal.lp /www/docroot/modals/
cp sudoers /etc/
chmod 4755 /usr/bin/sudo
sed -i 's#EXTENSION#'"$URI"'#' /www/docroot/modals/mmpbx-blacklist.lp 
/etc/init.d/asterisk enable   
/etc/init.d/asterisk restart                              
/usr/bin/lua /www/docroot/modals/mmpbx-blacklist.lp
echo Blacklist installation completed successfully: the app is active and running
echo To import the blacklist phonebook, digit ‘./import-blacklist.sh’ from the shell
EXTENSION="${URI/+/%2B}"
h=$(curl -s "http://blacklist.satellitar.it/ispro.php?exten=$EXTENSION") 
echo "$h"