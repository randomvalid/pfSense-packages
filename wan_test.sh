#!/bin/sh

#=====================================================================
# USER SETTINGS
#
# Set multiple ping targets separated by space.  Include numeric IPs
# (e.g., remote office, ISP gateway, etc.) for DNS issues which
# reboot will not correct.
ALLDEST="google.com www.cloudflare.com 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1"
# Interface to reset, usually your WAN
BOUNCE=igb0
#=====================================================================

COUNT=1
while [ $COUNT -le 2 ]
do
	for DEST in $ALLDEST
	do
		ping -c1 $DEST >/dev/null 2>/dev/null
		if [ $? -eq 0 ]
		then
			exit 0
		fi
	done

	if [ $COUNT -le 1 ]
	then
		logger -t wan_test "All pings failed. Resetting interface $BOUNCE."
		/sbin/ifconfig $BOUNCE down
		# Give interface time to reset before bringing back up
		sleep 10
		/sbin/ifconfig $BOUNCE up
		# Give interface time to establish connection
		sleep 60
	else
		logger -t wan_test "All pings failed twice. Rebooting..."
		/sbin/shutdown -r now
		exit 1
	fi

	COUNT=`expr $COUNT + 1`
done