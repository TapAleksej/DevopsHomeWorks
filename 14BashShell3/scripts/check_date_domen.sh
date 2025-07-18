#!/usr/bin/env bash

DAYS_BEFORE_END=30
DOMEN="anestesia.fun"

echo "set date < 30 days before expired domain? y/n"
read answer

if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
	NOW=$(date -d "2026-01-25" +%s)
else 
	NOW=$(date +"%s")
fi

DATA_END=$(whois "anestesia.fun" |grep -i expiry | awk '{print $4}' | cut -d'T' -f1)
DATA_END=$(date -d "$DATA_END" +"%s")


if [ -z $DATA_END ]; then
  echo "error get expired date domain"
  exit 1
fi

DAYS_LEFT=$(( (DATA_END - NOW) / 86400 ))

if [ $DAYS_LEFT -le $DAYS_BEFORE_END ]; then
        echo "ALERT: Your domain $DOMEN expired after $DAYS_LEFT days!!"
else
        echo "Dont warry."
fi
