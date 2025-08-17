Написать роль logrotate_config, которая генерирует конфиг для демона logrotate на основе переменных
logrotate_paths
rotate_count
Роль должна перед применением конфига 
проверять его с помощью 
logrotate -dv /etc/logrotate.d/your_config_file 
и перезапускать демон через handler
https://github.com/TapAleksej/PythonRole/tree/main/roles/logrotate

task
```
---
# tasks file for roles/logrotate
- name: Create log dir for app
  file:
    path: "{{ logrotate_paths }}"
    state: directory
    owner: www-data
    group: www-data

- name: Create error.log
  file:
    path: "{{ logrotate_paths }}/error.log"
    state: touch
    owner: www-data
    group: www-data

- name: Create debug.log
  file:
    path: "{{ logrotate_paths }}/debug.log"
    state: touch
    owner: www-data
    group: www-data

- name: Create app config for logrotate
  template:
    src: myapp_config.j2
    dest: /etc/logrotate.d/myapp
  notify:
    - check_logrotate
    - start_logrotate
```
handlers
```
---
# handlers file for roles/logrotate
- name: check_logrotate
  command: logrotate -d /etc/logrotate.d/myapp


- name: start_logrotate
  become: true
  command: logrotate -f /etc/logrotate.conf
```
vars
```
---
# vars file for roles/logrotate
logrotate_paths: /var/log/myapp/
rotate_count: 4
```

Зашифровать с помощью ansible vault переменные
api_token: "s3cr3t_t0k3n"
api_user: ecom
Написать плейбук, который на основе этих переменных генерирует файл /opt/app/.env с правами 0600 и содержимым вида

APP_TOKEN={{ api_token }}
API_USER={{ api_user }}
ENVIRONMENT=production

https://github.com/TapAleksej/PythonRole/tree/main/roles/env_role
tasks
```
---
# tasks file for roles/env_role
- name: Create directory app
  file:
    path: /opt/app/    
    state: directory


- name: Create env file
  template:
    src: env.j2
    dest: /opt/app/.env
    mode: "0600"
```

```
ansible-vault encrypt roles/env_role/vars/main.yml
New Vault password:  (123)
Confirm New Vault password: 
Encryption successful
```
cat  roles/env_role/vars/main.yml | head -10
$ANSIBLE_VAULT;1.1;AES256
35366635393631666161346430326164633136336133636133353863626534333264343333356465
6165393739616537666139396539393832333466343330660a636264663132373661633739306466
38373230363033643165316439303163376364303065663030623766363834613265643836313235
6235343539313436630a333965366633326330653735616539353465353465313239346439356230
32393336383931333631643261353438353931633032666164363437623035613661336138306463
66363066376536333566643630626233303066386563336633663732343165306266643433353537
62646464663065313536303630616239383835643137613266646431386663633134643665303437
39336339363737313632


```
ansible@master:/home/alrex/Pro$ ansible-playbook -i hosts run.yml --diff --ask-vault-pass
Vault password: 

PLAY [all] ************************************************************
****************************
```

На slave
```
sudo ls -la /opt/app/
total 12
drw------- 2 root root 4096 Aug 15 13:16 .
drwxr-xr-x 5 root root 4096 Aug 15 13:16 ..
-rw------- 1 root root   59 Aug 15 13:16 .env

```


Опциональная задача
Для плейбука из задачи №2 инициализировать структуру molecule для тестирования и прогнать базовые тесты
https://github.com/TapAleksej/molekula

Написать роль sys_utils_manager, которая устанавливает инструменты
мониторинга: atop, iotop
сетевые: nmap, tcpdump, mtr
отладочные: strace
Роль должна использовать теги
https://github.com/TapAleksej/PythonRole/tree/main/roles/sys_utils_manager

task
main.yml
```
---
# tasks file for roles/sys_utils_manager
- name: update cash
  apt:
    update_cache: yes

- name: install monitoring utils
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - atop
    - iotop
  tags: monitoring


- name: install networks utils
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nmap
    - tcpdump
    - mtr
  tags: network


- name: install debug utils
  apt:
    name: strace
    state: present
  tags: debug

- name: set interval metrics from atop
  template:
    src: atop.j2
    dest: /etc/default/atop
  notify:
    - reload atop
    - restart atop service
  tags: config_atop
```

handler
main.yml
```
---
# handlers file for roles/sys_utils_manager
- name: reload systemd
  systemd:
    daemon-reload: yes


- name: restart atop service
  service:
    name: atop
    state: restarted
```



vars
```
---
# vars file for roles/sys_utils_manager
atop_time: 300 # 5 минут
```

templates
atop.j2
```
# /etc/default/atop
# see man atoprc for more possibilities to configure atop execution

LOGOPTS=""
LOGINTERVAL={{ atop_time }}
LOGGENERATIONS=28
LOGPATH=/var/log/atop
```


Зпуск
```
ansible-playbook -i hosts run.yml --diff --tags config_atop
```


monitoring - для установки утилит мониторинга
network - для установки сетевых утилит
debug - для установки отладочных утилит
config_atop - для настройки утилиты atop -> 
изменение времени сбора метрик с 10 минут на значение, 
указанное в переменной atop_time

Установлен интервал
```
alrex@slv12:~$ sudo cat /etc/default/atop
# /etc/default/atop
# see man atoprc for more possibilities to configure atop execution

LOGOPTS=""
LOGINTERVAL=300
LOGGENERATIONS=28
LOGPATH=/var/log/atop
```