#!/bin/bash
source /etc/profile
source ~/.bashrc
#$1-$USERNAME process;

echo ''
echo -e -n "$COLOR_BLUE"Укажите дату в формате yyyymmdd:" $COLOR_NC"

read DATE

 if [ -d "$BACKUPFOLDER_DAYS"/"$DATE"/"mysql" ] ; then
    echo -e "$COLOR_YELLOW"Список бэкапов $DATE" $COLOR_NC"
	echo -e "$COLOR_BROWN"$DATE - Базы данных mysql:" $COLOR_NC"
	ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
 else
	echo -e "$COLOR_REDБэкапы mysql за $(date --date yesterday "+%Y.%m.%d") отсутствуют$COLOR_NC"
 fi
