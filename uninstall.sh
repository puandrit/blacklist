#!/bin/sh
/etc/init.d/asterisk stop
/etc/init.d/asterisk disable

opkg update
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

if [ -f /etc/opkg/customfeeds.conf.orig ]; then
	cp /etc/opkg/customfeeds.conf.orig /etc/opkg/customfeeds.conf
fi
if [ -f /www/docroot/modals/mmpbx-contacts-modal.lp.orig ]; then
	cp /www/docroot/modals/mmpbx-contacts-modal.lp.orig /www/docroot/modals/mmpbx-contacts-modal.lp
	rm /www/docroot/modals/mmpbx-contacts-modal.lp.orig
fi
if [ -f /etc/sudoers.orig ]; then
	cp /etc/sudoers.orig /etc/sudoers
fi
rm /www/docroot/modals/mmpbx-blacklist.lp
chmod 755 /usr/bin/sudo