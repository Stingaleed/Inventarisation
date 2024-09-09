#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   exec sudo "$0" "$@"
fi



############ hostname and ip  ############

echo "############ hostname and ip  ############"

hostnamectl | awk -F: '/Static hostname/ {hostname=$2} /Operating System/ {os=$2} /Kernel/ {kernel=$2} END {print "Hostname:" hostname; print "Operating System:" os; print "Kernel:" kernel}'

ip addr show|grep inet|grep -e "10" |cut -d/ -f1|sed "s/inet //"|sed "s/ //g" | awk '{print "IP: " $1}'

############ Открытые порты ############

echo "############ open ports  ############"

ss -tulnp4 | awk '/LISTEN/ {split($5, a, ":"); print $1, a[1], a[2], $NF}'

############ Инвентаризация паетов пользователей и групп ############ 

echo "############ pckg  ############"
# Информация об установленных пакетах + описание
#dpkg-query -W -f='${Package};${Version};${binary:Summary}\n'

echo "############ users and groups  ############"

awk -F: '{ print $1,$3 }' /etc/passwd | while read username uid; do 
  groups=$(id -Gn $username | tr ' ' ';')
  echo "$username,$uid,$groups" 
done 

echo "############ groups ############"

awk -F: '{ print $1 }' /etc/group


############ Инвентаризация запущенных сервисов ############


echo "############ processes  ############"

# Получаем список всех запущенных процессов с именами команд
processes=$(ps -eo comm)

# Удаляем первую строку (заголовок) и оставляем только уникальные имена процессов
unique_processes=$(echo "$processes" | tail -n +2 | sort | uniq)

# Проверяем каждый уникальный процесс
for process in $unique_processes; do
  # Находим все PID процесса с данным именем
  pids=$(pgrep -x $process)
  
  # Переменная для хранения путей к исполняемым файлам
  exe_paths=()
  
  # Проверяем каждый PID и находим путь к исполняемому файлу
  for pid in $pids; do
    # Получаем путь к исполняемому файлу, если возможно
    exe_path=$(readlink -f /proc/$pid/exe 2>/dev/null)
    
    # Если путь найден и еще не добавлен в список, добавляем его
    if [[ -n "$exe_path" && ! " ${exe_paths[@]} " =~ " ${exe_path} " ]]; then
      exe_paths+=("$exe_path")
    fi
  done
  
  # Выводим имя процесса и все уникальные пути к исполняемым файлам
  if [ ${#exe_paths[@]} -gt 0 ]; then
    echo "$process (${exe_paths[*]})"
  else
    echo "$process"
  fi
done