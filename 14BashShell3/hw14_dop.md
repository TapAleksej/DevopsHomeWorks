### сделал для удобства отправки гит

постоянно добавлять git add . git commit  pull push
иногда не нужно придумывать в комите коментарий - сгенерирует сам

~/.bashrc
```
alias upgt='~/Homework/DevopsHomeWorks/auto_commit.sh'
```

auto_commit.sh
```
#!/usr/bin/env bash
# set -o pipefail
# set -x

git add .

last_hash=$(git log --oneline | head -1 | awk '{print $1}')

echo "Примечание commit"
read comit

if [ ! "$comit" = "" ]; then
        git commit -m "$comit"
else
        git commit -m "autocommit_${last_hash}"
fi


echo "return code  $?"
chk=$(git log --oneline | head -2)

echo "$chk"

echo "Сделать отправку на гитхаб? y/n"
read answer

answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
  git pull

  if [ $? -eq 0 ]; then
    git push
  else
    echo "Ошибка при git pull"
    exit 1
  fi
elif [ "$answer" = "n" ] || [ "$answer" = "no" ]; then
  echo "Операция отменена."
  exit 0
else
  echo "Неверный ввод. Введите 'y' или 'n'."
  exit 1
fi
```



### Создать скрипт для мониторинга активных SSH-сессий с оповещением о подозрительной активности. 

Требования: 
- Выводит список пользователей с >2 активными сессиями 

```
who
alrex    pts/0        2025-07-17 10:31 (192.168.50.108)
oleg     pts/1        2025-07-17 10:44 (192.168.50.108)
oleg     pts/2        2025-07-17 10:46 (192.168.50.108)
oleg     pts/3        2025-07-17 10:48 (192.168.50.108)
oleg     pts/5        2025-07-17 10:59 (192.168.50.108)

who | awk '{print $1}' | sort | uniq -c

 1 alrex
 4 oleg
```


log_analiz.sh
```
#!/usr/bin/env bash

ssh_sessions=$(who | awk '{print $1}' | sort | uniq -c)


echo "$ssh_sessions" | while read -r count user; do
  if (( count > 2 )); then
    echo "User $user have $count active sessions"
  fi
done



./log_analiz.sh
User oleg have 4 active sessions
```

Или красивее однострочник
```
who | awk '{print $1}' | sort  | uniq -c | awk '$1 > 2'

# 4 oleg
```


- Проверяет подключения с недоверенных IP (из файла blocklist.txt) 

blocklist.txt
```
192.168.50.12
192.168.50.15
192.168.50.108
192.168.1.25
```

- Логирует подозрительные события в /var/log/auth_audit.log 


Формат лога:
[Дата] [Пользователь] [IP] [Кол-во сессий]


sudo touch /var/log/auth_audit.log
sudo chown alrex:alrex /var/log/auth_audit.log

bad_ipssh.sh
```
#!/usr/bin/env bash

#set -x
LOGFILE="/var/log/auth_audit.log"
filename="blocklist.txt"

active_ssh_ip=$(who | sed 's/[()]//g' | awk '{print $3,  $1,  $5'} | uniq -c | awk '{ print $2,":",$3,":",$4,":"$1}')

#echo "$active_ssh_ip"
for ip in $(cat "$filename");do
    if echo "$active_ssh_ip" | grep -q "$ip"; then
        echo "$active_ssh_ip" | grep "$ip" >> "$LOGFILE"
    fi
done

cat "$LOGFILE"

```
На выходе [Дата] [Пользователь] [IP] [Кол-во сессий]

```
./bad_ipssh.sh               

2025-07-18 : alrex : 192.168.50.108 :2
2025-07-18 : oleg : 192.168.50.108 :1

```


### Создать скрипт для резервного копирования PostgreSQL
Написать скрипт, для деплоя лендинга https://gitlab.com/dos-26/cmdb/frontend и скрипт для его проверки
 -- вот тут сложности -- как деплоят ?


### Написать скрипт для мониторинга даты продления доменного имени 
http://books.anestesia.fun/
Информация о домене через `whois`
```
sudo apt install whois
```

check_date_domen.sh
```
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
```
Проверка
```
./check_date_domen.sh
set date < 30 days before expired domain? y/n
n
Dont warry.

./check_date_domen.sh
set date < 30 days before expired domain? y/n
y
ALERT: Your domain anestesia.fun expired after 24 days!!

```