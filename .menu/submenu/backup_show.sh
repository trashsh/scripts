#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Просмотр списка бэкапов===${COLOR_NC}"

echo '1: Бэкапы за сегодняшний день'
echo '2: Бэкапы за вчерашний день'
echo '3: Бэкапы за последнюю неделю'
echo '4: Указать дату'
echo '5: Указать диапазон дат'


echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $SCRIPTS/info/backups_info/today.sh $1; break;;
        "2")  $SCRIPTS/info/backups_info/yestoday.sh $1; break;;
		"3")  $SCRIPTS/info/backups_info/week.sh $1; break;;
		"4")  $SCRIPTS/info/backups_info/range.sh $1; break;;
		"5")  $SCRIPTS/info/backups_info/range_input.sh $1; break;;
		"0")  $SCRIPTS/.menu/menu_backup.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0