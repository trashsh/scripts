#!/bin/bash
declare -x -f siteAdd_php
#Добавление php-сайта
###input
#$1-username-кому добавляется сайт ;
#$2-domain ;
#$3-site_path ;
#$4-apache_config ;
#$5-nginx_config ;
#$6-username - кем добавляется сайт;
###return
#0 - выполнено успешно
#1 - отсутствуют параметры
#2 - пользователь $1 не  существует
#3 - конфигурация apache не существует
#4 - конфигурация nginx не существует
#5 - каталог сайта уже существует
siteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ]
	then
	#Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка существования файла "$TEMPLATES/apache2/$4"
        		if [ -f $TEMPLATES/apache2/$4 ] ; then
        		    #Файл "$TEMPLATES/apache2/$4" существует
        		    #Проверка существования файла "$TEMPLATES/nginx/$5"
        		    if [ -f $TEMPLATES/nginx/$5 ] ; then
        		        #Файл "$TEMPLATES/nginx/$5" существует
                        #Проверка существования каталога "$3"
                        if [ -d $3 ] ; then
                            #Каталог сайта "$3" уже существует
                            echo -e "${COLOR_RED}Каталог сайта ${COLOR_GREEN}\"$3\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
                            return 5
                            #Каталог сайта "$3" уже существует (конец)
                        else
                            #Каталог сайта "$3" не существует

                            #добавление ftp-пользователя
                            FtpUserAdd $1 $2 autogenerate site_user $6
                            sudo cp -R /etc/skel/* $3

                            siteAddTestIndexFile $1 $2 public_html replace phpinfo

                           #nginx
                           sudo cp -rf $TEMPLATES/nginx/$5 /etc/nginx/sites-available/"$1"_"$2".conf
                           chModAndOwnFile /etc/nginx/sites-available/"$1"_"$2".conf $1 www-data 644

                           siteChangeWebserverConfigs nginx $1 $2 $HTTPNGINXPORT

                           siteStatus $1 $2 nginx enable

                            #apache2
                           sudo cp -rf $TEMPLATES/apache2/$4 /etc/apache2/sites-available/"$1"_"$2".conf
                           chModAndOwnFile /etc/apache2/sites-available/"$1"_"$2".conf $1 www-data 644
                            siteChangeWebserverConfigs apache $1 $2 $APACHEHTTPPORT

                            siteStatus $1 $2 apache enable

                            chModAndOwnSiteFileAndFolder $3 $WWWFOLDER $1 644 755

                            dbCreateBase $1_$2 utf8 utf8_general_ci error_only
                            mysqlpassword="$(openssl rand -base64 14)";

                            dbUseraddForDomain $1_$2 $mysqlpassword $6 $2 localhost pass user





                            cd $3/$WWWFOLDER
                            #echo -e "\033[32m" Инициализация Git "\033[0;39m"
                            git init
                            git config user.email "$1@$2"
                            git config user.name "$1"
                            git add .
                            git commit -m "initial commit"

                            viewAccessDetail $HOMEPATHWEBUSERS/$6/$2 full_info
                            #Каталог сайта "$3" не существует (конец)
                        fi
                        #Конец проверки существования каталога "$3"

        		        #Файл "$TEMPLATES/nginx/$5" существует (конец)
        		    else
        		        #Файл "$TEMPLATES/nginx/$5" не существует
        		        echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		        return 4
        		        #Файл "$TEMPLATES/nginx/$5" не существует (конец)
        		    fi
        		    #Конец проверки существования файла "$TEMPLATES/nginx/$5"

        		    #Файл "$TEMPLATES/apache2/$4" существует (конец)
        		else
        		    #Файл "$TEMPLATES/apache2/$4" не существует
        		    echo -e "${COLOR_RED}Конфигурация apache2 ${COLOR_GREEN}\"$TEMPLATES/apache2/$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		    return 3
        		    #Файл "$TEMPLATES/apache2/$4" не существует (конец)
        		fi
        		#Конец проверки существования файла "$TEMPLATES/apache2/$4"

        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f siteChangeWebserverConfigs
#Замена переменных в конфигах веб-серверов
###input
#$1-webserver(apache/nginx)
#$2-username ;
#$3-domain ;
#$4-port ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - ошибка передачи параметра mode:webserver(apache/nginx)
#3 - пользователь $2 не существует
#4 - файл "$path"/"$2"_"$3".conf не существует
siteChangeWebserverConfigs() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
        case "$1" in
            apache)
                path="/etc/apache2/sites-available"
                ;;
            nginx)
                path="/etc/nginx/sites-available"
                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: webserver\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_NC}";
        	    return
        	    ;;
        esac

        #Проверка существования системного пользователя "$2"
        	grep "^$2:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $2 существует
        		#Проверка существования файла ""$path"/"$2"_"$3".conf"
        		if [ -f "$path"/"$2"_"$3".conf ] ; then
        		    #Файл ""$path"/"$2"_"$3".conf" существует


                           #sudo echo "Замена переменных в файле "$path"/"$2"_"$3".conf"
                           sudo grep '#__DOMAIN' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/#__DOMAIN/'$3'/g' "$path"/"$2"_"$3".conf
                           sudo grep '#__USER' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/#__USER/'$2'/g' "$path"/"$2"_"$3".conf

                           sudo grep '#__PORT' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/#__PORT/'$4'/g' "$path"/"$2"_"$3".conf
                           sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/'#__HOMEPATHWEBUSERS'/\/home\/webusers/g' "$path"/"$2"_"$3".conf
                            return 0

        		    #Файл ""$path"/"$2"_"$3".conf" существует (конец)
        		else
        		    #Файл ""$path"/"$2"_"$3".conf" не существует
        		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\""$path"/"$2"_"$3".conf\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_NC}"
        		    return 4
        		    #Файл ""$path"/"$2"_"$3".conf" не существует (конец)
        		fi
        		#Конец проверки существования файла ""$path"/"$2"_"$3".conf"

        	#Пользователь $2 существует (конец)
        	else
        	#Пользователь $2 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_NC}"
        		return 3
        	#Пользователь $2 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $2


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f siteStatus
#включение-выключение сайта
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
###input
#$1-user;
#$2-domain;
#$3-mode: apache/nginx ;
#$4-mode: enable/disable ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - ошибка передачи параметра mode: enable/disable
#3 - ошибка передачи параметра mode: apache/nginx
#4 - файл /etc/nginx/sites-available/$1_$2.conf не существует
#5 - файл $NGINXENABLED"/"$1_$2.conf уже не существует
siteStatus() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		case "$4" in
		    enable)
                case "$3" in
                    apache)
                        sudo a2ensite $1_$2.conf
                        ;;
                    nginx)
                        #Проверка существования файла ""$NGINXAVAILABLE"/"$1_$2.conf""
                        if [ -f "$NGINXAVAILABLE"/"$1_$2.conf" ] ; then
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" существует
                            sudo ln -s "$NGINXAVAILABLE"/"$1_$2.conf" $NGINXENABLED
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" существует (конец)
                        else
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" не существует
                            echo -e "${COLOR_RED}Конфигурация сайта ${COLOR_GREEN}\""$NGINXAVAILABLE"/"$1_$2.conf"\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}"
                            return 4
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" не существует (конец)
                        fi
                        #Конец проверки существования файла ""$NGINXAVAILABLE"/"$1_$2.conf""
                        ;;
                	*)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: apache/nginx\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}";
                	    return 3
                	    ;;
                esac
		        ;;
		    disable)
                case "$3" in
                    apache)
                        sudo a2dissite $1_$2.conf
                        ;;
                    nginx)
                        #Проверка существования файла ""$NGINXENABLED"/"$1_$2.conf""
                        if [ -f "$NGINXENABLED"/"$1_$2.conf" ] ; then
                            #Файл ""$NGINXENABLED"/"$1_$2.conf"" существует
                            sudo rm "$NGINXENABLED"/"$1_$2.conf"
                            #Файл ""$NGINXENABLED"/"$1_$2.conf"" существует (конец)
                        else
                            return 5
                        fi
                        #Конец проверки существования файла ""$NGINXENABLED"/"$1_$2.conf""

                        ;;
                	*)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: apache/nginx\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}";
                	    return 3
                	    ;;
                esac
		        ;;
			*)
			    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: enable/disable\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}";
			    return 2
			    ;;
		esac
		webserverReload
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteStatus\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f siteRemove
#Удаление сайта
###input
#$1-domain ;
#$2-user ;
#$3-mode:createbackup/nocreatebackup ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не найден каталог сайта $2
#3 - ошибка передачи параметра mode:createbackup/nocreatebackup
#4 пользователь $2 не существует
siteRemove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then

	date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`

	#Проверка существования системного пользователя "$2"
		grep "^$2:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $2 существует
			true
		#Пользователь $2 существует (конец)
		else
		#Пользователь $2 не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteRemove\"${COLOR_NC}"
			return 4
		#Пользователь $2 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $2

	path="$HOMEPATHWEBUSERS"/"$2"/"$1"
	pathBackup=$BACKUPFOLDER/vds/removed/$2/$1/$date
	#Параметры запуска существуют
        #Проверка существования каталога "$path"
            case "$3" in
                createbackup)
                    backupSiteWebserverConfig $2 $1 error_only $pathBackup;
                    ##TODO сделать проверку успешности выполнения бэкапа
                    #Проверка существования каталога "$path"
                    if [ -d $path ] ; then
                        #Каталог "$path" существует
                        backupSiteFiles $2 $1 createDestFolder $pathBackup
                        #Каталог "$path" существует (конец)
                    fi
                    #Конец проверки существования каталога "$path"

                    dbBackupBasesOneDomainAndUser $1 $2 full_info data DeleteBase $pathBackup;
                    ;;
                nocreatebackup)
                    true
                    ;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: createbackup/nocreatebackup\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteRemove\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac

                    siteStatus $2 $1 apache disable;
                    siteStatus $2 $1 nginx disable;
                    siteRemoveWebserverConfig $2 $1;
                    siteRemoveLogs $2 $1;

                    #Проверка существования каталога "$path"
                    if [ -d $path ] ; then
                        #Каталог "$path" существует
                        sudo rm -Rf $path
                        #Каталог "$path" существует (конец)
                    fi
                    #Конец проверки существования каталога "$path"

                    #Проверка существования системного пользователя "$2_$1"
                    	grep "^$2_$1:" /etc/passwd >/dev/null
                    	if  [ $? -eq 0 ]
                    	then
                    	#Пользователь $2_$1 существует
                    		userDelete_system $2_$1
                    	#Пользователь $2_$1 существует (конец)
                    	fi
                    #Конец проверки существования системного пользователя $2_$1

                    #удаление ftp-пользователей
                    userDelete_ftpAll $2 $1 delete

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




declare -x -f siteRemoveLogs
#Удаление логов с сайта
###input
#$1-user ;
#$2-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
siteRemoveLogs() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют

		path=$HOMEPATHWEBUSERS/$1/$2
        if [ -f $path/logs/error_apache.log ] ;  then
           sudo rm $path/logs/error_apache.log
        fi

        if [ -f $path/logs/access_apache.log ] ;  then
           sudo rm $path/logs/access_apache.log
        fi

        if [ -f $path/logs/access_nginx.log ] ;  then
           rm $path/logs/access_nginx.log
        fi

        if [ -f $path/logs/error_nginx.log ] ;  then
           sudo rm $path/logs/error_nginx.log
fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemoveLogs\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f siteExist
#Проверка существования сайта
###input
#$1-domain
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - каталог домена имеется в папках пользователей
siteExist() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

                #Пользователь $2 существует
                    [ "$(ls -A $NGINXAVAILABLE | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            nginxAvailableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$NGINXAVAILABLE${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            nginxAvailableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команды
                    #echo nginxAvailableExist=$nginxAvailableExist

                    [ "$(ls -A $NGINXENABLED | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            nginxEnableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$NGINXENABLED${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            nginxEnableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команды
                     #echo nginxEnableExist=$nginxEnableExist

                    [ "$(ls -A $APACHEAVAILABLE | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            apacheAvailableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$APACHEAVAILABLE${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            apacheAvailableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команды
                    #echo apacheAvailableExist=$apacheAvailableExist

                    [ "$(ls -A $APACHEENABLED | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            apacheEnableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$APACHEENABLED${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            apacheEnableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команд
                    #echo apacheEnableExist=$apacheEnableExist


                        #TODO сделать поиск find
                    ls $HOMEPATHWEBUSERS | while read line
                    do
                        echo $HOMEPATHWEBUSERS/$line


                            ls $HOMEPATHWEBUSERS/$line | while read line2
                            do
                                echo $line2
                                if [ $line2 == $1 ]
                                then
                                        echo -e "${COLOR_RED}Каталог домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже имеется в домашней папке пользователя ${COLOR_YELLOW}$line${COLOR_RED} - ${COLOR_GREEN}$HOMEPATHWEBUSERS/$line/$1${COLOR_NC}"
                                        temp=1
                                        break
                                fi
                            (( i++ ))
                            done
                                        		#echo -e "${COLOR_RED}Каталог домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже имеется в домашней папке пользователя ${COLOR_YELLOW}$line${COLOR_RED} - ${COLOR_GREEN}$HOMEPATHWEBUSERS/$line/$1${COLOR_NC}"
                                        		#return 3
                             if [ $temp==1 ]
                             then
                                echo '123'
                                break
                             fi

                    (( i++ ))
                    done

       if [ "$nginxAvailableExist" == "1" ] || [ "$nginxEnableExist" == "1" ] || [ "$apacheAvailableExist" == "1" ] || [ "$apacheEnableExist" == "1" ]
       then
            return 3
       fi

       folderExistWithInfo $HOMEPATHWEBUSERS/$line/$1 exist silent
                                                #Проверка на успешность выполнения предыдущей команды
                                                if [ $? -eq 6 ]
                                                	then
                                                		#предыдущая команда завершилась успешно
                                                		return 3
                                                		#предыдущая команда завершилась успешно (конец)
                                                fi
                                                #Конец проверки на успешность выполнения предыдущей команды
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"siteExist\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

}


declare -x -f viewSiteConfigsByName
#Вывод перечня сайтов указанного пользователя (конфиги веб-сервера)
###input
#$1 - имя пользователя
###return
#0 - выполнено успешно,
#1 - не передан параметр,
#2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
viewSiteConfigsByName(){
	if [ -n "$1" ]
	then
		if [ -d $HOMEPATHWEBUSERS/$1 ] ;  then
            echo -e "\nСписок сайтов в каталоге пользователя ${COLOR_YELLOW}\"$1\"${COLOR_NC}" $HOMEPATHWEBUSERS/$1:
			ls $HOMEPATHWEBUSERS/$1 | echo ""
		else
		    echo -e "${COLOR_RED}Каталог  ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1\"${COLOR_RED} не найден.Ошибка выполнения функции ${COLOR_GREEN}\"viewSiteConfigsByName\"${COLOR_RED}  ${COLOR_NC}"
		    return 2
        fi

		echo -n "Apache - sites-available (user:$1): "
		ls $APACHEAVAILABLE | grep -E "$1.*$1" | echo ""
		echo  -n "Apache - sites-enabled (user:$1): "
		ls $APACHEENABLED | grep -E "$1.*$1" | echo ""
		echo  -n "Nginx - sites-available (user:$1): "
		ls $NGINXAVAILABLE | grep -E "$1.*$1" | echo ""
		echo  -n "Nginx - sites-enabled (user:$1): "
		ls $NGINXENABLED | grep -E "$1.*$1" | echo ""
		echo $LINE
		return 0
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewSiteConfigsByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

declare -x -f viewSiteFoldersByName
#Вывод перечня сайтов указанного пользователя
###input
# $1 - имя пользователя
###return
#0  - выполнено успешно,
#1 - не передан параметр,
#2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
viewSiteFoldersByName(){
	if [ -n "$1" ]
	then
		if [ -d $HOMEPATHWEBUSERS/$1 ] ;  then
            echo -e "\nСписок сайтов в каталоге пользователя ${COLOR_YELLOW}\"$1\"${COLOR_NC}" $HOMEPATHWEBUSERS/$1:
			ls $HOMEPATHWEBUSERS/$1/
			retun 0
		else
			echo -e "${COLOR_RED}Каталог $HOMEPATHWEBUSERS/$1/ не существует. Ошибка выполнения функции viewSiteFoldersByName ${COLOR_NC}"
			return 2
        fi
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewSiteFoldersByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

declare -x -f viewFtpAccess
#отобразить реквизиты доступа к серверу FTP
#Полностью готово. 13.03.2019 г.
###input
#$1 - user;
#$2 - password,
#$3 - port,
#$4 - сервер
###return
#0 - выполнено успешно,
#1 - не переданы параметры
viewFtpAccess(){
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты FTP-Доступа" ${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" $4 "${COLOR_NC}"
		echo -e "Порт ${COLOR_YELLOW}" $3 "${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Пароль: ${COLOR_YELLOW}" $2 "${COLOR_NC}"
		echo $LINE
		return 0
	else
		echo -e "${COLOR_RED}Не переданы параметры в функцию ${COLOR_GREEN}\"viewFtpAccess\"${COLOR_RED}. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}

declare -x -f viewSshAccess
#отобразить реквизиты доступа к серверу SSH
###input
#$1 - user
#$2 - сервер
#$3 - порт
#$4 -  тип подключения (0- по паролю/1 - с использованием ключевого файла) - не обязательно
#$5 -  путь к ключевому файлу (при использовании ключевого файла) - не обязательно
###return
#0 - выполнено успешно,
#1 - отсутствуеют параметры
viewSshAccess(){
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
		echo ""
		echo $LINE
		echo -e "${COLOR_GREEN}"Реквизиты SSH-Доступа" ${COLOR_NC}"
		echo -e "${COLOR_YELLOW}Сервер: ${COLOR_GREEN}" $2 "${COLOR_NC}"
		echo -e "${COLOR_YELLOW}Порт ${COLOR_GREEN}" $3 "${COLOR_NC}"
		echo -e "${COLOR_YELLOW}Пользователь: ${COLOR_GREEN}" $1 "${COLOR_NC}"
		#Проверка на существование параметров запуска скрипта
		if [ -n "$4" ]
		then
		#Параметры запуска существуют
		    case "$4" in
		        0)
		            echo -e "${COLOR_YELLOW}Тип подключения к серверу по SSH: ${COLOR_GREEN}" с использованием пароля "${COLOR_NC}"
		            ;;
		        1)
		            echo -e "${COLOR_YELLOW}Тип подключения к серверу по SSH: ${COLOR_GREEN}" с использованием ключевого файла "${COLOR_NC}"
		            ;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"viewSshAccess\"${COLOR_NC}";
		    	    ;;
		    esac
		#Параметры запуска существуют (конец)
		fi
		if [ -n "$5" ]
		then
		#Параметры запуска существуют

		    echo -e "${COLOR_YELLOW}Путь к ключевому файлу: ${COLOR_GREEN}" $5 "${COLOR_NC}"
		#Параметры запуска существуют (конец)
		fi
		#Конец проверки существования параметров запуска скрипта
		echo $LINE
		return 0
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию ${COLOR_GREEN}\"viewSshAccess\"${COLOR_NC}"
		return 1
	fi
}



