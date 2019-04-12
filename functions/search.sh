#!/bin/bash


declare -x -f searchSiteConfigByUsername
#Поиск файла конфигурации сайта в каталогах серверов apache2, nginx с указанием имени пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1-user ;
#$1-домен ;
#$3-mode full_info/error_only/success_only/silent ;
###return
#0 - Конфигурация существует
#1 - не переданы параметры в функцию
#2 - конфигурация отсутствует
#3 - ошибка передачи параметра mode full_info/error_only/success_only/silent
searchSiteConfigByUsername() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		[ "$(ls -A $APACHEAVAILABLE | grep "$1_$2.conf$")" ]
		 if [ $? -eq 0 ]; then res_aa=0; else res_aa=1; folder=$APACHEAVAILABLE; fi

		[ "$(ls -A $APACHEENABLED | grep "$1_$2.conf$")" ]
		 if [ $? -eq 0 ]; then res_ae=0; else res_ae=1; folder=$APACHEENABLED; fi

        [ "$(ls -A $NGINXAVAILABLE | grep "$1_$2.conf$")" ]
		 if [ $? -eq 0 ]; then res_na=0; else res_na=1; folder=$NGINXAVAILABLE; fi

		[ "$(ls -A $NGINXENABLED | grep "$1_$2.conf$")" ]
		 if [ $? -eq 0 ]; then res_ne=0; else res_ne=1; folder=$NGINXENABLED; fi


		 if [ $res_aa -eq 0 ] || [ $res_ae -eq 0 ] || [ $res_na -eq 0 ] || [ $res_ne -eq 0 ]
		 then
            case "$3" in
                full_info)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} имеется в каталоге ${COLOR_GREEN}\"$folder\"${COLOR_YELLOW} ${COLOR_NC}"
                    ;;
                error_only)

                    ;;
            	success_only)
            	    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} имеется в каталоге ${COLOR_GREEN}\"$folder\"${COLOR_YELLOW} ${COLOR_NC}"
            		;;
                silent)

            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            return 0

         else
            case "$3" in
                full_info)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} отсутствует в каталогах веб-серверов${COLOR_NC}"
                    ;;
                error_only)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} отсутствует в каталогах веб-серверов${COLOR_NC}"
                    ;;
            	success_only)
            		;;
                silent)

            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            return 2
		 fi

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteConfigByUsername\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f searchSiteConfigAllFolder
#Поиск файла конфигурации сайта в каталогах серверов apache2, nginx
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1-домен ;
#$2-mode full_info/error_only/success_only/silent ;
###return
#0 - Конфигурация существует
#1 - не переданы параметры в функцию
#2 - конфигурация отсутствует
#3 - ошибка передачи параметра mode full_info/error_only/success_only/silent
searchSiteConfigAllFolder() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		[ "$(ls -A $APACHEAVAILABLE | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_aa=0; else res_aa=1; folder=$APACHEAVAILABLE; fi

		[ "$(ls -A $APACHEENABLED | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_ae=0; else res_ae=1; folder=$APACHEENABLED; fi

        [ "$(ls -A $NGINXAVAILABLE | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_na=0; else res_na=1; folder=$NGINXAVAILABLE; fi

		[ "$(ls -A $NGINXENABLED | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_ne=0; else res_ne=1; folder=$NGINXENABLED; fi


		 if [ $res_aa -eq 0 ] || [ $res_ae -eq 0 ] || [ $res_na -eq 0 ] || [ $res_ne -eq 0 ]
		 then
            case "$2" in
                full_info)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} имеется в каталоге ${COLOR_GREEN}\"$folder\"${COLOR_YELLOW} ${COLOR_NC}"
                    ;;
                error_only)

                    ;;
            	success_only)
            	    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} имеется в каталоге ${COLOR_GREEN}\"$folder\"${COLOR_YELLOW} ${COLOR_NC}"
            		;;
                silent)

            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            return 0

         else
            case "$2" in
                full_info)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствует в каталогах веб-серверов${COLOR_NC}"
                    ;;
                error_only)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствует в каталогах веб-серверов${COLOR_NC}"
                    ;;
            	success_only)
            		;;
                silent)

            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            return 2
		 fi

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f searchSiteFolder
#Поиск каталога в указанной папке (с вложением)
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1-domain ;
#$2-path-корневой каталог поиска ;
#$3-mode: full_info/silent ;
#$3-mode: d-directory; f-file;
#$5-максимальная вложенность - не обязательно
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - корневой каталог для начала поиска не существует
#3 - ошибка передачи параметра $3-mode: full_info/silent
#4 - отрицательный результат поиска
#5 - ошибка передачи параметра mode: folder/file - поиск файла или каталога
searchSiteFolder() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
	    case "$4" in
	        d)
	            #directory
	            searchType="d";
	            searchTypeWord="Каталог"
	            ;;
	        f)
	            #file
	             searchType="f";
	             searchTypeWord="Файл"
	            ;;
	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"searchType\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_NC}";
	    	    return 5
	    	    ;;
	    esac

		#Проверка существования каталога "$2"
		if [ -d $2 ] ; then
		    #Каталог "$2" существует
            path=$2
		    #Каталог "$2" существует (конец)
		else
		    #Каталог "$2" не существует
		    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_NC}"
		    return 2
		    #Каталог "$2" не существует (конец)
		fi
		#Конец проверки существования каталога "$2"

        case "$3" in
            full_info)

                #Проверка на существование параметров запуска скрипта - глубина поиска
                if [ -n "$5" ]
                then
                #Параметры запуска существуют

                    if [[ ! -z "$(sudo find $2 -maxdepth $5 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} расположен по следующему пути ${COLOR_GREEN}\"$(sudo find $2 -type $searchType -name "$1")\"${COLOR_YELLOW} с вложенностью поиска - ${COLOR_GREEN}$5${COLOR_NC}"
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} не найден во вложенных каталогах папки ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} с вложенностью поиска - ${COLOR_GREEN}$5${COLOR_NC}"
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют

                        #Поиск каталога по имени
                        if [[ ! -z "$(sudo find $2 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} расположен по следующему пути ${COLOR_GREEN}\"$(sudo find $2 -type $searchType -name "$1")\"${COLOR_YELLOW}  ${COLOR_NC}"
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} не найден во вложенных каталогах папки ${COLOR_GREEN}\"$2\"${COLOR_YELLOW}  ${COLOR_NC}"
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта  - глубина поиска (конец)
                ;;

            silent)
                #Проверка на существование параметров запуска скрипта - глубина поиска
                if [ -n "$5" ]
                then
                #Параметры запуска существуют

                    if [[ ! -z "$(sudo find $2 -maxdepth $5 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют

                        #Поиск каталога по имени
                        if [[ ! -z "$(sudo find $2 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта  - глубина поиска (конец)

                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_NC}";
        	    return 3
        	    ;;
        esac
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f searchSiteConfig
#Вывод списка конфигов apache2
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1 - Каталог (aa/ae/na/ne)
#$2 - domain
#$3 - mode: full_info/error_only/success_only/silent
#$4 - Username - не обязательно ; без параметра выводятся все конфиги
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - ошибка передачи параметра mode: apache2/nginx
#4 - результат отрицательный
#5 - ошибка передачи параметра mode-full_info/error_only/success_only/silent
searchSiteConfig() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    case "$1" in
	        aa)
                folder="/etc/apache2/sites-available"
	            ;;
	        ae)
                folder="/etc/apache2/sites-enabled"
	            ;;
	        na)
	            folder="/etc/nginx/sites-available"
	            ;;
	        ne)
	            folder="/etc/nginx/sites-enabled"
	            ;;

	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-webserver\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
	    	    return 3
	    	    ;;
	    esac

	    #Проверка на существование параметров запуска скрипта
	    if [ -n "$4" ]
	    then
	    #Параметры запуска существуют
            #Проверка существования системного пользователя "$4"
        	grep "^$4:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $4 существует

                        [ "$(ls -A $folder | grep "$4_$2.conf$")" ]
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                            then
                                #предыдущая команда завершилась успешно

                                case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} существует${COLOR_NC}"
                                        return 0
                                        ;;
                                    error_only)
                                         return 4
                                        ;;
                                	success_only)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} существует${COLOR_NC}"
                                        return 0
                                		;;
                                	silent)
                                        return 4
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac

                                #предыдущая команда завершилась успешно (конец)
                            else
                                #предыдущая команда завершилась с ошибкой
                                case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} отсутствует${COLOR_NC}"
                                        return 4
                                        ;;
                                    error_only)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} отсутствует${COLOR_NC}"
                                        return 4
                                        ;;
                                	success_only)
                                	    return 4
                                		;;
                                	silent)
                                        return 4
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac

                                #предыдущая команда завершилась с ошибкой (конец)
                        fi
                        #Конец проверки на успешность выполнения предыдущей команды


        	#Пользователь $4 существует (конец)
        	else
        	#Пользователь $2 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}"
        		return 2
        	#Пользователь $4 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $4
	    #Параметры запуска существуют (конец)
	    else
	    #Параметры запуска отсутствуют
		            [ "$(ls -A $folder | grep "_$2.conf$")" ]
		            case "$?" in
		                0)
		                    case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_GREEN}Список всех конфигураций ${COLOR_LIGHT_RED}$1${COLOR_GREEN}:${COLOR_NC}";
		                                ls -l -A -L $folder | grep "$2.conf$"
		                                return 0
                                        ;;
                                    error_only)
                                        return 0
                                        ;;
                                	success_only)
                                	    echo -e "\n${COLOR_GREEN}Список всех конфигураций ${COLOR_LIGHT_RED}$1${COLOR_GREEN}:${COLOR_NC}";
		                                ls -l -A -L $folder | grep "$2.conf$"
		                                return 0
                                		;;
                                	silent)
                                        return 0
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac


		                    ;;
		                1)
		                    case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$2.conf\"${COLOR_RED} в каталоге ${COLOR_YELLOW}$folder${COLOR_RED} - отсутствует${COLOR_NC}";
                                        return 4
                                        ;;
                                    error_only)
                                        echo -e "\n${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$2.conf\"${COLOR_RED} в каталоге ${COLOR_YELLOW}$folder${COLOR_RED} - отсутствует${COLOR_NC}";
                                        return 4
                                        ;;
                                	success_only)
                                	    return 4
                                		;;
                                	silent)
                                	    return 4
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac

		                    ;;
		            	*)
		            	    echo -e "${COLOR_RED}Код ошибки отличается от 0/1 в функции ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
		            	    ;;
		            esac
	    fi
	    #Конец проверки существования параметров запуска скрипта
	else
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

