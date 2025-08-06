```bash
sudo vim inventory

[targets]
MySlaveServer ansible_host=192.168.50.34
```


Написать плейбук, который создает системного пользователя 
с именем appuser с домашней директорией (/home/appuser)
и оболочкой /bin/bash



Запуск yaml playbook
```
sudo ansible-playbook -i inventory hw19dop.yaml
```

На ansible машине

`sudo vim hw19dop.yaml`

```
---
- hosts: targets
  become: true
  gather_facts: no
  tasks:
    - name: Add appuser
      user:
        name: appuser
        shell: /bin/bash
        state: present

```


Написать плейбук, который копирует публичный SSH-ключ с управляющей машины 
(files/appuser.pub) в файл authorized_keys пользователя 
appuser на удаленных узлах (/home/appuser/.ssh/authorized_keys). 
Убедиться, что у директории .ssh правильные права (700), а у файла authorized_keys - права (600).

На ansible машине руками
```
sudo adduser appuser
sudo -su appuser
cd ~
ssh-keygen -t ed25519

# просто посмотрел
 cat /home/appuser/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPEZl+rDAQKswyHQg30g8pKl5opWOCemoVCTKi6MhHq appuser@ubuntu1

```
hw19dop.yaml
```yaml
---
- hosts: targets
  become: true
  gather_facts: no
  vars:
    user: "appuser"

  tasks:
    - name: Add appuser
      user:
        name: appuser
        shell: /bin/bash
        state: present

    - name: Create dir .ssh if not exist
      file:
        path: "/home/{{ user }}/.ssh"
        state: directory
        owner: "{{ user }}"
        group: "{{ user }}"
        mode: '0700'

    - name: Create authorized_key
      file:
        path: "/home/{{ user }}/.ssh/authorized_keys"
        state: touch
        owner: "{{ user }}"
        group: "{{ user }}"
        mode: '0600'


    - name: Set authorized key taken from file
      authorized_key:
        user: "{{ user }}"
        state: present
        key: "{{ lookup('file', '/home/{{ user }}/.ssh/id_ed25519.pub') }}"

```

На хосте после прокрутки

```
sudo ls -la /home/appuser/.ssh
total 12
drwx------ 2 appuser appuser 4096 Aug  6 07:16 .
drwxr-x--- 3 appuser appuser 4096 Aug  6 07:16 ..
-rw------- 1 appuser appuser   97 Aug  6 07:16 authorized_keys

sudo cat /home/appuser/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPEZl+rDAQKswyHQg30g8pKl5opWOCemoVCTKi6MhHq appuser@ubuntu1
```


Написать плейбук, который копирует шаблон файла mod с управляющей машины (templates/motd.j2) 
на удаленные узлы в /etc/motd. 
Использовать переменную {{ inventory_hostname }} в шаблоне, чтобы в файле motd отображалось имя хоста. 
Шаблон (templates/motd.j2)
Welcome to server {{ inventory_hostname }}!
Provided by Ansible.


```bash
sudo mkdir templates
sudo vim templates/motd.j2

Welcome to server {{ inventory_hostname }}!
Provided by Ansible.
```

Добавил в  hw19dop.yaml

```
  - name: copy template in /etc/motd
      template:
        src: "./templates/motd.j2"
        dest: "/etc/motd"

```


Написать плейбук, который проверит, установлен ли git на удаленных узлах 
и склонирует репозиторий https://gitlab.com/devops201206/it-mtb-blog в директорию /var/www/simple-blog

hw19dop_git.yaml
```bash
---
- hosts: targets
  become: true
  gather_facts: no

  tasks:
    - name: check present git in remote hosts
      command:  git --version
      register: git_data
      ignore_errors: yes


    - name: if exists git then print mesage
      debug:
        msg: "{{ git_data.stdout }} on {{ inventory_hostname }} is installed"
      when:  git_data.rc == 0


    - name: if not exists git then print mesage
      debug:
        msg: "git  on {{ inventory_hostname }} is not installed"
      when:  git_data.rc != 0

    - name: Create /var/www/simple-blog directory
      file:
        path: /var/www/simple-blog
        state: directory

    - name: git repo clone
      git:
        repo: 'https://gitlab.com/devops201206/it-mtb-blog.git'
        dest: /var/www/simple-blog
```


Написать плейбук для сбора системной информации об управляемых узлах
размер оперативной памяти
sudo ansible-playbook -i inventory sysinfo.yaml
```
free -h | grep Mem | awk '{ print $2}' 
#| sed 's/Gi//'
```

```
- name:

```
размер диска, смонтированного в /
```
df -h | grep -vE "tmp|mnt|File" | awk '{ print $2 }' 
#| sed 's/G//'
```
версия ОС

sysinfo.yaml
```
---
- hosts: targets
  become: true
  gather_facts: yes

  tasks:
    - name: size of RAM
      shell: free -h | grep Mem | awk '{ print $2}' | sed 's/Gi//'
      register: ram_size

    - name: size HDD in /
      shell: df -h | grep -vE "tmp|mnt|File" | awk '{ print $2 }' | sed 's/G//'
      register: hhd_size

    - name: print results
      debug:
        msg: "Size of ram: {{ ram_size.stdout }} Gb;  Size of hdd: {{ hhd_size.stdout }} Gb"

    - name: Version OS
      debug:
        msg: "OS: {{ ansible_distribution }} \n Version: {{ ansible_distribution_version }}"
```


```
TASK [print results] *******************************************************************************
ok: [MySlaveServer] => {
    "msg": "Size of ram: 3.1 Gb;  Size of hdd: 46\n46 Gb"
}

TASK [Version OS] **********************************************************************************
ok: [MySlaveServer] => {
    "msg": "OS: Ubuntu \n Version: 24.04"
}

```