### Изучаем сеть

```bash
sudo ifconfig -a
```
получил ошибку

Установил пакет
```bash
alrex@devpc:~$ sudo apt install net-tools
```
Получил

enp5s0 - локальня сеть
lo - localhost
wlp4s0 - wan  интернет

```bash

enp5s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.50.103  netmask 255.255.255.0  broadcast 192.168.50.255
        inet6 fdcc:52a9:24eb:0:16da:e9ff:fe68:a286  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::16da:e9ff:fe68:a286  prefixlen 64  scopeid 0x20<link>
        inet6 fdcc:52a9:24eb:0:2812:224:d29b:f327  prefixlen 64  scopeid 0x0<global>
        ether 14:da:e9:68:a2:86  txqueuelen 1000  (Ethernet)
        RX packets 60949  bytes 53059476 (53.0 MB)
        RX errors 0  dropped 227  overruns 0  frame 0
        TX packets 37862  bytes 4114165 (4.1 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 4913  bytes 538726 (538.7 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4913  bytes 538726 (538.7 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlp4s0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 64:70:02:91:31:a8  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```
Запустил редактор для просмотра файла  для облака
- пустой
```bash
alrex@devpc:~$ nano /etc/netplan/50-cloud-init.yaml
```



Для десктопных пк используется
```bash
nano /etc/netplan/01-network-manager-all.yaml

alrex@devpc:~$ cat /etc/netplan/01-network-manager-all.yaml
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
```

Настройки NetworkManager можно увидеть через графический интерфейс
settinngs -> network

У меня стоит DHCP в этих настройках

### Изменить ручками в файле настройки сети на DHCP
01-network-manager-all.yaml

```bash
alrex@devpc:~$ cat /etc/netplan/01-network-manager-all.yaml
# Let NetworkManager manage all devices on this system
network:
  ethernets:
   enp5s0:
     dhcp4: true
     dhcp6: true
     optional: true
  version: 2
```

Проверяем настройки сети
```bash
alrex@devpc:~$ sudo netplan try
[sudo] password for alrex:

** (process:35601): WARNING **: 14:22:56.727: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (generate:35603): WARNING **: 14:22:56.735: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (process:35601): WARNING **: 14:22:57.456: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (process:35601): WARNING **: 14:22:57.617: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.
Do you want to keep these settings?


Press ENTER before the timeout to accept the new configuration


Changes will revert in 108 seconds
Configuration accepted.
```

Всё работает на DHCP!

```bash
alrex@devpc:~$ nslookup ya.ru
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   ya.ru
Address: 77.88.44.242
Name:   ya.ru
Address: 77.88.55.242
Name:   ya.ru
Address: 5.255.255.242
Name:   ya.ru
Address: 2a02:6b8::2:242

```
### Пробуем поменять на статику

Сделаю статику на ip 192.168.50.105 (был 192.168.50.103 на DHCP)
```bash
alrex@devpc:~$ sudo nano /etc/netplan/01-network-manager-all.yaml
```
```bash
# Let NetworkManager manage all devices on this system
network:
  ethernets:
   enp5s0:
     addresses: [192.168.50.105/24,'fdcc:52a9:24eb:0:98e7:1a7e:76ef:b378/64']
     gateway4: 192.168.50.1
     nameservers:
      addresses: [192.168.50.105,'fdcc:52a9:24eb:0:98e7:1a7e:76ef:b378']
      search:
      - lan
     optional: true
  version: 2
```
Проверяю

```bash
** (process:41547): WARNING **: 14:46:19.154: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (process:41547): WARNING **: 14:46:19.154: `gateway4` has been deprecated, use default routes instead.
See the 'Default routes' section of the documentation for more details.

** (generate:41549): WARNING **: 14:46:19.163: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (generate:41549): WARNING **: 14:46:19.163: `gateway4` has been deprecated, use default routes instead.
See the 'Default routes' section of the documentation for more details.

** (process:41547): WARNING **: 14:46:19.947: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (process:41547): WARNING **: 14:46:19.947: `gateway4` has been deprecated, use default routes instead.
See the 'Default routes' section of the documentation for more details.

** (process:41547): WARNING **: 14:46:20.109: Permissions for /etc/netplan/01-network-manager-all.yaml are too open. Netplan configuration should NOT be accessible by others.

** (process:41547): WARNING **: 14:46:20.110: `gateway4` has been deprecated, use default routes instead.
See the 'Default routes' section of the documentation for more details.
Do you want to keep these settings?


Press ENTER before the timeout to accept the new configuration


Changes will revert in 118 seconds
Configuration accepted.
```

```bash
alrex@devpc:~$ nslookup google.com
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   google.com
Address: 64.233.162.138
Name:   google.com
Address: 64.233.162.101
Name:   google.com
Address: 64.233.162.139
Name:   google.com
Address: 64.233.162.113
Name:   google.com
Address: 64.233.162.100
Name:   google.com
Address: 64.233.162.102
Name:   google.com
Address: 2a00:1450:4010:c01::71
Name:   google.com
Address: 2a00:1450:4010:c01::64
Name:   google.com
Address: 2a00:1450:4010:c01::66
Name:   google.com
Address: 2a00:1450:4010:c01::65

```

Всё работает и на статике!

### Проверка статуса DNS
```bash
alrex@devpc:~$ resolvectl status
Global
         Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
  resolv.conf mode: stub

Link 2 (enp5s0)
    Current Scopes: DNS
         Protocols: +DefaultRoute -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 192.168.50.1
       DNS Servers: 192.168.50.105 192.168.50.1 fdcc:52a9:24eb:0:98e7:1a7e:76ef:b378
        DNS Domain: lan

Link 3 (wlp4s0)
    Current Scopes: none
         Protocols: -DefaultRoute -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
```

192.168.50.1 - мой интернет роутер
192.168.50.105 - ip статический моего UPK

Нужно поменять dns 127.0.0.53 на 8.8.8.8
```bash
alrex@devpc:~$ nslookup ya.ru
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   ya.ru
Address: 77.88.44.242
Name:   ya.ru
```
Редактируем файл
alrex@devpc:~$ sudo nano /etc/resolv.conf

меняем nameserver 127.0.0.53 на 8.8.8.8

Поверяем - dns нужный
```bash
alrex@devpc:~$ nslookup ya.ru
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   ya.ru
Address: 77.88.55.242
Name:   ya.ru
Address: 77.88.44.242
Name:   ya.ru
Address: 5.255.255.242
```
