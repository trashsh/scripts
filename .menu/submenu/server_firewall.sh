#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление ufw===${COLOR_NC}"

echo '1: Добавить открытый порт'
echo '2: Просмотр открытых портов'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")   $SCRIPTS/system/firewall/ufw_add_port.sh $1;  break;;
		"2")  $SCRIPTS/system/firewall/ufw_ports.sh $1; break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0