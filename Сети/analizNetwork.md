# Методика поиска ошибок
## Анализ node
#### Проверить как запущено node
```bash
ps auxf | grep node
```
f  - представить графически

#### На каком порту запущено node
```bash
sudo ss -nlptu | grep node
# tcp  LISTEN 0  511  *:3000   *:*    users:(("node",pid=3550,fd=24))
# 3000 порт
```
t -tcp
u udp
#### Проверка удаленного порта
```bash
nc -zv 10.152.25.65 3000
# or
nc 192.168.50.34 3000


```
#### Внутренний ip
```bash
ip -o a
```
#### Публичный ip
```bash
curl 2ip.ru
#46.173.179.72
```


### Определить причину почему не работает блог
Сервер nginx
Сайт blog должен работать на 80 порту

```bash
ping mainblog.ru
nslookup mainblog.ru
# Подключаемся по ssh к машине
ssh name@mainblog.ru
# Что запущено
htop
top
# Слушаем порты
sudo ss -nlptu
# 80 порта нет в списке, те нужно смотреть в конфигурацию nginx
```

```bash
# где конф nginx
whereis nginx
# nginx: /usr/sbin/nginx /etc/nginx /usr/share/nginx /usr/share/man/man8/nginx.8.gz
sudo ls -lh /etc/nginx | grep conf
# -rw-r--r-- 1 root root 1.5K Nov 30  2023 nginx.conf
```

#### Какие порты использует nginx (какие порты используются)
```bash
sudo grep -r listen /etc/nginx/
```
Видно, что сайт blog слушает 9100 порт - это и есть конфиг сайта
а counter 80
![[Pasted image 20250620141338.png|650]]
Все конфиги лежат в `etc/ngnix/sites-avaible`

```bash
cat etc/ngnix/sites-avaible/blog
```
![[Pasted image 20250620142250.png|300]]
#### Включаем блог
В нём нужно поменять порт 9100 на 80
Создать симлинк блога в `sites-enabled` <font color="#ffff00">чтобы заработало</font>
```bash
sudo ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
ls -l /etc/nginx/sites-enabled/
```
![[Pasted image 20250620142836.png]]
#### Когда изменяли конфиги всегда выполняем проверку
```bash
sudo nginx -t
```
Перечитываем конфигурацию
```bash
sudo nginx -s reload
```

И проверяем что висит на 80 порту [[#Какие порты использует nginx (какие порты используются)]]
или
```bash
sudo ss -nlptu | grep nginx
```
#### Проверяем запуск блога
```bash
curl localhost:80
# 80 можно опустить если 80
curl localhost
```


### Counter

![[Pasted image 20250620154509.png]]
Проверка порта
```bash
nc -zv 10.129.0.44 6379
```

```bash
sudo vim /etc/nginx/sites-available/counter
```
Меняем название сервера на counter
![[Pasted image 20250620154827.png]]
Делаю ссылку
```bash
sudo ln -sf /etc/nginx/sites-available/counter /etc/nginx/sites-enabled/
ls -l /etc/nginx/sites-enabled/
# проверка конфига
sudo nginx -t
# Перечитаем
sudo nginx -s reload

```
Правка файла hosts для проверки counter
```bash
sudo vim /etc/hosts
```
![[Pasted image 20250620155428.png]]
Проверка
```bash
curl counter
```