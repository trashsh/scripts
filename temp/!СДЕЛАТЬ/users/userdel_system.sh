#!/bin/bash
#удалить системного пользователя
#$1-username
source /etc/profile
source ~/.bashrc
source $SCRIPTS/info/users_info/users_info.sh

viewGroupUsersAccessAll

echo -e "\n$COLOR_YELLOWУдаление системного пользователя  $COLOR_NC"
read -p "Введите имя пользователя: " username
	
	echo -n -e "Для удаления системного пользователя $COLOR_YELLOW" $username "$COLOR_NC введите $COLOR_BLUE\"y\"$COLOR_NC, для выхода - $COLOR_BLUE\"n\"$COLOR_NC: "
	
	while read
		do
			echo -n ": "
			case "$REPLY" in
			y|Y) userdel -r $username
				 $SCRIPTS/mysql/make/userdel_make.sh $1 $username
					$MENU/user.sh
					break;;
			n|N)  $MENU/user.sh $1
					break;;
			esac
		done

