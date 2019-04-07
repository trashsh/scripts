#!/bin/bash

declare -x -f dbViewAllUsersByContainName
#Отобразить список всех пользователей mysql,содержащих в названии переменную $1
###input:
#$1-переменная для поиска пользователя ;
###return
#0 - выполнено успешно
#1 - отсутствуют параметры вызова функции
#2 - пользователи с заданным именем не существуют
dbViewAllUsersByContainName() {
	#Проверка на существование параметров запуска скрипта
		#Проверка на существование параметров запуска скрипта
		if [ -n "$1" ]
		then
		#Параметры запуска существуют
		    #проверка на пустой результат
		    		if [[ $(mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '%%$1%%' ORDER BY User ASC") ]]; then
		    			#непустой результат
		    			echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL, содержащих в названии ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
		                mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '%%$1%%' ORDER BY User ASC"
		                return 0
		    			#непустой результат (конец)
		    		else
		    		    #пустой результат
		    			return 2
		    			#пустой результат (конец)
		    		fi
		    #Конец проверки на пустой результат
		#Параметры запуска существуют (конец)
		else
		#Параметры запуска отсутствуют
		    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewAllUsersByContainName\"${COLOR_RED} ${COLOR_NC}"
		    return 1
		#Параметры запуска отсутствуют (конец)
		fi
		#Конец проверки существования параметров запуска скрипта
}



declare -x -f dbViewBasesByUsername
#Отобразить список всех баз данных, владельцем которой является пользователь mysql $1_% (по имени)
###input
#$1-user;
#$2-mode(full_info/error_only/success_only)
#return
#0 - базы данных найдены,
#1 - не переданы параметры,
#2 - базы данных не найдены
#3 - ошибка параметра mode(full_info/error_only/success_only)
dbViewBasesByUsername() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SHOW DATABASES LIKE '$1\_%';") ]]; then
					#непустой результат
					case "$2" in
					        full_info)
					            echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL пользователя ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
                                mysql -e "SHOW DATABASES LIKE '$1\_%';"
                                return 0
					            ;;
					        error_only)
					            return 0
					            ;;
					    	success_only)
					    		echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL пользователя ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
                                mysql -e "SHOW DATABASES LIKE '$1\_%';"
                                return 0
                                ;;
					    	*)
					    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
					    	    return 3
					    	    ;;
					    esac

					#непустой результат (конец)
				else
				    #пустой результат
					    case "$2" in
					        full_info)
					            echo -e "${COLOR_YELLOW}\nБазы данных пользователя ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствуют${COLOR_NC}"
					            return 2
					            ;;
					        error_only)
					            echo -e "${COLOR_YELLOW}\nБазы данных пользователя ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствуют${COLOR_NC}"
					            return 2
					            ;;
					    	success_only)
					    		return 2
					    		;;
					    	*)
					    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
					    	    return 3
					    	    ;;
					    esac

					#пустой результат (конец)
				fi
		#Конец проверки на пустой результат
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewBasesByUsername\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}