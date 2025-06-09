### Железо
    Установил отдельный HDD c ubuntu (UPK)  на ПК (WPK).

### Создать репозитарий для домашки
    Создал на гитхабе репозитарий домашних работ.
    На ubuntu в разделе создал папку для репозитария
    установил гит

    alrex@devpc:~/DevopsHomeWorks$ sudo apt install git
    alrex@devpc:~/DevopsHomeWorks$ git init
    alrex@devpc:~/DevopsHomeWorks$ touch HomeWork4.md

    git branch -M main

    git remote add origin git remote add origin git@github.com:TapAleksej/DevopsHomeWorks.git

    Сгенерировал и добавил открытый ключ

    ssh-keygen -b 4096

    Назвал SSH KEY "fromubuntu"на github

    Для подключения к UPK нужно добавить открытый ключ с WPK в файл
     .ssh/authorized_keys


    - Смотрю файл authorized_keys на UPK

        alrex@devpc:~$ nano .ssh/authorized_keys

     Пустой файл

    - Меняю порт 22 по которому по умолчанию происходит соединение

        alrex@devpc:~$ sudo nano /etc/ssh/sshd_config

        Расскоментим и поставил порт Port  1234



##Подключение с WPK

    - Проверим можем ли достучаться до UPK c WPK

        user@VLG-5CD5491NCN MINGW64 /c/MobaXterm_Portable_v25.2
        $ ping  192.168.50.103

        Обмен пакетами с 192.168.50.103 по с 32 байтами данных:
        Ответ от 192.168.50.103: число байт=32 время=1мс TTL=64
        Ответ от 192.168.50.103: число байт=32 время=5мс TTL=64
        Ответ от 192.168.50.103: число байт=32 время=2мс TTL=64
        Ответ от 192.168.50.103: число байт=32 время=1мс TTL=64
    Есть

    - Скопируем SSH ключ с винды на ubuntu

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

    - Смотрю файл authorized_keys на UPK -- ключ добавлен

        alrex@devpc:~$ cat .ssh/authorized_keys
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpiHQzsCgo7KsB+779OPvYnaKy1DUdoivxzRvqs8CajwhIeEf1D/yz8GDj2Kg7xEHeRevDw3xp+D2qOoPH+6mp264jUUYwgBOMqVGm9IGE762Mce5hjCrBcl5ifuhP3Gzh+ScNNvzQnLFGxRBwI+gPQL4rIYN4stbww6P8Z63i2NOHmmondap0YCk2vAv8fekEA4xuwyBfYR/IgGGzePY5xC1TbxG2oHwjee7ajN4liDQn2UVc/V38jDLfisZIJt70dwyuWZiNv1LGGHbkvlgxGWFiWxDmZaOGVtiartUfkie6U9G4IR9uIq9HWeq5IJEbeoEcLIsVrf8RqXlQRIcgr9EwAv85qNL7VmRIoA9S35zmZfSaNwo81HlkWY4uk0rrRdxY3iS2wNwSeSHL1K5YaWyLqb5Pve0R6/sNtEmLOD8ss1PkY9hvnCvSQWUzLnLos0btsOS4RAOsoxf0SZE4CMgQZO9nYwuHPoNA+MVBW3eI4K0U7in8SOGAAVBM/BpgG/FXgVgdC8FeohN8Cf59hFbIAC8PMTMs7Muc1ZIonFevNNgo7eLsfE0WV6kXJEBHnlZxGFwfqFw5hK4b5SS7bviXCjRhXvcEZ1N97QtOOPQwpQO2x4pdbBrMAM8z/A2pj0IgSF/PtO1VkfKMr4kCnENmZmlNagWEntPC7C47Aw== tapaleksej@yandex.ru

    - Стучусь - меня поздравляют

        user@VLG-5CD5491NCN MINGW64 /c/MobaXterm_Portable_v25.2
        $ ssh alrex@192.168.50.103 -p 1234

        Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.11.0-26-generic x86_64)

        * Documentation:  https://help.ubuntu.com
        * Management:     https://landscape.canonical.com
        * Support:        https://ubuntu.com/pro

Теперь через git bash клиент я могу работать на ubuntu pk








