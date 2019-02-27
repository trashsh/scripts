#!/bin/bash
source /etc/profile
source ~/.bashrc
# $1-username process; $2-user
#отображение информации SSH-сервера
echo ''
echo -e "$COLOR_YELLOW"Реквизиты SSH-Доступа" $COLOR_NC"

		echo -e "Пользователь: $COLOR_YELLOW" $2 "$COLOR_NC"
		echo -e "Сервер: $COLOR_YELLOW" $MYSERVER "$COLOR_NC"
		echo -e "Порт $COLOR_YELLOW" $SSHPORT "$COLOR_NC"
		echo "--------------------------------------"

