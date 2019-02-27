#!/bin/bash
# $1-username process; $2-user
source /etc/profile
source ~/.bashrc

if [ -n "$1" ] && [ -n "$2" ] 
then
	mysql -e "DROP USER '$2'@'localhost';"
	mysql -e "DROP USER '$2'@'%';"
	echo -e "$COLOR_LIGHT_PURPLEПользователь $COLOR_YELLOW$2$COLOR_LIGHT_PURPLE удален $COLOR_NC"
else
       echo "--------------------------------------"
    echo "Параметры запуска не найдены. Необходимы параметры: имя пользователя mysql"
	fileParamsNotFound "$1" "Для запуска меню управления базами данных MYSQL введите" "$MENU/sql.sh"
fi

