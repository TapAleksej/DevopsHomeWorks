### Задание 1

#### добавить в cron скрипт/команду ,которая будет очищать кэш apt (кэшируемые пакеты,
#### пакеты,которые не могут быть загружены) раз в месяц в 16 часов.

`apt-get autoclean` очищает старый не используемый кэш


`0 16    1 * * root apt-get autoclean >> /home/alrex/apt_clean.log 2>> /home/alrex/apt_clean_err.log`


0 минут
16 часов
1 день месяца


```bash
# Создал 2 файла apt_clean.log (для вывода) и apt_clean_err.log для ошибок 
touch apt_clean.log apt_clean_err.log
sudo chmod 644 apt_clean.log
sudo chmod 644 apt_clean_err.log

```


Заносить в лог /var/log/apt_clean.log ошибки

## Управление для root пользователя cron

```bash
sudo nano /etc/crontab
```

```bash
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
# You can also override PATH, but by default, newer versions inherit it from the environment
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.daily; }
47 6    * * 7   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.weekly; }
52 6    1 * *   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.monthly; }
0 16    1 * * root apt-get autoclean >> /home/alrex/apt_clean.log 2>> /home/alrex/apt_clean_err.log
#

```
Проверка в логе
```alrex@ubuntu1:~/Homework$ tail -f /home/alrex/apt_clean.log

Текущее время: 10:56:01
Reading package lists...
Building dependency tree...
Reading state information...
Reading package lists...
Building dependency tree...
```
Значит чистит кэш


## Управление от текущего пользователя

#### Пример вывовда времени по расписанию через каждую минуту

Создам скрипт dr.sh 

``` bash
#!/bin/bash
echo "Текущее время: $(date '+%H:%M:%S')" >> /home/alrex/apt_clean.log
```
Делаю исполняемым
``` bash
sudo chmode +x dr.sh
```

Открвываю настройки cron для текущего пользователя
``` bash
crontab -e
```

Каждую минуту запускаю скрипт dr.sh
`*/1 * * * * bash /home/alrex/Homework/pro/dr.sh`

Смотрю в реальном времени
```bash
alrex@ubuntu1:~/Homework$ tail -f /home/alrex/apt_clean.log

Текущее время: 10:53:01
Текущее время: 10:54:01
Текущее время: 10:55:01
Текущее время: 10:56:01
```