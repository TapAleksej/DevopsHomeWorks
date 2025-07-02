https://lms.teachmeskills.com/attachments/student/10055
## Домашнее задание No9
Цель: освоить принципы работы текстового редактора Vim. Ознакомиться с
процессом логирования в Linux. Научиться определять уровень загрузки
системы.

```
alrex@ubuntu1:~/Homework/DevopsHomeWorks$ cd 10\ Unix\ utils\ 1/
alrex@ubuntu1:~/Homework/DevopsHomeWorks/10 Unix utils 1$ mkdir practice
alrex@ubuntu1:~/Homework/DevopsHomeWorks/10 Unix utils 1$ cd practice/
alrex@ubuntu1:~/Homework/DevopsHomeWorks/10 Unix utils 1/practice$ sudo vim memo
```

#### Настройка vim
`sudo vim ~/.vimrc`

```
"Табы и пробелы
set expandtab
set smarttab
set tabstop=4
set softtabstop=4
set shiftwidth=4
"Нумерация строк и отступ
set number
set foldcolumn=2
"Цветовая схема
colorscheme delek
syntax on
"Без звука
set noerrorbells
set novisualbell
"Мышь
set mouse=a
"Привязки
let mapleader = ","
nmap <leader>w :w!<CR>
map <space> /
map <C-space> ?
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <leader>ss :setlocal spell!<CR>
inoremap <C-v> <ESC>"+pa
vnoremap <C-c> "+y
vnoremap <C-d> "+d
"Поиск
set ignorecase
set smartcase
set hlsearch
set incsearch
"Выход с sudo
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
"Кодировка
set encoding=utf8
"Тип переноса
set ffs=unix,dos,mac
```

```
alrex@ubuntu1:~/Homework/DevopsHomeWorks/10 Unix utils 1/practice$ touch testcase.c
alrex@ubuntu1:~/Homework/DevopsHomeWorks/10 Unix utils 1/practice$ ls
memo  testcase.c

```
поиск в текущей директории файла

```
alrex@ubuntu1:~/Homework/DevopsHomeWorks/10 Unix utils 1/practice$ find -name 'tes*'
./testcase.c

```

или поиск везде

```
 sudo find / -type f -name 'testcase.c'
find: ‘/run/user/1000/doc’: Permission denied
find: ‘/run/user/120/doc’: Permission denied
/home/alrex/Homework/DevopsHomeWorks/10 Unix utils 1/practice/testcase.c

```

#### Включите отображение номеров строк. Сколько строк в данном файле?
в командном режиме `:set number` - включить
`:set number!` - отключить 

#### Вернитесь в начало файла.
в командном режиме `gg`

#### Найдите слово WORD и замените его на IGNORE.
в командном режиме `:%s/WORD/IGNORE`

#### Найдите слово Reset и замените его на set
в командном режиме `:%s/Reset/set`

#### Найдите слово input и замените его на output
в командном режиме `:%s/input/output`


#### Вставьте строку, заполненную вопросительными знаками <?> 
под строкой :state= WORD
`o` и вставляю в insert режиме `?`

#### Скопируйте строки с 16 по 29 в файл printwords.c

В визуальном режиме `v` выделяю 16-29 строки.
`yy` копирую в буфер
`:n` перехожу в файл `printwords.c`
`p` втавляю и записываю файл `w`

Переключение на другой файл и оборатно ':n' и `:N` 
В буфер обмена:
Скопировать строку  `Y` or `yy`
Скопировать символ  `y`
Вставить `p` dd
Вырезать 'x'

#### Перейдите в конец файла и удалите две последние строки
`shift+g` (G) -  конец файла
`dd` -  удалите две последние строки

#### Вернитесь в начало файла и перенесите фрагмент текста, начинающийся
словами /*Manifests ..., в конец файла
`gg` - в начало файла
'yy' - копия строки
`G` - конец строки
`p` - вставка из буфера

#### Запишите произведенные изменения на диск в файл testvim.c и выйдите из
редактора.
':w testvim.c' - сохраняет в другой файл изменения
':q!' - выходим без сохранения

## Задание 4
### Установить утилиту nginx, посмотреть ее логи и также уровень нагрузки на ОС.


```
 sudo apt-get update
 sudo apt install nginx
 
 # проверка конфига nginx
 sudo nginx -t
 
 #nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
 # nginx: configuration file /etc/nginx/nginx.conf test is successful


 sudo systemctl start nginx
 sudo systemctl status nginx
  ```
 
 htop atop
```
ls -l /var/log/nginx/
total 12
-rw-r----- 1 www-data adm  0 Jun 23 10:31 access.log
-rw-r----- 1 www-data adm 79 Jun 22 13:35 access.log.1
-rw-r----- 1 www-data adm 93 Jun 19 08:00 access.log.2.gz
-rw-r----- 1 www-data adm 96 Jun 16 07:00 access.log.3.gz
-rw-r----- 1 www-data adm  0 Jun 16 06:36 error.log

alrex@ubuntu1:~$ less /var/log/nginx/access.log
/var/log/nginx/access.log: Permission denied
alrex@ubuntu1:~$ sudo less /var/log/nginx/access.log
alrex@ubuntu1:~$ sudo less /var/log/nginx/access.log.
access.log.1     access.log.2.gz  access.log.3.gz
alrex@ubuntu1:~$ sudo less /var/log/nginx/access.log.1


::1 - - [22/Jun/2025:13:35:40 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/8.5.0"
```

 sudo journalctl -u nginx.service

```
-- Boot 14edef9c51364b94bbae648210ec6db9 --
Jun 30 07:02:21 ubuntu1 systemd[1]: Starting nginx.service - A high performance web server and a rev>
Jun 30 07:02:22 ubuntu1 systemd[1]: Started nginx.service - A high performance web server and a reve>
~

```

### Просмотрите логи действий пользователей системы.
действия пользователя вызывающего sudo
`sudo grep 'sudo' /var/log/auth.log`

По uid запущенные команды от юзера
```
# uid=
sudo getent passwd alrex
# alrex:x:1000:1000:alrex:/home/alrex:/bin/bash


sudo journalctl _UID=1000 --since today

#-----
#Jun 30 08:39:57 ubuntu1 sudo[9894]:    alrex : TTY=pts/0 ; PWD=/home/alrex/Homework ; USER=root ; COMMAND=/usr/bin/vim /home/alrex/.vimrc
#Jun 30 08:39:57 ubuntu1 sudo[9894]: pam_unix(sudo:session): session opened for user root(uid=0) by alrex(uid=1000)
#-----
```