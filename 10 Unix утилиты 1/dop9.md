# Пользователи и права доступа
#### Создать директорию /var/www/server-app; 
в ней файлы readme.md и app.log; директорию uploads
```
sudo mkdir /var/www/server-app
sudo touch /var/www/server-app/readme.md /var/www/server-app/app.log
sudo mkdir /var/www/server-app/uploads

ls -l /var/www/server-app
total 4
-rw-r--r-- 1 root root    0 Jul  1 08:28 app.log
-rw-r--r-- 1 root root    0 Jul  1 08:28 readme.md
drwxr-xr-x 2 root root 4096 Jul  1 08:31 uploads
```
Создать:
группу ftpusers
группу admins
группу auditors

```
sudo addgroup ftpusers
	info: Selecting GID from range 1000 to 59999 ...
	info: Adding group `ftpusers' (GID 1001) ...
sudo addgroup admins
	info: Selecting GID from range 1000 to 59999 ...
	info: Adding group `admins' (GID 1002) ...
sudo addgroup auditors
	info: Selecting GID from range 1000 to 59999 ...
	info: Adding group `auditors' (GID 1003) ...
```
#### пользователя logger с домашней директорией /opt/logger 
```
sudo useradd -m -d /opt/logger logger
```

#### без возможности входа в систему

```
sudo vim /etc/passwd

logger:x:1001:1004::/opt/logger::/bin/bash
меняем на 
logger:x:1001:1004::/opt/logger:/usr/sbin/nologin
```

#### Разрешить с помощью ACL:
инициализация
```
mkdir uploads
# права на папку
getfacl uploads

	# file: uploads
	# owner: alrex
	# group: alrex
	user::rwx
	group::rwx
	other::r-x
```


пользователю www-data чтение всех файлов
```
setfacl -m u:www-data:rX uploads/

# права на папку
getfacl uploads

# user:www-data:r-x
```


группе ftpusers запись в uploads
```
# Права на запись и соответственно чтение для ftpusers
setfacl -m g:ftpusers:rwX uploads/

getfacl uploads
#  group:ftpusers:rwx
```

группе admins полный доступ
```
setfacl -m g:admins:rwxX uploads/

getfacl uploads                 
# group:admins:rwx	
```

### app.log

```bash
getfacl var/www/server-app/app.log

# file: var/www/server-app/app.log
# owner: root
# group: root
user::rw-
group::r--
other::r--
```


пользователю logger полный доступ только к файлу app.log
```
sudo setfacl -m u:logger:rwxX /var/www/server-app/app.log
```

группе auditors чтение файла app.log
```
sudo setfacl -m g:auditors:rX /var/www/server-app/app.log
```
Результат
```
getfacl /var/www/server-app/app.log

# file: var/www/server-app/app.log
# owner: root
# group: root
user::rw-
user:logger:rwx
group::r--
group:auditors:r-x
mask::rwx
other::r--
```


## umask

Получим начальное значение
```
umask
# 0002
```

Настроить систему так, чтобы новые файлы создавались с правами rw-r-----, а директории - rwxr-x---

Для директории надо получить
rwxr-x--- (750)   
777-750 = 027
файл 
rw-r----- (640)
666-640 = 026
Установим и проверим

```
umask 027 & rm mydir/file & rm -r mydir/u1
touch mydir/file & mkdir mydir/u1 & ls -l mydir/

026
-rw-r----- 1 alrex alrex    0 Jul  2 08:38 file
drwxr-x--x 2 alrex alrex 4096 Jul  2 08:38 u1


027
-rw-r----- 1 alrex alrex    0 Jul  2 08:24 file
drwxr-x--- 2 alrex alrex 4096 Jul  2 08:24 u1

```
Все *OK*, но работает только на `027` 

Important

не забудьте восстановить исходное состояние системы после проверки

Вернём назад

```
umask 0002
ls -l mydir/

-rw-rw-r-- 1 alrex alrex    0 Jul  2 08:29 file
drwxrwxr-x 2 alrex alrex 4096 Jul  2 08:29 u1

```


## SU



Разрешить пользователю logger вход в систему; 
```
sudo vim /etc/passwd


 
logger:x:1001:1004::/opt/logger:/usr/sbin/nologin
меняем на
logger:x:1001:1004::/opt/logger::/bin/bash
```

переключиться на него с помощью su, 
```
su logger
# passwd =
```
сохранив текущее окружение и создать файл /tmp/logger-envs и вывести в него переменные окружения. 
```
env > /tmp/logger-envs

```

Выйти и переключиться еще раз с -; 
```
exit
su - logger
# переклюился ка вошёл под пользователем
#logger@ubuntu1:~$
```
сравнить вывод env и содержимое файла /tmp/logger-envs

Первый вариант содержит строки подключения по SSH
```
SSH_CONNECTION=192.168.50.108 58228 192.168.50.34 1234
SSH_CLIENT=192.168.50.108 58228 1234

