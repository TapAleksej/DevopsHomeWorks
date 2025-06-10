#FIREWALL

Просмотр действующих параметров iptables:

#IPV4
sudo iptables -L
#IPV6
sudo ip6tables -L



```bash
alrex@devpc:~$ sudo iptables -L

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination


alrex@devpc:~$ sudo ip6tables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
```

alrex@devpc:~$ sudo ip6tables -L | grep policy
Chain INPUT (policy ACCEPT)
Chain FORWARD (policy ACCEPT)
Chain OUTPUT (policy ACCEPT)

Отключу поддержку ping
Проверим пинг с (windows пк) WPK на (ubuntu пк)UPK
```bash
ping 192.168.50.105

Обмен пакетами с 192.168.50.105 по с 32 байтами данных:
Ответ от 192.168.50.105: число байт=32 время=5мс TTL=64
Ответ от 192.168.50.105: число байт=32 время=1мс TTL=64
Ответ от 192.168.50.105: число байт=32 время=4мс TTL=64
Ответ от 192.168.50.105: число байт=32 время=2мс TTL=64

# Отключаю
iptables --policy OUTPUT DROP

# все отвалилось
$ ping 192.168.50.105

Обмен пакетами с 192.168.50.105 по с 32 байтами данных:
Превышен интервал ожидания для запроса.
Превышен интервал ожидания для запроса.
Превышен интервал ожидания для запроса.
```

На upk
```bash
alrex@devpc:~$ sudo iptables -L

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy DROP)
target     prot opt source               destination
```
Восстановим уже на самом UPK

```bash
iptables --policy OUTPUT ACCEPT
```
$ ping 192.168.50.105

Обмен пакетами с 192.168.50.105 по с 32 байтами данных:
Ответ от 192.168.50.105: число байт=32 время=2мс TTL=64
