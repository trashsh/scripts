#!/bin/bash

declare -x -f input_backupEtcFolder #Создание бэкапа каталога в etc
#Создание бэкапа каталога в etc
###input
#$1-username
###return
#0 - выполнено успешно
#1 - Отсутствуют параметры
#2 - пользователь не существует
#3 - каталог etcFolder не существует
input_backupEtcFolder() {
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ]
    then
    #Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		ls -d /etc/*/ | xargs -n 1 basename
                echo -n -e "${COLOR_BLUE}\nАрхивация каталога из папки /etc в каталог бэкапов: ${COLOR_NC}\n"
                read -p "Введите название каталога в папке /etc для архивации: " etcFolder
                #Проверка существования каталога "/etc/$etcFolder"
                if [ -d /etc/$etcFolder ] ; then
                    #Каталог "/etc/$etcFolder" существует
                        backupImportantFolder $1 $etcFolder /etc/$etcFolder
                    #Каталог "/etc/$etcFolder" существует (конец)
                else
                    #Каталог "/etc/$etcFolder" не существует
                    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"/etc/$etcFolder\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_backupEtcFolder\"${COLOR_NC}"
                    return 3
                    #Каталог "/etc/$etcFolder" не существует (конец)
                fi
                #Конец проверки существования каталога "/etc/$etcFolder"
        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_backupEtcFolder\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1


    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"input_backupEtcFolder\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта



}