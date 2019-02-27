#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN}===Добавление сайта===${COLOR_NC}"

echo '1: PHP/HTML'
echo '2: PHP/HTML (с вводом доп.параметров)'
echo '3: Framework Laravel'
echo '4: Framework Laravel (с вводом доп.параметров)'


echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $SCRIPTS/webserver/site/input_site_php_easy.sh $1; break;;
        "2")  $SCRIPTS/webserver/site/site_php_full.sh $1; break;;
		"3")  $SCRIPTS/webserver/site/input_site_laravel_easy.sh $1; break;;
		"4")  $SCRIPTS/webserver/site/site_laravell_full.sh $1; break;;		
		"0")  $SCRIPTS/.menu/menu_site.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0