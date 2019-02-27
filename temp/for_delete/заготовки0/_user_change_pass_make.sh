#!/bin/bash
# $1-username process; $2-user; $3-pass
source /etc/profile
source ~/.bashrc

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] 
then
	mysql -e "ALTER USER '$2'@'localhost' IDENTIFIED WITH mysql_native_password BY '$3';"
	echo -e "$COLOR_LIGHT_PURPLEПароль пользователя $2 изменен $COLOR_NC"
else
       echo "--------------------------------------"
    echo "Параметры запуска не найдены. Необходимы параметры: имя пользователя mysql, пароль"
    fileParamsNotFound "$1" "Для запуска меню управления базами данных MYSQL введите" "$MENU/sql.sh"
fi



