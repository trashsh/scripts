#!/bin/bash

declare -x -f input_SiteAdd #Ввод информации о добавлении сайта PHP: ($1-username)
#Ввод информации о добавлении сайта PHP
###input
#$1-username ;
#$2-mode: siteType: php/laravel
#$3-mode: lite/querry/reverseProxy ;

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - конфиг существует, пользователь отменил
#4 -  ошибка передачи siteType
input_SiteAdd() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	case "$2" in
	    php)
	        true
	        ;;
	     laravel)
	        true
	        ;;
		*)
		    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"siteType: php/laravel\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}";
		    return 4
		    ;;
	esac

        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
                echo "--------------------------------------"
                echo "Добавление виртуального хоста."
                echo -n -e "${COLOR_BLUE}\nВведите домен для добавления ${COLOR_NC}: "
                read domain

                searchSiteConfigByUsername $1 $domain silent
                #Проверка на успешность выполнения предыдущей команды
                if [ $? -eq 0 ]
                	then
                		#конфиг существует
                		echo -n -e "${COLOR_YELLOW}Для удаления старых настроек веб-серверов введите ${COLOR_GREEN}\"d\"${COLOR_YELLOW} для отмены операции введите ${COLOR_BLUE}\"n\"${COLOR_YELLOW}${COLOR_NC}: "
                		    while read
                		    do
                		        case "$REPLY" in
                		            d|D)
                		                siteRemoveWebserverConfig $1 $domain;
                		                break
                		                ;;
                		            n|N)

                		                return 5;
                		                menuSiteAdd $1;
                		                ;;
                		            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                		               ;;
                		        esac
                		    done
                		#конфиг уже существует (конец)
                fi
                #Конец проверки на успешность выполнения предыдущей команды

            searchSiteFolder $domain $HOMEPATHWEBUSERS silent d 2
            #Проверка на успешность выполнения предыдущей команды
            if [ $? -eq 0 ]
            	then
            		#предыдущая команда завершилась успешно
            		echo -e "${COLOR_RED}В настройках сервера уже имеется каталог домена ${COLOR_GREEN}\"$domain\"${COLOR_RED}${COLOR_NC}"
                    return 6
                    menuSiteAdd $1
            		#предыдущая команда завершилась успешно (конец)		
            	else
            		#предыдущая команда завершилась с ошибкой

                    site_path=$HOMEPATHWEBUSERS/$1/$domain
                    echo ''

                    case "$3" in
                                    querry)
                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

                                                ls $TEMPLATES/apache2/
                                                echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
                                                echo -n ": "
                                                read apache_config
                                                #Проверка существования файла "$TEMPLATES/apache2/$apache_config"
                                                if ! [ -f $TEMPLATES/apache2/$apache_config ] ; then
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует
                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/apache2/$apache_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}"
                                                    return 2
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                                                fi
                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"


                                                echo ''
                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
                                                ls $TEMPLATES/nginx/
                                                echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
                                                echo -n ": "
                                                read nginx_config
                                                #Проверка существования файла "$TEMPLATES/nginx/$nginx_config"
                                                if ! [ -f $TEMPLATES/nginx/$nginx_config ] ; then
                                                    #Файл "$TEMPLATES/nginx/$nginx_config" не существует
                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$nginx_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}"
                                                    return 3
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                                                fi
                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"

                                                echo ''
                                                echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
                                                echo -n ": "
                                                read item
                                                case "$item" in
                                                    y|Y)

                                                        case "$2" in
                                                            php)
                                                                siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                                                ;;
                                                            laravel)
                                                                siteAdd_Laravel $1 $domain $site_path $apache_config $nginx_config $1
                                                                ;;
                                                        	*)
                                                        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"sitetype\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}";
                                                        	    return 4
                                                        	    ;;
                                                        esac


                                                        ;;
                                                    *) echo "Выход..."
                                                        exit 0
                                                        ;;
                                                esac
                                                #Параметры запуска существуют (конец)
                                                        ;;
                                    lite)
                                            case "$2" in
                                                            php)
                                                                apache_config="php_base.conf"
                                                                nginx_config="php_base.conf"
                                                                siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                                                ;;
                                                            laravel)
                                                                apache_config="laravel.conf"
                                                                nginx_config="laravel.conf"
                                                                siteAdd_Laravel $1 $domain $site_path $apache_config $nginx_config $1
                                                                ;;
                                                        	*)
                                                        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"sitetype\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}";
                                                        	    return 4
                                                        	    ;;
                                                        esac


                                        ;;
                                    reverseProxy)
                                            case "$2" in
                                                            php)
                                                                apache_config="php_rproxy.conf"
                                                                nginx_config="php_rproxy.conf"
                                                                siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                                                ;;
                                                            laravel)
                                                                apache_config="laravel_rproxy.conf"
                                                                nginx_config="laravel_rproxy.conf"
                                                                siteAdd_Laravel $1 $domain $site_path $apache_config $nginx_config $1
                                                                ;;
                                                        	*)
                                                        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"sitetype\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}";
                                                        	    return 4
                                                        	    ;;
                                                        esac

                                        ;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: querry/lite\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}";
                                	    return 7
                                	    ;;
                                esac

                    echo -n -e "${COLOR_YELLOW}Добавить автоматически SSL-сертификат для домена ${COLOR_GREEN}\"$domain\"${COLOR_YELLOW}? Введите для генерации сертификата ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены  - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                        while read
                        do
                            case "$REPLY" in
                                y|Y)
                                    site_AddSSL $1 $domain auto;
                                    break
                                    ;;
                                n|N)

                                    break
                                    ;;
                                *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                   ;;
                            esac
                        done

            		#предыдущая команда завершилась с ошибкой (конец)
            fi
            #Конец проверки на успешность выполнения предыдущей команды

        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#declare -x -f input_SiteAdd #Ввод информации о добавлении сайта PHP: ($1-username)