Во 2 варианте этого нет

И разница в домашних директориях

PWD=/home/alrex/Homework/DevopsHomeWorks/10 Unix утилиты 1/practice

2 вариант
PWD=/opt/logger

```

Без переключения пользователя создать от имени logger директорию /tmp/logger-dir

```
mkdir /tmp/logger-dir
```

## Анализ производительности
Warning

будьте осторожны, при выполнении можно неслабо "приложить" машину

Определите текущую load average; установить пакет sysstat
```
sudo apt upgrade
sudo apt install sysstat
sudo apt install stress-ng
sudo apt install dstat
```
Запустить стресс-тест с помощью утилиты stress-ng:
stress-ng --cpu 4 --timeout 600
stress-ng --vm 2 --vm-bytes 2G --timeout 300 & stress-ng --vm 1 --vm-bytes 1G --timeout 300 -s 1


Понаблюдать за тем что показывают утилиты
dstat -cglmns --top-cpu --top-mem --top-io

при запуске 
```
stress-ng --vm 2 --vm-bytes 2G --timeout 300 &
stress-ng --vm 1 --vm-bytes 1G --timeout 300 -s 1
```
Показывает наиболее дорогие
![image](https://github.com/user-attachments/assets/e8c4ae32-b18f-4eba-9d01-c645bcc7c448)
При `stress-ng --cpu 4 --timeout 600`
![image](https://github.com/user-attachments/assets/78ca49cf-b62a-40d9-a315-9952a2c3bb84)



Запустить dd if=/dev/zero of=/tmp/testfile bs=1M count=5000 

mpstat -P ALL 2
где 2 - повторение через 2 сек.



Показал изменение %sys (системные процессы), %iowait (дисковые)

```
12:06:16 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
12:06:18 PM  all    0.26    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.74
12:06:18 PM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
12:06:18 PM    1    0.54    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.46

* * * 
12:06:56 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
12:06:58 PM  all    0.53    0.00   16.45   81.17    0.00    1.86    0.00    0.00    0.00    0.00
12:06:58 PM    0    0.51    0.00   12.82   86.67    0.00    0.00    0.00    0.00    0.00    0.00
12:06:58 PM    1    0.55    0.00   20.33   75.27    0.00    3.85    0.00    0.00    0.00    0.00

12:06:58 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
12:07:00 PM  all    0.00    0.00    9.28   85.94    0.00    2.39    0.00    0.00    0.00    2.39
12:07:00 PM    0    0.00    0.00    9.23   89.74    0.00    0.51    0.00    0.00    0.00    0.51
12:07:00 PM    1    0.00    0.00    9.34   81.87    0.00    4.40    0.00    0.00    0.00    4.40
```
'%steal' - проблемы с гипервизором



* не работает wmstat *
```
sudo apt update 
sudo apt install procps
```

Смотрим кто ест ресурсы 
```
ps aux --sort=%mem | head -10
sudo iotop
```

и параллельно с помощью iostat найти
устройство с максимальной нагрузкой

%util диска
await (среднее время ожидания)

```
iostat 2

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.91    0.00   97.25    0.85    0.00    0.00

iostat -hdx 2

 w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz Device
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop0
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop1
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop10
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop11
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop12
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop13
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop14
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop2
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop3
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop4
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop5
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop6
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop7
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop8
    0.00      0.0k     0.00   0.0%    0.00     0.0k loop9
    7.50     60.0k     7.50  50.0%    1.00     8.0k sda

```
Видно , что нагрузка идёт на диск sda

`iostat -hdx 2`
`-h` human
'-d'  Display the device utilization report.
`-x`  Display extended statistics.




сгенерировать нагрузку с помощью stress-ng и dd 
и проанализировать постфактум с помощью atop и sar (то есть условно 5 минут понагружали, 
сняли нагрузку и анализируем что там было)

Самостоятельно изучить такие утилиты как atop и sar; 



`sar 2` - каждые 2 сек - видно %system службы системные начали возрастать по нагрузке
```
12:37:50 PM     CPU     %user     %nice   %system   %iowait    %steal     %idle
12:37:52 PM     all      0.26      0.00      0.78      0.00      0.00     98.96
12:37:54 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
12:37:56 PM     all      0.26      0.00      0.00      0.00      0.00     99.74
12:37:58 PM     all      0.00      0.00      0.26      0.00      0.00     99.74
12:38:00 PM     all      0.26      0.00      0.26      0.00      0.00     99.48
12:38:02 PM     all      0.00      0.00      0.00      0.00      0.00    100.00
12:38:04 PM     all      0.26      0.00      0.00      1.03      0.00     98.71
12:38:06 PM     all      0.00      0.00      0.52      0.00      0.00     99.48
12:38:08 PM     all      0.00      0.00      1.04      0.00      0.00     98.96
12:38:10 PM     all      4.55      0.00      6.95     54.01      0.00     34.49
12:38:12 PM     all     16.25      0.00     81.75      2.00      0.00      0.00
12:38:15 PM     all      9.09      0.00     90.55      0.18      0.00      0.18
12:38:17 PM     all     26.57      0.00     73.43      0.00      0.00      0.00
12:38:19 PM     all     17.34      0.00     82.66      0.00      0.00      0.00

