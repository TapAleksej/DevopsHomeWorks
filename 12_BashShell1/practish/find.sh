#!/bin/bash
FINDSTR=$1
DIR=$2

if [ $# -eq 0 ]; then
    echo "Не указаны параметр"
    exit 1
fi

if [ -d "$DIR" ]; then
    for file in $(find "$DIR" -type f);do
#set -x      
        POS=$(grep -i ${FINDSTR} ${file}) 
        if [ -n "$POS" ]; then
            line=$(ls -lh "${file}")
            size=$(echo "$line" | awk {'print $5'})
    
            echo "${FINDSTR} найден в файле ${file}"
            echo "Размер файла ${size}"
        fi
#set +x
    done

else
    echo "Нет каталога ${DIR}"
    exit 1
fi
