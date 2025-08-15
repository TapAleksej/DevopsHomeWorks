Написать роль для настройки времени 
и часового пояса с помощью 
chrony или ntpd




https://blog.sedicomm.com/2019/09/01/sinhronizatsiya-vremeni-v-linux-s-ntp-kak-ustanovit-i-ispolzovat-chrony/


Chrony — это гибкая реализация протокола сетевого времени Network Time Protocol (NTP). Используется для синхронизации системных часов с различных NTP-серверов, эталонных часов или с помощью ручного ввода.

Также можно его использовать как сервер NTPv4 для синхронизации времени других серверов в той же сети. Сервис предназначен для безупречной работы в различных условиях, таких как прерывистое сетевое подключение, перегруженные сети, изменение температуры, что может повлиять на отсчет времени в обычных компьютерах.

Chrony поставляется с двумя программами:

chronyc — интерфейс командной строки для службы Chrony;
chronyd — служба, которая может быть запущена во время загрузки системы.

```
---
# tasks file for chrony
# apt install chrony
- name: install chrony
  package:
      name:
        - chrony
      update_cache: yes

- name: Start chrony
  systemd_service:
    name: chrony.service
    state: started
    enabled: true
```


Проверки
```
alrex@slv12:/opt$ sudo systemctl status chrony
● chrony.service - chrony, an NTP client/server
     Loaded: loaded (/usr/lib/systemd/system/chrony.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-08-14 13:50:13 UTC; 1min 19s ago
       Docs: man:chronyd(8)
             man:chronyc(1)
             man:chrony.conf(5)
    Process: 29807 ExecStart=/usr/lib/systemd/scripts/chronyd-starter.sh $DAEMON_OPTS (code=exited, status=0/SU>
   Main PID: 29817 (chronyd)
      Tasks: 2 (limit: 1108)
     Memory: 1.4M (peak: 2.3M)
        CPU: 32ms
     CGroup: /system.slice/chrony.service
             ├─29817 /usr/sbin/chronyd -F 1
             └─29818 /usr/sbin/chronyd -F 1

Aug 14 13:50:13 slv12 systemd[1]: Starting chrony.service - chrony, an NTP client/server...
Aug 14 13:50:13 slv12 chronyd[29817]: chronyd version 4.5 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFI>
Aug 14 13:50:13 slv12 chronyd[29817]: Loaded 0 symmetric keys
Aug 14 13:50:13 slv12 chronyd[29817]: Initial frequency -25.219 ppm
Aug 14 13:50:13 slv12 chronyd[29817]: Using right/UTC timezone to obtain leap second data
Aug 14 13:50:13 slv12 chronyd[29817]: Loaded seccomp filter (level 1)
Aug 14 13:50:13 slv12 systemd[1]: Started chrony.service - chrony, an NTP client/server.
Aug 14 13:50:20 slv12 chronyd[29817]: Selected source 92.255.126.22 (1.ubuntu.pool.ntp.org)
Aug 14 13:50:20 slv12 chronyd[29817]: System clock TAI offset set to 37 seconds
Aug 14 13:51:25 slv12 chronyd[29817]: Selected source 92.255.126.3 (2.ubuntu.pool.ntp.org)

alrex@slv12:/opt$ chkconfig --add chronyd
chkconfig: command not found
alrex@slv12:/opt$ chronyc tracking
Reference ID    : 5CFF7E03 (mskm9-ntp03c.ntppool.yandex.net)
Stratum         : 3
Ref time (UTC)  : Thu Aug 14 14:21:34 2025
System time     : 0.000056841 seconds fast of NTP time
Last offset     : +0.000017758 seconds
RMS offset      : 0.000305767 seconds
Frequency       : 25.268 ppm slow
Residual freq   : +0.001 ppm
Skew            : 0.127 ppm
Root delay      : 0.010387705 seconds
Root dispersion : 0.000327788 seconds
Update interval : 256.4 seconds
Leap status     : Normal
alrex@slv12:/opt$ chronyc tracking
Reference ID    : 5CFF7E03 (mskm9-ntp03c.ntppool.yandex.net)
Stratum         : 3
Ref time (UTC)  : Thu Aug 14 14:21:34 2025
System time     : 0.000056510 seconds fast of NTP time
Last offset     : +0.000017758 seconds
RMS offset      : 0.000305767 seconds
Frequency       : 25.268 ppm slow
Residual freq   : +0.001 ppm
Skew            : 0.127 ppm
Root delay      : 0.010387705 seconds
Root dispersion : 0.000340664 seconds
Update interval : 256.4 seconds
Leap status     : Normal
alrex@slv12:/opt$ chronyc sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^- prod-ntp-3.ntp1.ps5.cano>     2   8   377   105   +882us[ +882us] +/-   28ms
^- prod-ntp-5.ntp4.ps5.cano>     2   8   377   103   +737us[ +737us] +/-   29ms
^- alphyn.canonical.com          2   7   376   488  +1549us[+1566us] +/-   84ms
^- prod-ntp-4.ntp4.ps5.cano>     2   8   377   104  +1109us[+1109us] +/-   28ms
^- 45.141.102.99                 2   8   377    37   -270us[ -270us] +/-   47ms
^+ 92.255.126.22                 2   8   377   100   +412us[ +412us] +/- 5343us
^- as57164-151-0-2-53.htel.>     2   7   377    41  -3298us[-3298us] +/-   24ms
^* mskm9-ntp03c.ntppool.yan>     2   8   377   105   -398us[ -381us] +/- 5638us
alrex@slv12:/opt$ sudo vim /etc/chrony/chrony.conf


```