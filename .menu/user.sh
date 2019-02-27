#!/bin/bash
source /my/scripts/include/include.sh
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление пользователями===${COLOR_NC}"

echo '1: Добавить пользователя ssh'
#echo '2: Добавить пользователя web'
#echo '3: Удаление пользователя'
#echo '4: Список пользователей'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  userAddSystem; break;;
#        "2")  sudo $SCRIPTS/users/useradd_web.sh $1; break;;
#		"3")  sudo $SCRIPTS/users/userdel_system.sh $1; break;;
#		"4")  $MENU/submenu/users_info.sh $1; break;;
		"0")  $MYFOLDER/scripts/menu $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done

exit 0