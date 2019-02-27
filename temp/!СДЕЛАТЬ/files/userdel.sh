#!/bin/bash
#удалить пользователя mysql
#$1-username
source /etc/profile
source ~/.bashrc

echo ''
$SCRIPTS/info/mysql/users_view.sh
echo -e "\n$COLOR_YELLOW Удаление пользователя mysql$COLOR_NC"
read -p "Введите имя пользователя: " username
	
	echo -n -e "Для удаления пользователя mysql $COLOR_YELLOW" $username "$COLOR_NC введите $COLOR_BLUE\"delete\"$COLOR_NC, для выхода - $COLOR_BLUE\"n\"$COLOR_NC: "
	
	while read
		do
			echo -n ": "
			case "$REPLY" in
			delete) $SCRIPTS/mysql/make/userdel_make.sh $1 $username
					break;;
			n|N)  $MENU/user.sh $1
					break;;
			esac
		done

 $SCRIPTS/info/mysql/full_info.sh
	
