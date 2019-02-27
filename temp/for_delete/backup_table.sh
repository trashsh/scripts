#!/bin/bash
source /etc/profile
source ~/.bashrc
# $1-username process; # $2-база данных, $3-путь к расположению бэкапа? $4 - название таблицы

mysql -e "mysqldump -c $2 $4 > $3;"