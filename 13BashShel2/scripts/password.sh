#!/bin/bash

password=$1


if [ "$#" -ne 1 ]; then
    echo "Input password as parametr"
    exit 1
fi

#set -x
len="${#password}"
if [ "$len" -lt 12 ] || [ "$len" -gt 24 ]; then
    echo "Length of passport must be between 12 and 24 symbols."
    exit 1
fi

if ! [[ "$password" =~ [0-9] ]]; then
    echo "Password must have min one number"
    exit 1
fi

if ! [[ "$password" =~ [A-Z] && "$password" =~ [a-z] ]]; then
    echo "Password must contain upper and lower letters."
    exit 1
fi

if ! [[ "$password" =~ [\!\@\#\$\%\^\&\*] ]]; then
    echo "Password must have some symbols !@#$%^&*"
    exit 1
fi

echo "Password is passed"
#set +x
