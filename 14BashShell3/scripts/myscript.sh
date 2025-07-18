#!/bin/bash
exec 5> debug_output.txt
BASH_XTRACEFD="5"
PS4='$LINENO: '
set -x
var="Привет мир"
# печать
echo "$var"
# альтернативный способ печати
printf "%s\n" "$var"
set +x
echo "Мой дом - это: $HOME"
