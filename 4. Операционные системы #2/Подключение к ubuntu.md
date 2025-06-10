### Железо
    Установил отдельный HDD c ubuntu (UPK)  на физический ПК
    Изучать буду через MobaXterm на пк с win10  (WPK).

### Установить SSH на UPK
Обновить пакет

    ```bash
    alrex@devpc:~$ sudo apt update
    [sudo] password for alrex:
    Hit:1 http://ru.archive.ubuntu.com/ubuntu noble InRelease
    Get:2 http://ru.archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
    Get:3 http://ru.archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
    - - - -

    # установить SSH
    sudo apt-get install ssh
    ----
    # Проверка статуса - запущен ли SSH
        alrex@devpc:~$ systemctl status sshd
    ● ssh.service - OpenBSD Secure Shell server
        Loaded: loaded (/usr/lib/systemd/system/ssh.service; enabled; preset: enabled)
        Active: active (running) since Tue 2025-06-10 09:00:05 MSK; 5h 20min ago
    TriggeredBy: ● ssh.socket

    ```
    Меняю порт 22 по которому по умолчанию происходит соединение

    ```bash

        alrex@devpc:~$ sudo nano /etc/ssh/sshd_config

    ```
        Расскоментим и поставил порт Port  1234

    Рестартуем SSH

    ```bash
        systemctl restart sshd
    ```


### Создать репозитарий для домашки
    Создал на гитхабе репозитарий домашних работ.
    На ubuntu в разделе создал папку для репозитария
    установил гит

    ```bash
    alrex@devpc:~/DevopsHomeWorks$ sudo apt install git
    alrex@devpc:~/DevopsHomeWorks$ git init
    alrex@devpc:~/DevopsHomeWorks$ touch HomeWork4.md

    git branch -M main

    git remote add origin git remote add origin git@github.com:TapAleksej/DevopsHomeWorks.git
    ```

    Сгенерировал и добавил открытый ключ

    ```bash
    ssh-keygen -b 4096
    ```
    Назвал SSH KEY "fromubuntu"на github

    Для подключения к UPK нужно добавить открытый ключ с WPK в файл
     .ssh/authorized_keys


    - Смотрю файл authorized_keys на UPK

    ```bash
    alrex@devpc:~$ nano .ssh/authorized_keys
    # Пустой файл
    ```



## Подключение с WPK

    - Проверим можем ли достучаться до UPK c WPK

        ```bash
            user@VLG-5CD5491NCN MINGW64 /c/MobaXterm_Portable_v25.2
            $ ping  192.168.50.103

            Обмен пакетами с 192.168.50.103 по с 32 байтами данных:
            Ответ от 192.168.50.103: число байт=32 время=1мс TTL=64
            Ответ от 192.168.50.103: число байт=32 время=5мс TTL=64
            Ответ от 192.168.50.103: число байт=32 время=2мс TTL=64
            Ответ от 192.168.50.103: число байт=32 время=1мс TTL=64
        ```
    Есть

    - Скопируем SSH ключ с винды на ubuntu

        ```bash
        user@VLG-5CD5491NCN MINGW64 /c/MobaXterm_Portable_v25.2
        $ ssh-copy-id alrex@192.168.50.103

        /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/c/Users/user/.ssh/id_rsa.pub"
        The authenticity of host '192.168.50.103 (192.168.50.103)' can't be established.
        ED25519 key fingerprint is SHA256:EjxMKvBfUc3Vu1J47LinH63Y+wORojVi4heovTYAymI.
        This key is not known by any other names.
        Are you sure you want to continue connecting (yes/no/[fingerprint])? y
        Please type 'yes', 'no' or the fingerprint: y
        Please type 'yes', 'no' or the fingerprint: dfsdf
        Please type 'yes', 'no' or the fingerprint: yes
        /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
        /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
        alrex@192.168.50.103's password:
        Permission denied, please try again.
        alrex@192.168.50.103's password:

        Number of key(s) added: 1

        Now try logging into the machine, with: "ssh 'alrex@192.168.50.103'"
        and check to make sure that only the key(s) you wanted were added.
        ```
    - Смотрю файл authorized_keys на UPK -- ключ добавлен

        ```bash
        alrex@devpc:~$ cat .ssh/authorized_keys
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpiHQzsCgo7KsB+779OPvYnaKy1DUdoivxzRvqs8CajwhIeEf1D/yz8GDj2Kg7xEHeRevDw3xp+D2qOoPH+6mp264jUUYwgBOMqVGm9IGE762Mce5hjCrBcl5ifuhP3Gzh+ScNNvzQnLFGxRBwI+gPQL4rIYN4stbww6P8Z63i2NOHmmondap0YCk2vAv8fekEA4xuwyBfYR/IgGGzePY5xC1TbxG2oHwjee7ajN4liDQn2UVc/V38jDLfisZIJt70dwyuWZiNv1LGGHbkvlgxGWFiWxDmZaOGVtiartapaleksej@yandex.ru
        ```
    - Стучусь - *меня поздравляют*

        ```bash
        user@VLG-5CD5491NCN MINGW64 /c/MobaXterm_Portable_v25.2
        $ ssh alrex@192.168.50.103 -p 1234

        Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.11.0-26-generic x86_64)

        * Documentation:  https://help.ubuntu.com
        * Management:     https://landscape.canonical.com
        * Support:        https://ubuntu.com/pro
        ```
Теперь через git bash клиент или mobaXterm я могу работать на ubuntu pk

```bash
alrex@devpc:~$ exit
logout
Connection to 192.168.50.103 closed.
```