#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Просмотр списка пользователей/групп===${COLOR_NC}"

echo "1: Члены группы \"Users\""
echo "2: Члены группы \"sudo\""
echo "3: Члены группы \"ssh-access\""
echo "4: Список групп конкретного пользователя"
echo "0: Назад"
echo "q: Выход"
echo ""
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $SCRIPTS/info/users_info/users.sh $1; break;;
		"2")  $SCRIPTS/info/users_info/sudo_add.sh $1; break;;
		"3")  $SCRIPTS/info/users_info/ssh-access.sh $1; break;;
		"4")  $SCRIPTS/info/users_info/useringroup.sh $1; break;;
		"0")  $SCRIPTS/.menu/user.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0