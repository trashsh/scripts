#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Пользователями базы данных===${COLOR_NC}"

echo '1: Добавить пользователя'
echo '2: Удалить пользователя'
echo '3: Просмотр списка пользователей'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $SCRIPTS/mysql/useradd.sh $1; break;;
        "2")  $SCRIPTS/mysql/userdel.sh $1; break;;
		"3")  $SCRIPTS/mysql/usersview.sh $1; break;;
		"0")  $MENU/menu_sql.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0