```
'atop' так же позволяет увидеть нагрузку текущую. Удобно видно pid процессов. Который можно снять.
![image](https://github.com/user-attachments/assets/e3528b6c-5ffe-46ee-9f99-0d2b7f021d08)

```
kill 9830 9832
```


Запустить 'openssl speed -seconds 30 2>& 1 > /dev/null &' и с помощью `pidstat` найти
PID процесса openssl'
```
ps aux | grep openssl
# alrex      10414 99.9  0.1   9788  6440 pts/0    R    13:17   2:56 openssl speed -seconds 30

pidstat | grep openssl
# 01:22:22 PM  1000     10414    1.12    0.00    0.00    0.00    1.12     0  openssl

```
% пользовательского (usr) и системного (sys) CPU time
```
mpstat -P ALL

01:27:06 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
01:27:06 PM  all    5.27    0.05    3.82    0.61    0.00    0.16    0.00    0.00    0.00   90.09
01:27:06 PM    0    6.34    0.09    3.71    0.66    0.00    0.03    0.00    0.00    0.00   89.16
01:27:06 PM    1    4.14    0.02    3.92    0.56    0.00    0.29    0.00    0.00    0.00   91.08


mpstat 

01:28:51 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
01:28:51 PM  all    5.47    0.05    3.80    0.61    0.00    0.16    0.00    0.00    0.00   89.91


```


Запустить sleep 5; ls -R /usr и после ее завершения найти
время выполнения (real, user, sys)
максимальное потребление памяти
```
/usr/bin/time -v bash -c "sleep 5; ls -R /usr" 2> output.txt


cat output.txt
        Command being timed: "bash -c sleep 5; ls -R /usr"
        User time (seconds): 2.22
        System time (seconds): 3.29
        Percent of CPU this job got: 34%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:16.13
        Average shared text size (kbytes): 0
        Average unshared data size (kbytes): 0
        Average stack size (kbytes): 0
        Average total size (kbytes): 0
        Maximum resident set size (kbytes): 4980
        Average resident set size (kbytes): 0
        Major (requiring I/O) page faults: 3
        Minor (reclaiming a frame) page faults: 1015
        Voluntary context switches: 16
        Involuntary context switches: 155031
        Swaps: 0
        File system inputs: 424
        File system outputs: 0
        Socket messages sent: 0
        Socket messages received: 0
        Signals delivered: 0
        Page size (bytes): 4096
        Exit status: 0

```
Запустить стресс-тест с помощью утилиты stress-ng 
(параметры подобрать самостоятельно) и вывести с помощью ps топ-5 процессов (по очереди) с 
наибольшим потреблением
CPU MEM

  `ps aux --sort=-%cpu | head -n 5`

```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
alrex      33986 37.9  4.4 1316096 146236 pts/0  R    13:21   0:02 stress-ng-vm [run]
alrex      33985 32.2 32.3 1316096 1058000 pts/0 R+   13:21   0:02 stress-ng-vm [run]
alrex      33988 28.0 11.6 1316096 380772 pts/0  R    13:21   0:00 stress-ng-vm [run]
alrex      33981 15.8  0.2 267520  9796 pts/0    R+   13:21   0:01 stress-ng-switch [run]
```

`ps aux --sort=-%mem | head -n 5`
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
alrex      33993 36.9 32.3 1316096 1057980 pts/0 R    13:22   0:07 stress-ng-vm [run]
alrex      33995 25.2 28.9 1316096 944548 pts/0  R+   13:22   0:01 stress-ng-vm [run]
alrex      33998 49.5  8.8 1316096 288220 pts/0  R    13:22   0:00 stress-ng-vm [run]
gdm         2202  0.4  3.2 3767080 107524 tty1   Sl+  06:15   1:52 /usr/bin/gnome-shell

```



DISK  disk write = 82.94 M/s - на 1 месте
```
dd if=/dev/zero of=/tmp/testfile bs=1M count=5000


sudo iotop

  33795 be/4 alrex       0.00 B/s   82.94 M/s dd if=/dev/zero of=/tmp/testfile bs=1M count=5000
```

# Но лучший вариант
```
dstat -cglmns --top-cpu --top-mem --top-io
```
![image](https://github.com/user-attachments/assets/a222567f-33ec-4096-943f-8b4d5c990d32)
