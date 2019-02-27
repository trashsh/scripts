#!/bin/bash
# $1-username process; $2-user, $3-db
source /etc/profile
source ~/.bashrc

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] 
then
	mysql -e "GRANT ALL ON $3.* TO '$2'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	echo -e "$COLOR_YELLOW"Права администратора для пользователя $2 на базу $3 добавлены" $COLOR_NC"
	echo -e "$COLOR_LIGHT_PURPLEПрава администратора для пользователя  $COLOR_YELLOW$2$COLOR_LIGHT_PURPLE на базу $3 $COLOR_NC $COLOR_LIGHT_PURPLEдобавлены $COLOR_NC"
else
       echo "--------------------------------------"
    echo "Параметры запуска не найдены. Необходимы параметры: Имя пользователя, Название базы данных"
    echo -n "Для запуска меню управление mysql напишите \"y\", для выхода - любой другой символ: "
    read item
    case "$item" in
        y|Y) $MENU/menu_sql.sh $1
            ;;
        *) echo "Выход..."
            exit 0
            ;;
    esac
fi


