#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "No parametrs. Input some site with backspase"
    exit 1
fi


check_site() {
    local site="$1"

    # Add http if not exist in begin 
    if [[ ! "$site" =~ ^https?:// ]]; then
        site="http://$site"
    fi

    # Get response
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$site")

    # Проверяем, попадает ли код в диапазон 2xx или 3xx
    if [[ "$http_code" =~ ^(2|3)[0-9]{2}$ ]]; then
        echo "[OK] Site $site active (HTTP $http_code)"
    else
        echo "[FAIL] Site $site failed (HTTP $http_code)"
    fi
}

# In array substitute sites
for site in "$@"; do
    check_site "$site"
done
