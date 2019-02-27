#!/bin/bash
#$1-$USERNAME process;
source /etc/profile
source ~/.bashrc

echo ''
TODAY=$(date +%Y.%m.%d)
DATE=$(date --date='7 days ago' "+%Y.%m.%d")
echo -e "$COLOR_YELLOW"Список бэкапов за Неделю - $DATE-$TODAY" $COLOR_NC"

for ((i=0; i<7; i++)) 
do 
	DATE=$(date --date=''$i' days ago' "+%Y.%m.%d");
	if [ -d "$BACKUPFOLDER_DAYS"/"$DATE" ] ; then
		echo -e "$COLOR_BROWN"$DATE:" $COLOR_NC"
		ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
	fi
done






