#!/bin/bash

declare -x -f input_SiteAdd_php
#Форма ввода данных для добавления сайта php
###input
#$1-username ;
#$2-mode: lite/querry ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует файл apache_config
#3 - не существует файл nginx_config
#4 - не существует пользователь $1
#5 - конфиги для домена уже существуют в настройках сервера
#6 - каталог для домена уже существует на сервере
#7 - ошибка mode: querry/lite
input_SiteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует

                clear
                echo "--------------------------------------"
                echo "Добавление виртуального хоста."

                #echo -e "${COLOR_YELLOW}Список имеющихся доменов:${COLOR_NC}"


                echo -n -e "${COLOR_BLUE}\nВведите домен для добавления ${COLOR_NC}: "
                read domain

                searchSiteConfigAllFolder $domain silent
                #Проверка на успешность выполнения предыдущей команды
                if [ $? -eq 0 ]
                	then
                		#Есть конфигурация
                		echo -e "${COLOR_RED}В настройках сервера уже имеется конфигурация для домена ${COLOR_GREEN}\"$domain\"${COLOR_RED}${COLOR_NC}"
                		return 5
                		#Есть конфигурация (конец)
                	else
                		#нет конфигурации

                		#поиск каталога
                        searchSiteFolder $domain $HOMEPATHWEBUSERS silent d 2
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                        	then
                        		#каталог существует
                        		echo -e "${COLOR_RED}В настройках сервера уже имеется каталог домена ${COLOR_GREEN}\"$domain\"${COLOR_RED}${COLOR_NC}"
                        		return 6
                        		#каталог существует (конец)
                        	else
                        		#каталог не существует


                                site_path=$HOMEPATHWEBUSERS/$1/$domain
                                echo ''

                                case "$2" in
                                    querry)
                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

                                                ls $TEMPLATES/apache2/
                                                echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
                                                echo -n ": "
                                                read apache_config
                                                #Проверка существования файла "$TEMPLATES/apache2/$apache_config"
                                                if ! [ -f $TEMPLATES/apache2/$apache_config ] ; then
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует
                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/apache2/$apache_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}"
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
                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$nginx_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}"
                                                    return 3
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                                                fi
                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"

                                                echo ''
                                                echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
                                                echo -n ": "
                                                read item
                                                case "$item" in
                                                    y|Y) echo
                                                        siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                                        exit 0
                                                        ;;
                                                    *) echo "Выход..."
                                                        exit 0
                                                        ;;
                                                esac
                                                #Параметры запуска существуют (конец)
                                                        ;;
                                    lite)
                                            apache_config="php_base.conf"
                                            nginx_config="php_base.conf"
                                            siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                        ;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: querry/lite\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}";
                                	    return 7
                                	    ;;
                                esac

                        		#каталог не существует (конец)
                        fi
                        #Конец проверки на успешность выполнения предыдущей команды
                		#нет конфигурациий (конец)
                fi
                #Конец проверки на успешность выполнения предыдущей команды



                    #Пользователь $1 существует (конец)
                    else
                    #Пользователь $1 не существует
                        echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}"
                        return 4
                    #Пользователь $1 не существует (конец)
                    fi
                #Конец проверки существования системного пользователя $1

	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


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
                ls $HOMEPATHWEBUSERS/$1
                echo ''
                echo -n "Введите домен для удаления: "
                read domain
                path=$HOMEPATHWEBUSERS/$1/$domain
                echo ''

                bash -c "source $SCRIPTS/include/inc.sh; siteRemove $domain $1 createbackup";
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

	            searchSiteConfigAllFolder $domain success_only
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
