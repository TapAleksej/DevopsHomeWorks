#!/bin/bash

if [ $(id -u) -ne 0 ]; then
	echo "not root"
	exit 1
fi

if [ $# -eq 0 ]; then
	echo "need service"
	exit 1
fi

for service in "$@"; do
	if ! systemctl cat "$service" > /dev/null 2>&1; then
	  echo "$service not exist"
	  continue
	fi

	if systemctl is-active	--quiet "$service"; then
	  echo "$service is active"
	else
		if systemctl restart "$service"; then
			sleep 5
			if systemctl is-active	--quiet "$service"; then
			  echo "$service is active"
			else
			  echo "failed to restart $service"
			fi
		else
			echo "not restart $service"
		fi
	fi
done
