#!/bin/bash
source $SCRIPTS/include/include.sh
source /etc/profile
source ~/.bashrc
echo ''
echo -e "${COLOR_GREEN} ===Управление Git===${COLOR_NC}"

echo '1: Git commit'
echo '2: Push remote'
echo '3: Git remote view'


echo '0: Назад'
echo 'q: Выход'
echo ''
echo -n 'Выберите пункт меню:'

while read
    do
        case "$REPLY" in
        "1")  $SCRIPTS/git/commit.sh $1; break;;
        "2")  $SCRIPTS/git/remote_push.sh $1; break;;
		"3")  $SCRIPTS/git/remote_view.sh $1; break;;
		"0")  $MYFOLDER/scripts/menu $1;  break;;
        "q"|"Q")  exit 0;; 
         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done
exit 0