#!/bin/bash

#Check 2 params
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <начальный_порт> <конечный_порт>"
    exit 1
fi

START_PORT=$1
END_PORT=$2


#Check bisy or not port
is_port_in_use() {
    port="$1"
    
    if ss -tuln | grep -q "$port"; then
        return 0 
    else
        return 1
    fi    
}


for (( port=START_PORT; port<=END_PORT; port++ )); do
    if ! is_port_in_use "$port"; then
        echo "Port:  $port is free"
        #if port free then stop end exit
        exit 0
    fi
done

# Else 
echo "In $START_PORT-$END_PORT free port not find." >&2
