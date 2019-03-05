#!/bin/bash


declare -x -f fileParamsNotFound	#Вывод сообщения с предложением запуска указанного в параметре 3 меню. #$1-user; $2-сообщение; $3-ссылка на скрипт меню для запуска



#######Полностью протестировано







#Вывод сообщения с предложением запуска указанного в параметре 3 меню
#$1-user; $2-сообщение; $3-ссылка на скрипт меню для запуска
fileParamsNotFound(){
echo -n -e "${COLOR_YELLOW}$2 ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода введите ${COLOR_BLUE}\"n\"${COLOR_NC}:"
	while read
		do
			echo -n ": "
			case "$REPLY" in
			y|Y) echo "$2"
				$3 $1;
					break;;
			n|N)  break;;
			esac
		done
		
}







