# Написать роль для установки и настройки auditd
https://github.com/TapAleksej/PythonRole/tree/main/roles/audittd
роль должна включать

#### настройку основного конфигурационного файла 
`/etc/audit/auditd.conf` через шаблон `Jinja2`
log_file
max_log_file
num_logs
space_left_action
admin_space_left

#### управление правилами аудита: 
размещение правил в /etc/audit/rules.d/security.rules 
с помощью шаблона и переменных
auditd_rules:
  - "-a always,exit -F arch=b64 -S open,openat -F success=1"
  - "-w /etc/passwd -p wa -k identity"
  - "-w /etc/sudoers -p wa -k scope"
  
  
  
  tasks
  ```
  ---
#tasks file for roles/audittd
- name: install auditd
  package:
    name: auditd
    state: present
    update_cache: yes

- name: set template auditd.config
  template:
    src: auditd.config.j2
    dest: /etc/audit/auditd.conf

- name: insert template rules in /etc/audit/rules.d/
  template:
    src: auditd_rules.j2
    dest: /etc/audit/rules.d/audit.rules

- name: service auditd must be started
  service:
    name: auditd
    state: started
    enabled: yes
  ```
  
  vars
  ```
  ---
# vars file for roles/audittd
log_file: /var/log/audit/audit.log
max_log_file: 8
num_logs: 5
space_left_action: SYSLOG
admin_space_left: 50
auditd_rules_1: "-a always,exit -F arch=b64 -S open,openat -F success=1"
auditd_rules_2: "-w /etc/passwd -p wa -k identity"
auditd_rules_3: "-w /etc/sudoers -p wa -k scope"
  ```
  
templates
auditd.config.j2
  ```
#
# This file controls the configuration of the audit daemon
#

local_events = yes
write_logs = yes
log_file = {{ log_file }}
log_group = adm
log_format = ENRICHED
flush = INCREMENTAL_ASYNC
freq = 50
max_log_file = {{ max_log_file }}
num_logs = {{ num_logs }}
priority_boost = 4
name_format = NONE
##name = mydomain
max_log_file_action = ROTATE
space_left = 75
space_left_action = {{ space_left_action }}
verify_email = yes
action_mail_acct = root
admin_space_left = {{ admin_space_left }}
admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND
use_libwrap = yes
##tcp_listen_port = 60
tcp_listen_queue = 5
tcp_max_per_addr = 1
##tcp_client_ports = 1024-65535
tcp_client_max_idle = 0
transport = TCP
krb5_principal = auditd
##krb5_key_file = /etc/audit/audit.key
distribute_network = no
q_depth = 2000
overflow_action = SYSLOG
max_restarts = 10
plugin_dir = /etc/audit/plugins.d
end_of_event_timeout = 2 
  
  ```
  
auditd_rules.j2

```
## First rule - delete all
-D

## Increase the buffers to survive stress events.
## Make this bigger for busy systems
-b 8192

## This determine how long to wait in burst of events
--backlog_wait_time 60000

## Set failure mode to syslog
-f 1


{{ auditd_rules_1 }}
{{ auditd_rules_2 }}
{{ auditd_rules_3 }}
```  