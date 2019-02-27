#!/bin/bash
source /etc/profile
source ~/.bashrc
#Создание бэкапа всех баз на сервере
#$1-$USERNAME process; $2 - BACKUPPATH, $3-type, $4-$USER $5-$PASSWORD


if [ -n "$1" ] && [ -n "$2" ] 
then

		mysql -e "show databases;"
		d=`date +%Y.%m.%d`;
		dt=`date +%Y%m%d_%H%M`;

		#rm "BACKUPPATH/*gz" > /dev/null 2>&1

		echo -e "${COLOR_YELLOW}Список имеющихся баз данных на сервере: ${COLOR_NC}"
		databases=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

	for db in $databases; do
		if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
			echo -e "Dumping database: $COLOR_YELLOW$db$COLOR_NC"
			
		case $3 in
			"1")
				mysqldump --databases $db > $2$db.$dt.sql
#				$SCRIPTS/archive/tar_with_structure_remove_original.sh $2$db.$dt.sql $2 $db.$dt.sql
#				tar -czvf $2$db.$dt.sql.tar.gz $2$db.$dt.sql --remove-files
				;;
			"2")
				mysqldump -u$4 -p$5 --databases $db > $2$db.$dt.sql
#				$SCRIPTS/archive/tar_with_structure_remove_original.sh $2$db.$dt.sql $2 $db.$dt.sql
#				tar -czvf $2$db.$dt.sql.tar.gz $2$db.$dt.sql --remove-files
				;;
			*)
				echo "Ошибка передачи параметров"
				;;
		esac	
				$SCRIPTS/archive/tar_with_structure_remove_original.sh $2$db.$dt.sql.tar.gz $2 $db.$dt.sql		
			
		fi		
done
$MENU/submenu/sql_backup.sh $1
  
fi




















