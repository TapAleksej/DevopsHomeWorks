#!/bin/bash

if [ $(id -u) -ne 0 ]; then
	echo "You mast change user to root"
	exit 1
fi	

if [ $# -eq 0 ]; then
	echo "Count params is zerro. Input them"
	exit 1
fi

for service in "$@"; do
	if ! systemctl cat "$service" > /dev/null 2>&1; then
		echo "Service $service not exists" 
		continue
	fi
if systemctl is-active --quiet "$service"; then
	echo "Service $service is running"
else
	if systemctl restart "$service"; then
		sleep 5
		if systemctl is-active --quiet "$service"; then
			echo "Service $service is running"
		else
			echo "Service $service faled to restart"	
		fi	
	else
		echo "Service not restart"
	fi	
fi	
done