##Ввод информации о добавлении сайта PHP
####input
##$1-username ;
##$2-mode: lite/querry/reverseProxy ;
####return
##0 - выполнено успешно
##1 - не переданы параметры в функцию
##2 - пользователь не существует
##3 - конфиг существует, пользователь отменил
#input_SiteAdd() {
#	#Проверка на существование параметров запуска скрипта
#	if [ -n "$1" ] && [ -n "$2" ]
#	then
#	#Параметры запуска существуют
#        #Проверка существования системного пользователя "$1"
#        	grep "^$1:" /etc/passwd >/dev/null
#        	if  [ $? -eq 0 ]
#        	then
#        	#Пользователь $1 существует
#                clear
#                echo "--------------------------------------"
#                echo "Добавление виртуального хоста."
#                echo -n -e "${COLOR_BLUE}\nВведите домен для добавления ${COLOR_NC}: "
#                read domain
#
#                searchSiteConfigByUsername $1 $domain silent
#                #Проверка на успешность выполнения предыдущей команды
#                if [ $? -eq 0 ]
#                	then
#                		#конфиг существует
#                		echo -n -e "${COLOR_YELLOW}Для удаления старых настроек веб-серверов введите ${COLOR_GREEN}\"d\"${COLOR_YELLOW} для отмены операции введите ${COLOR_BLUE}\"n\"${COLOR_YELLOW}${COLOR_NC}: "
#                		    while read
#                		    do
#                		        case "$REPLY" in
#                		            d|D)
#                		                siteRemoveWebserverConfig $1 $domain;
#                		                break
#                		                ;;
#                		            n|N)
#
#                		                return 5;
#                		                menuSiteAdd $1;
#                		                ;;
#                		            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
#                		               ;;
#                		        esac
#                		    done
#                		#конфиг уже существует (конец)
#                fi
#                #Конец проверки на успешность выполнения предыдущей команды
#
#            searchSiteFolder $domain $HOMEPATHWEBUSERS silent d 2
#            #Проверка на успешность выполнения предыдущей команды
#            if [ $? -eq 0 ]
#            	then
#            		#предыдущая команда завершилась успешно
#            		echo -e "${COLOR_RED}В настройках сервера уже имеется каталог домена ${COLOR_GREEN}\"$domain\"${COLOR_RED}${COLOR_NC}"
#                    return 6
#                    menuSiteAdd $1
#            		#предыдущая команда завершилась успешно (конец)
#            	else
#            		#предыдущая команда завершилась с ошибкой
#
#                    site_path=$HOMEPATHWEBUSERS/$1/$domain
#                    echo ''
#
#                    case "$2" in
#                                    querry)
#                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"
#
#                                                ls $TEMPLATES/apache2/
#                                                echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
#                                                echo -n ": "
#                                                read apache_config
#                                                #Проверка существования файла "$TEMPLATES/apache2/$apache_config"
#                                                if ! [ -f $TEMPLATES/apache2/$apache_config ] ; then
#                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует
#                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/apache2/$apache_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}"
#                                                    return 2
#                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
#                                                fi
#                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"
#
#
#                                                echo ''
#                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
#                                                ls $TEMPLATES/nginx/
#                                                echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
#                                                echo -n ": "
#                                                read nginx_config
#                                                #Проверка существования файла "$TEMPLATES/nginx/$nginx_config"
#                                                if ! [ -f $TEMPLATES/nginx/$nginx_config ] ; then
#                                                    #Файл "$TEMPLATES/nginx/$nginx_config" не существует
#                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$nginx_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}"
#                                                    return 3
#                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
#                                                fi
#                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"
#
#                                                echo ''
#                                                echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
#                                                echo -n ": "
#                                                read item
#                                                case "$item" in
#                                                    y|Y) echo
#                                                        siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
#                                                        exit 0
#                                                        ;;
#                                                    *) echo "Выход..."
#                                                        exit 0
#                                                        ;;
#                                                esac
#                                                #Параметры запуска существуют (конец)
#                                                        ;;
#                                    lite)
#                                            apache_config="php_base.conf"
#                                            nginx_config="php_base.conf"
#                                            siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
#                                        ;;
#                                    reverseProxy)
#                                            apache_config="php_rproxy.conf"
#                                            nginx_config="php_rproxy.conf"
#                                            siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
#                                        ;;
#                                	*)
#                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: querry/lite\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}";
#                                	    return 7
#                                	    ;;
#                                esac
#
#            		#предыдущая команда завершилась с ошибкой (конец)
#            fi
#            #Конец проверки на успешность выполнения предыдущей команды
#
#        	#Пользователь $1 существует (конец)
#        	else
#        	#Пользователь $1 не существует
#        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_NC}"
#        		return 2
#        	#Пользователь $1 не существует (конец)
#        	fi
#        #Конец проверки существования системного пользователя $1
#	#Параметры запуска существуют (конец)
#	else
#	#Параметры запуска отсутствуют
#		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_SiteAdd\"${COLOR_RED} ${COLOR_NC}"
#		return 1
#	#Параметры запуска отсутствуют (конец)
#	fi
#	#Конец проверки существования параметров запуска скрипта
#}

