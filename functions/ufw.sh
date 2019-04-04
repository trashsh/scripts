#!/bin/bash
declare -x -f ufwAddPort
declare -x -f ufwOpenPorts

#Добавление порта с исключением в firewall ufw
#TODO Добавить INPUT в меню
###input
#$1-port ;
#$2-protocol ;
#$3-комментарий ;
###return
#0 - выполнено успешно,
#1 - не переданы параметры,
#2 - ошибка добавления правила
ufwAddPort() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		ufw allow $1/$2 comment $3 && return 0 || return 2
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"ufwAddPort\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Вывод открытых портов ufw
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
#TODO Добавить INPUT в меню
ufwOpenPorts() {
    netstat -ntulp
}