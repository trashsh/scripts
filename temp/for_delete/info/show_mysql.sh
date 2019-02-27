#!/bin/bash
source /etc/profile
source ~/.bashrc
# $1-username process; $2-user
#отображение информации phpmyadmin
echo ''
echo -e "$COLOR_YELLOW"Реквизиты PHPMYADMIN" $COLOR_NC"

		echo -e "Пользователь: $COLOR_YELLOW" $2 "$COLOR_NC"
		echo -e "Сервер: $COLOR_YELLOW" http://$MYSERVER:$APACHEHTTPPORT/$PHPMYADMINFOLDER "$COLOR_NC"
		echo -e "\n${COLOR_YELLOW}Пользователь MySQL:"
		cat $HOMEPATHWEBUSERS/$2/.my.cnf
		echo -e "${COLOR_NC}"
		echo "--------------------------------------"

