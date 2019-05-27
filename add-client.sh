#!/bin/bash

if [ $# -eq 0 ]
then
	echo "must pass a client name as an arg: add-client.sh new-client"
else
	echo "Creating client config for: $1"
	mkdir -p clients/$1
	wg genkey | tee clients/$1/$1.priv | wg pubkey > clients/$1/$1.pub
	key=$(cat clients/$1/$1.priv) 
	ip="10.201.3."$(expr $(cat last-ip.txt | tr "." " " | awk '{print $4}') + 1)
	FQDN=$(hostname -f)
	cat wg0-client-template.conf | sed -e 's/:CLIENT_IP:/'"$ip"'/' | sed -e 's|:CLIENT_KEY:|'"$key"'|' | sed -e 's|:SERVER_ADDRESS:|'"$FQDN"'|' > clients/$1/wg0.conf
	echo $ip > last-ip.txt
	echo "Created client config!"
	echo "Adding peer"
	sudo wg set wg0 peer $(cat clients/$1/$1.pub) allowed-ips $ip/32
	qrencode -t ansiutf8 < clients/$1/wg0.conf
fi
