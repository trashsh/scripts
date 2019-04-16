#!/bin/bash
declare -x -f input_siteAddSSL #Добавить ssl-сертификат для сайта: ($1-username ; $2-domain)
###!Полностью готово. Не трогать больше
#Добавить ssl-сертификат для сайта
###input
#$1-username ;
#$2 - mode:manual/auto
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - каталог сайта не существует
#4 - ошибка передачи mode:manual/auto
input_siteAddSSL() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
	    case "$2" in
	        manual|auto)
	            true
	            ;;
	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_siteAddSSL\"${COLOR_NC}";
	    	    return 4
	    	    ;;
	    esac
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
            echo "Добавление SSL-сертификата для сайта"
            echo -n -e "${COLOR_GREEN}\nДобавление SSL-сертификата для сайта${COLOR_NC}: "
            echo -n -e "${COLOR_YELLOW}\nСписок имеющихся доменов для пользователя $1:${COLOR_NC}: "
            ls $HOMEPATHWEBUSERS/$1
            echo -n -e "${COLOR_BLUE}\nВведите домен для добавления ему SSL-сертификата${COLOR_NC}: "
            read domain

            WEBFOLDER=$HOMEPATHWEBUSERS/$1/$domain
                #Проверка существования каталога "$WEBFOLDER"
                if [ -d $WEBFOLDER ] ; then
                    #Каталог "$WEBFOLDER" существует
                    case "$2" in
                        manual)
                            site_AddSSL $1 $domain manual
                            ;;
                        auto)
                            site_AddSSL $1 $domain auto
                            ;;
                    	*)
                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_siteAddSSL\"${COLOR_NC}";
                    	    ;;
                    esac

                    #Каталог "$WEBFOLDER" существует (конец)
                else
                    #Каталог "$WEBFOLDER" не существует
                    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$WEBFOLDER\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteAddSSL\"${COLOR_NC}"
                    return 3
                    #Каталог "$WEBFOLDER" не существует (конец)
                fi
                #Конец проверки существования каталога "$WEBFOLDER"


			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteAddSSL\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_siteAddSSL\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}