#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление Сертификатами===${COLOR_NC}"

echo '1: certbot certificates'
echo '2: letsencrypt'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  sudo certbot certificates $1; break;;
        "2")  sudo letsencrypt $1; break;;
		"0")  $SCRIPTS/.menu/site.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0