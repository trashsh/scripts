#!/bin/bash
source $SCRIPTS/include/include.sh
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление бэкапами===${COLOR_NC}"

echo '1: Создать файловый бэкап сайта'
echo '2: Восстановить файловый бэкап сайта'
echo '3: Создать бэкап баз данных mysql'
echo '4: Восстановить бэкап баз данных mysql'
echo '5: Просмотр бэкапов'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  sudo $SCRIPTS/backups/backup_path.sh $1; break;;
        "2")  echo "В разработке"; break;;
		"3")  $MENU/menu_sql_backup.sh $1; break;;
		"4")  echo "В разработке"; break;;
		"5")  $MENU/submenu/backup_show.sh $1; break;;
		"0")  $MYFOLDER/scripts/menu $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0