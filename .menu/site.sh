#!/bin/bash
source $SCRIPTS/include/include.sh
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление сайтами===${COLOR_NC}"

echo '1: Добавить сайт на сервер'
echo '2: Удаление сайта с сервера'
echo '3: Список виртуальных хостов на сервере'
echo '4: Сертификаты'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $MENU/submenu/site_add.sh $1; break;;
        "2")  $SCRIPTS/webserver/remove/remove_site.sh $1; break;;
		"3")  $SCRIPTS/info/site_info/show_sites.sh $1; break;;
		"4")  $MENU/submenu/site_cert.sh $1; break;;		
		"0")  $MYFOLDER/scripts/menu $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0