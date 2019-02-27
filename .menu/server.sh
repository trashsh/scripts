#!/bin/bash
source $SCRIPTS/include/include.sh
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление Сервером===${COLOR_NC}"
echo '1: Firewall ufw'
echo '2: Quota'

echo '9: Перезапустить Apache2 и Nginx'
echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $MENU/submenu/server_firewall.sh $1;  break;;
		"2")  $MENU/submenu/server_quota.sh $1;  break;;
		"9")  $SCRIPTS/system/webserver/webserver_restart.sh $1; break;;
		"0")  $MYFOLDER/scripts/menu $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0