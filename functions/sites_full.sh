#!/bin/bash

declare -x -f siteAddTestIndexFile
#Добавление тестового индексного файла при добавлении домена
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1 - user
#$2-domain ;
#$3 - wwwfolder_name
#$4-mode: replace/noreplace ;
#$5-mode (type index file): phpinfo ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - каталог $HOMEPATHWEBUSERS/$1/$2/$3 не существует
#4 - ошибка передачи параметра mode: replace/noreplace
#5 - ошибка передачи параметра mode (type index file): phpinfo
siteAddTestIndexFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				#Проверка существования каталога "$HOMEPATHWEBUSERS/$1/$2/$3"
				if [ -d $HOMEPATHWEBUSERS/$1/$2/$3 ] ; then
				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" существует

				    case "$4" in
				        replace)

                            case "$5" in
                                phpinfo)
                                     sudo cp -f $TEMPLATES/index_php/index.php $HOMEPATHWEBUSERS/$1/$2/$3/index.php
                                     sudo cp -f $TEMPLATES/index_php/underconstruction.jpg $HOMEPATHWEBUSERS/$1/$2/$3/underconstruction.jpg
                                     sudo grep '#__DOMAIN' -P -R -I -l  $HOMEPATHWEBUSERS/$1/$2/$3/index.php | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' $HOMEPATHWEBUSERS/$1/$2/$3/index.php;
                                     return 0
                                    ;;

                            	*)
                            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode - (type index file)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}";
                            	    return 5
                            	    ;;
                            esac
				            ;;
				        noreplace)
                            case "$5" in
                                phpinfo)
                                     sudo cp -n $TEMPLATES/index_php/index.php $HOMEPATHWEBUSERS/$1/$2/$3/index.php
                                     sudo cp -n $TEMPLATES/index_php/underconstruction.jpg $HOMEPATHWEBUSERS/$1/$2/$3/underconstruction.jpg
                                     sudo grep '#__DOMAIN' -P -R -I -l  $HOMEPATHWEBUSERS/$1/$2/$3/index.php | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' $HOMEPATHWEBUSERS/$1/$2/$3/index.php;
                                     return 0
                                    ;;

                            	*)
                            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode - (type index file)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}";
                            	    return 5
                            	    ;;
                            esac
				            ;;
				    	*)
				    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}";
				    	    return 4
				    	    ;;
				    esac

				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" существует (конец)
				else
				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" не существует
				    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2/$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}"
				    return 3
				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" не существует (конец)
				fi
				#Конец проверки существования каталога "$HOMEPATHWEBUSERS/$1/$2/$3"

			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f siteRemoveWebserverConfig
###!Полностью готово. Не трогать больше
#Удаление конфигов веб-серверов
###input
#$1-user ;
#$2-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
siteRemoveWebserverConfig() {
  #  echo $1_$2.conf
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
#	    echo "$NGINXENABLED"/"$1_$2.conf"
		if [ -f "$NGINXENABLED"/"$1_$2.conf" ] || [ -L "$NGINXENABLED"/"$1_$2.conf" ]; then
            sudo rm -f "$NGINXENABLED"/"$1_$2.conf"
        fi

        if [ -f "$NGINXAVAILABLE"/"$1_$2.conf" ] || [ -L "$NGINXAVAILABLE"/"$1_$2.conf" ]; then
            sudo rm -f "$NGINXAVAILABLE"/"$1_$2.conf"
        fi

        if [ -f "$APACHEENABLED"/"$1_$2.conf" ] || [ -L "$APACHEENABLED"/"$1_$2.conf" ]; then
            sudo rm -f "$APACHEENABLED"/"$1_$2.conf"
        fi

#        echo "$APACHEAVAILABLE"/"$1_$2.conf"
        if [ -f "$APACHEAVAILABLE"/"$1_$2.conf" ] || [ -L "$APACHEAVAILABLE"/"$1_$2.conf" ]; then
            sudo rm -f "$APACHEAVAILABLE"/"$1_$2.conf"
        fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemoveWebserverConfig\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
