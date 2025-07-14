#!/bin/bash

source .env

notify() {
  message="$1"
  bot_token=$BOT_TOKEN
  chat_id=$CHAT_ID

  curl -s -X POST "https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$chat_id&text=$message" >/dev/null
}

check_cert() {
  domain=$1
  port=443
  days_alert=${2:-80}

  end_date=$(echo | openssl s_client -connect $domain:$port -servername $domain 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
  if [ -z "$end_date" ]; then
    echo "Error: can not get certificate info for $domain"
  fi

  current_timestamp=$(date +%s)
  cert_timestamp=$(date -d "$end_date" +%s 2>/dev/null)
  seconds_left=$((cert_timestamp - current_timestamp))
  days_left=$((seconds_left / 86400))

  #echo "Certificate valid till $end_date"
  if [ $days_left -lt 0 ]; then
    msg="ERROR: Certificate expired"
    notify $msg
  else
    echo "INFO: Days till expire - $days_left"
  fi

  if [ $days_left -le $days_alert ]; then
    msg="WARNING: Certificate for $domain will be expired in $days_left"
    notify $msg
  fi
}

DOMAIN=$1
check_cert $DOMAIN
