#!/bin/bash
source $SCRIPTS/include/include.sh
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление базами данных===${COLOR_NC}"

echo '1: Добавить базу данных'
echo '2: Управление пользователями баз данных'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $SCRIPTS/sql/db_create.sh $1;  break;;
        "2")  $MENU/menu_sql_users.sh $1;  break;;
		"0")  $MYFOLDER/scripts/menu $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done

	