#!/bin/bash

declare -x -f certExist #Проверка существования сертификатов для домена:
#Проверка существования сертификатов для домена
###input
#$1-username ;
#$2-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь
#3 - сертификаты не сущевуют
certExist() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует

			    ARCHDIR=/etc/letsencrypt/archive/$2

                #Проверка существования файла ""$ARCHDIR"/"privkey1.pem""
                if [ -d $ARCHDIR ] ; then
                    echo -e "${COLOR_RED}Сертификат для домена ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует в каталоге ${COLOR_GREEN}\"$ARCHDIR\"${COLOR_RED}. Ошибка выполнения функции certExist${COLOR_NC}"
                    return 0
                else
                    return 3
                fi
                #Конец проверки существования файла ""$ARCHDIR"/"privkey1.pem""
                
                
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"certExist\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"certExist\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f site_AddSSL #добавление ssl-сертификата для пользователя:
#добавление ssl-сертификата для пользователя
###input
#$1-user ;
#$2-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
site_AddSSL() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
        certbot --nginx -d $2 -d www.$2
        backupSslCert $1 $2
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAddSSL\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}