declare -x -f input_siteRemove
#удаление сайта
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
input_siteRemove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo "--------------------------------------"
                echo "Удаление виртуального хоста:"
                echo "Список имеющихся доменов для пользователя $1:"
                ls -d $HOMEPATHWEBUSERS/$1/*/ | xargs -n 1 basename
                echo ''
                echo -n "Введите домен для удаления: "
                read domain
                path=$HOMEPATHWEBUSERS/$1/$domain
                echo ''

                bash -c "source $SCRIPTS/include/inc.sh; siteRemove $domain $1 createbackup";
                dbUserdel $1_$domain drop
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteRemove\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_siteRemove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f input_siteExist
#Проверка наличия сайта
###input
#$1-username;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - Ошибка обработки возвращенного результата выполнения операции в функции input_siteExist-searchSiteConfigAllFolder
#4 - ошибка ввода конфигурации apache
#5 - ошибка ввода конфигурации nginx
#6 - операция добавления отменена пользователем
input_siteExist() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    #Проверка существования системного пользователя "$1"
	    	grep "^$1:" /etc/passwd >/dev/null
	    	if  [ $? -eq 0 ]
	    	then
	    	#Пользователь $1 существует

                echo -n -e "${COLOR_BLUE}Введите домен: ${COLOR_NC}"
	            read domain

	            searchSiteConfigByUsername $1 $domain success_only
	            #Проверка на успешность выполнения предыдущей команды
	            case "$?" in
	                0)
	                    echo -e "${COLOR_RED}Операция добавления домена ${COLOR_GREEN}\"$domain\"${COLOR_RED} прервана${COLOR_NC}"
	                    ;;
	                2)

                        site_path=$HOMEPATHWEBUSERS/$1/$domain
                        echo ''
                        echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

                        ls $TEMPLATES/apache2/
                        echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
                        echo -n ": "
                        read apache_config

                            #Проверка существования файла "$TEMPLATES/apache2/$apache_config"
                            if ! [ -f $TEMPLATES/apache2/$apache_config ] ; then
                                #Файл "$TEMPLATES/apache2/$apache_config" не существует
                                echo -e "${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$TEMPLATES/apache2/$apache_config\"${COLOR_RED} не существует. Операция прервана${COLOR_NC}"
                                return 4
                                #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                            fi
                            #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"

                        echo ''
                        echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
                        ls $TEMPLATES/nginx/
                        echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
                        echo -n ": "
                        read nginx_config

                            #Проверка существования файла "$TEMPLATES/nginx/$nginx_config"
                            if ! [ -f $TEMPLATES/nginx/$nginx_config ] ; then
                                #Файл "$TEMPLATES/nginx/$nginx_config" не существует
                                echo -e "${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$TEMPLATES/nginx/$nginx_config\"${COLOR_RED} не существует. Операция прервана${COLOR_NC}"
                                return 5
                                #Файл "$TEMPLATES/nginx/$nginx_config" не существует (конец)
                            fi
                            #Конец проверки существования файла "$TEMPLATES/nginx/$nginx_config"

                        echo ''
                        echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
                        echo -n ": "
                        read item
                        case "$item" in
                            y|Y) echo
                                echo $1 $domain $1 $site_path $apache_config $nginx_config
                                ;;
                            *) echo "Выход..."
                                return 6
                                ;;
                        esac
                        #Параметры запуска существуют (конец)


	                    ;;
	            	*)
	            	    echo -e "${COLOR_RED}Ошибка обработки возвращенного результата выполнения операции в функции ${COLOR_GREEN}\"input_siteExist-searchSiteConfigAllFolder\"${COLOR_NC}";
	            	    return 3
	            	    ;;
	            esac
	    	#Пользователь $1 существует (конец)
	    	else
	    	#Пользователь $1 не существует
	    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteExist\"${COLOR_NC}"
                return 2
	    	#Пользователь $1 не существует (конец)
	    	fi
	    #Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"input_siteExist\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f input_siteConfigRemove #запрос домена для удаления конфигов сайта: ($1-user ; $2-domain ;)
#запрос домена для удаления конфигов сайта
###input
#$1-user ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь $1 не существует
input_siteConfigRemove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
			    echo -n -e "${COLOR_BLUE}Введите домен для удаления конфигов сайта: ${COLOR_NC}"
			    read domain

                bash -c "source $SCRIPTS/include/inc.sh; siteRemoveWebserverConfig $1 $domain"
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteConfigRemove\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_siteConfigRemove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}


