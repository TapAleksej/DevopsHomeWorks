# Создание пользователя в ubuntu


```bash
adduser talex
# добавление в группу root
adduser talex sudo
```
### Запрет ssh-подключения от имени root-пользователя

Зашёл под talex

```bash
talex@devpc:~$ sudo nano /etc/ssh/sshd_config
```
Заменил
```bash
#PermitRootLogin prohibit-password
PermitRootLogin no
```

Перезапустил службу
```bash
sudo systemctl restart sshd
```


> [!help]
> Но тут не понятно - по идее по ssh root  логины не должны подключаться
удалённо.... но подключение все равно происходит.