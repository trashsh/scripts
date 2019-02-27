#!/bin/bash
#$1-$USERNAME process;
source /etc/profile
source ~/.bashrc

echo ''
DATE=$(date +%Y.%m.%d)

 if [ -d "$BACKUPFOLDER_DAYS"/"$DATE"/"mysql" ] ; then
    echo -e "$COLOR_YELLOW"Список бэкапов за сегодня - $DATE" $COLOR_NC"
	echo -e "$COLOR_BROWN"$BACKUPFOLDER_DAYS/$DATE/mysql:" $COLOR_NC"
	ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
 else
	echo -e "$COLOR_REDБэкапы mysql за $(date --date today "+%Y.%m.%d") отсутствуют$COLOR_NC"
 fi