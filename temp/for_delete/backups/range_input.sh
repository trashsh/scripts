#!/bin/bash
#$1-$USERNAME process;
source /etc/profile
source ~/.bashrc

echo ''
echo -e -n "$COLOR_BLUE"Укажите первую дату диапазона в формате yyyymmdd:" $COLOR_NC"
read DATE1
echo -e -n "$COLOR_BLUE"Укажите последнюю дату диапазона в формате yyyymmdd:" $COLOR_NC"
read DATE2

echo -e "$COLOR_YELLOW"Список бэкапов $DATE1 - $DATE2" $COLOR_NC"

start_ts=$(date -d "$DATE1" '+%s')
end_ts=$(date -d "$DATE2" '+%s')
range=$(( ( end_ts - start_ts )/(60*60*24) ))
echo -e "$COLOR_BROWN" Базы данных mysql:" $COLOR_NC"

n=0
for ((i=0; i<${range#-}+1; i++)) 
do 
	DATE=$(date --date=''$i' days ago' "+%Y.%m.%d");
	if [ -d "$BACKUPFOLDER_DAYS"/"$DATE" ] ; then
		echo -e "$COLOR_BROWN"$DATE:" $COLOR_NC"
		ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
		n=$(($n+1))
	fi

done
	echo $n