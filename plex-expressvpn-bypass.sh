#!/bin/bash

# Author: https://github.com/costaht/
#
# Instructions:
#		After saving this file, change its permissions in order to make it executable. 
#		Commands: chmod +x plex-expressvpn-bypass.sh
#			  ./plex-expressvpn-bypass.sh
#
# This script was tested on Fedora 31 only, but it should work in most of Linux distributions.

connected=`expressvpn status | grep Connected`

if [ -z "$connected" ]; then
	echo -e "\e[31mNo VPN connections detected. Connecting before continue...\e[0m "
	expressvpn connect
	sleep 2
else
	echo "Connected to: $connected"
fi

echo -e "\n\e[32mAdding firewall rules and routing entries to by-pass Express VPN\e[0m"

my_gw=`ip route show | grep default | awk '{print $3}'`
ip_list=`dig -4 +short my.plexapp.com plexapp.com plex.tv app.plex.tv | grep -v cdn && curl -s https://s3-eu-west-1.amazonaws.com/plex-sidekiq-servers-list/sidekiqIPs.txt`
# Adding firewall rules and route entries to by-pass Express VPN
for plex_ip in $ip_list; 
 do
	sudo iptables -A xvpn_ks_ip_exceptions -d $plex_ip -j ACCEPT
	sudo route add -host $plex_ip gw $my_gw > /dev/null 2>&1
done
echo -e "Done. \nEnjoy your \e[40mPLE\e[1;33mX\e[0m"
