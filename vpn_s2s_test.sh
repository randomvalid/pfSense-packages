#!/bin/sh

#=====================================================================
# USER SETTINGS
#
# Set multiple ping targets separated by space.  Include numeric IPs
# (e.g., remote office, ISP gateway, etc.) for DNS issues which
# reboot will not correct.
ALLDEST="dest1 dest2 dest3"
# VPN mode to reset
VPNMODE=<server/client>
# VPN ID to reset
VPNID=<integer>
# Interface to reset, usually your ovpn[c/s][n]
BOUNCE=ovpns<integer>
#=====================================================================

TestConnection () {
	for DEST in $ALLDEST
	do
		ping -c1 $DEST >/dev/null 2>/dev/null
		if [ $? -eq 0 ]
		then
			exit 0
		fi
	done
}

TestConnection

logger -t vpn_s2s_test "All pings failed. Restart VPN Service: $VPNMODE $VPNID."
/usr/local/sbin/pfSsh.php playback svc restart openvpn $VPNMODE $VPNID
# Give openvpn time to restart
sleep 60

TestConnection

logger -t vpn_s2s_test "All pings failed twice. Resetting interface $BOUNCE."
/sbin/ifconfig $BOUNCE down
# Give interface time to reset before bringing back up
sleep 10
/sbin/ifconfig $BOUNCE up
# Give interface time to establish connection
sleep 60
