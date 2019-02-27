#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Quota===${COLOR_NC}"

echo '1: Отчет'


echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  repquota -a; break;;

		"0")  $SCRIPTS/.menu/server.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0