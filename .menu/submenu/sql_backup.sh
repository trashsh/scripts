#!/bin/bash
#$1-username process
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Резервное копирование баз данных===${COLOR_NC}"

echo '1: Создать копию всех баз всего сервера'
echo '2: Создать копию всех баз конкретного пользователя'
echo '3: Создать копию одной базы'
echo '4: Восстановить из бэкапа сервер баз данных'
echo '5: Восстановить из бэкапа все базы пользователя'
echo '6: Восстановить из бэкапа одну базу'

echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  sudo $SCRIPTS/mysql/backup_all_bases.sh $1; break;;
        "2")  $SCRIPTS/mysql/backup_all_bases_user.sh $1; break;;
		"3")  $SCRIPTS/mysql/mysql_backup_base.sh $1; break;;
        "4")  $SCRIPTS/mysql/ $1; break;;
		"5")  $SCRIPTS/mysql/ $1; break;;
        "6")  $SCRIPTS/mysql/ $1; break;;
		"0")  $MENU/menu_sql.sh $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0