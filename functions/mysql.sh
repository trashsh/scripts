#!/bin/bash


declare -x -f dbChangeUserPassword #Смена пароля пользователю mysql: ($1-user ; $2-host ; $3-password ; $4-autentification type (mysql_native_password) ; )



#####################ПОЛНОСТЬЮ ГОТОВО
declare -x -f dbViewUserInfo #Вывести информацию о пользователе mysql. #$1-user ;
                             #return 0 - пользователь существует, 1 - пользователь не существует;



declare -x -f dbDropBase #Удаление базы данных mysql: ($1-dbname ; $2"drop"-подтверждение ;)
                         #return 0 - успешно удалена база; 1 - отсутствуют параметры; 2 - подтверждение на удаление не получено
                         #3 - база данных не существует; 4 - после выполнения команды на удаление база удалена не была
declare -x -f dbDropUser #Удаление пользователя mysql: ($1-user ; $2-"drop"-подтверждение ; )
                         #return 0 - выполнено успешно, 1 - не переданы параметры; 2 - пользователь не существует;
                         #3 - подтверждение на удаление не получено
declare -x -f dbSetFullAccessToBase #Предоставление всех прав пользователю $1 на базу данных $1: ($1-dbname ; $2-user ; $3-host ;)
                                    #return 0 - выполнено успешно; 1 - отсутствуют параметры; 2 - пользователь не существует;
                                    #3 - База данных не существует
declare -x -f dbSetMyCnfFile #Смена пароля и создание файла ~/.my.cnf (только файл): ($1-user ; $2-password ;)
              #return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователь не существует
              #3 - после выполнения функции файл my.cnf не найден
declare -x -f dbViewBasesByUsername #Отобразить список всех баз данных, владельцем которой является пользователь mysql $1_%: ($1-user ;)
                                    #return 0 - базы данных найдены, 1 - не переданы параметры, 2 - базы данных не найдены
declare -x -f dbShowTables #Вывод всех таблиц базы данных $1: ($1-dbname ;)
                            #return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - база данных не существует
declare -x -f dbViewAllUsersByContainName #Отобразить список всех пользователей mysql,содержащих в названии переменную $1: ($1-переменная для поиска пользователя ;
                                          #return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователи отсутствуют
declare -x -f dbViewAllBases #Вывод списка всех баз данных (без параметров)
declare -x -f dbViewAllUsers #Вывод списка всех пользователей mysql (без параметров)
declare -x -f dbViewBasesByTextContain #Отобразить список всех баз данных mysql с названием, содержащим переменную $1:
                                        # ($1-Переменная, по которой необходимо осуществить поиск баз данных ;)
declare -x -f dbViewUserGrant #Вывод прав пользователя mysql на все базы: ($1-user ; $2-host ;)
                              #return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователь не существует







#
#Смена пароля пользователю mysql
#$1-user ; $2-host ; $3-password ; $4-autentification type (mysql_native_password) ; $5- ;
dbChangeUserPassword() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		#проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then
		#Пользователь mysql "$1" существует
		    mysql -e "ALTER USER '$1'@'$2' IDENTIFIED WITH '$4' BY '$3';"
			echo -e "${COLOR_LIGHT_PURPLE}Пароль пользователя $1 изменен ${COLOR_NC}"
			#корректирование файла ~/.my.cnf
			dbSetMyCnfFile $1 $3
		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует ${COLOR_NC}"
		#Пользователь mysql "$1" не существует (конец) 
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbChangeUserPassword\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}





########################################################################################################################

#Полностью готово
#Вывести информацию о пользователе mysql $1. Проверка существования пользователя
#$1-user ;$2 (необязательный) - если в параметре значение "0", то результат не выводится, если "1" - результат выводится
#return 0 - пользователь существует, 1 - пользователь не существует;
dbViewUserInfo() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv, Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '$1' ORDER BY User ASC") ]]; then
					#непустой результат
                    #выводим или нет информацию о выполнении команды
			        case "$2" in
			        	0)  return 0
			        		;;
			        	1)
			        		echo -e "${COLOR_YELLOW}Информация о пользователе MYSQL ${COLOR_GREEN}\"$1\" ${COLOR_NC}";
			                mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv, Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '$1' ORDER BY User ASC";
			                return 0;;
			        	*)
			        		echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_GREEN}\"dbViewUserInfo\"${COLOR_NC}";;
			        esac
                    #выводим или нет информацию о выполнении команды (конец)
					#непустой результат (конец)
				else
				    #пустой результат
				    case "$2" in
				    	0)  return 1
				    		;;
				    	1)
				    		echo -e "${COLOR_LIGHT_RED}Пользователь mysql ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} не существует ${COLOR_NC}";
					        return 1;;
				    	*)
				    		echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_RED}\"dbViewUserInfo\"${COLOR_NC}";;
				    esac
					#пустой результат (конец)
				fi
		#Конец проверки на пустой результат
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewUserInfo\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




#
#Удаление базы данных mysql
#$1-dbname ; $2-"drop"-подтверждение ;
#return 0 - успешно удалена база; 1 - отсутствуют параметры; 2 - подтверждение на удаление не получено
#3 - база данных не существует; 4 - после выполнения команды на удаление база удалена не была
dbDropBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка наличия подтверждения на удаление
		if [ "$2" = "drop" ]
		then
            #проверка существования базы данных "$1"
            if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
            	then
            	#база $1 - существует
                    mysql -e "DROP DATABASE IF EXISTS $1;"

                    #Финальная проверка существования базы данных "$1"
                    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                    	then
                    	#база $1 - существует
                    	    echo -e "${COLOR_RED}Произошла ошибка удаления базы данных ${COLOR_GREEN}\"$1.\"${COLOR_RED} Функция ${COLOR_GREEN}\"dbDropBase\"${COLOR_RED}  ${COLOR_NC}"
                    		return 4
                    	#база $1 - существует (конец)
                    	else
                    	#база $1 - не существует
                    	     echo -e "${COLOR_GREEN}База данных ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} удалена.${COLOR_NC}"
                    	     return 0
                    	#база $1 - не существует (конец)
                    fi
                    #Финальная проверка существования базы данных $1 (конец)



            	#база $1 - существует (конец)
            	else
            	#база $1 - не существует
                    echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"dbDropBase\" ${COLOR_NC}"
                    return 3
            	#база $1 - не существует (конец)
            fi
            #конец проверки существования базы данных $1
        else
            #Не получено подтверждение на удаление
            echo -e "${COLOR_RED}Подтверждение на удаление базы данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не получено. Функция ${COLOR_GREEN}\"dbDropBase\"${COLOR_NC}"
            return 2
            #Не получено подтверждение на удаление (конец)
		fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbDropBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Удаление пользователя mysql
#$1-user ; $2-"drop"-подтверждение ;
#return 0 - выполнено успешно, 1 - не переданы параметры; 2 - пользователь не существует;
#3 - подтверждение на удаление не получено
dbDropUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка наличия подтверждения на удаление
		if [ "$2" = "drop" ]
		then
		    #Получено подтверждение на удаление
            #проверка на существование пользователя mysql "$1"
            if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
            then
            #Пользователь mysql "$1" существует
                mysql -e "DROP USER IF EXISTS '$1'@'localhost';"
				mysql -e "DROP USER IF EXISTS '$1'@'%';"

                #Проверка на существование пользователя mysql "$1"
                if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
                then
                #Пользователь mysql "$1" не удалился
                    return 4
                #Пользователь mysql "$1" не удалился (конец)
                else
                #Пользователь mysql "$1" не существует
                    echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}$1${COLOR_GREEN} удален ${COLOR_NC}"
                    return 0
                #Пользователь mysql "$1" не существует (конец)
                fi
                #Конец проверки на существование пользователя mysql "$1"


            #Пользователь mysql "$1" существует (конец)
            else
            #Пользователь mysql "$1" не существует
                echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"dbDropUser\" ${COLOR_NC}"
                return 2
            #Пользователь mysql "$1" не существует (конец)
            fi
            #Конец проверки на существование пользователя mysql "$1"
            #Получено подтверждение на удаление - конец
        else
            #Не получено подтверждение на удаление
            echo -e "${COLOR_RED}Подтверждение на удаление пользователя ${COLOR_GREEN}\"$1\"${COLOR_RED} не получено. Функция ${COLOR_GREEN}\"dbDropUser\"${COLOR_NC}"
            return 3
            #Не получено подтверждение на удаление (конец)
		fi
		#Проверка наличия подтверждения на удаление (конец)
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbDropUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Предоставление всех прав пользователю $1 на базу данных $1
#$1-dbname ; $2-user ; $3-host ;
#return 0 - выполнено успешно; 1 - отсутствуют параметры; 2 - пользователь не существует;
#3 - База данных не существует
dbSetFullAccessToBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#проверка на существование пользователя mysql "$2"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$2'" 2>&1`" ]];
		then
		#Пользователь mysql "$2" существует
		    #проверка существования базы данных "$1"
		    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
		    	then
		    	#база $1 - существует
				mysql -e "GRANT ALL PRIVILEGES ON $1.* TO $2@$3 REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; FLUSH PRIVILEGES;"
				return 0
		    	#база $1 - существует (конец)
		    	else
		    	#база $1 - не существует
		    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует ${COLOR_NC}"
		    	     return 3
		    	#база $1 - не существует (конец)
		    fi
		    #конец проверки существования базы данных $1

		#Пользователь mysql "$2" существует (конец)
		else
		#Пользователь mysql "$2" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$2" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$2"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetFullAccessToBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Смена пароля и создание файла ~/.my.cnf (только файл)
#$1-user ; $2-password ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователь не существует
#3 - после выполнения функции файл my.cnf не найден
dbSetMyCnfFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				   #пользователь существует
			dt=`date +%Y.%m.%d_%H.%M.%S`;
			#если файл для бэкапа существует
			if [ -f "$HOMEPATHWEBUSERS"/"$1"/"my.cnf" ] ; then
					backupImportantFile $1 "my.cnf"  $HOMEPATHWEBUSERS/$1/.my.cnf
					sed -i "s/.*password=.*/password=$2/" $HOMEPATHWEBUSERS/$1/.my.cnf
			#если файл для бэкапа не существует
			else
				touch $HOMEPATHWEBUSERS/$1/.my.cnf
				cat $HOMEPATHWEBUSERS/$1/.my.cnf | grep $HOMEPATHWEBUSERS
									{
							echo '[mysqld]'
							echo 'init_connect=‘SET collation_connection=utf8_general_ci’'
							echo 'character-set-server=utf8'
							echo 'collation-server=utf8_general_ci'
							echo ''
							echo '[client]'
							echo 'default-character-set=utf8'
							echo 'user='$1
							echo 'password='$2
							} > $HOMEPATHWEBUSERS/$1/.my.cnf
							chmod 600 $HOMEPATHWEBUSERS/$1/.my.cnf
							chown $1:users $HOMEPATHWEBUSERS/$1/.my.cnf

							backupImportantFile $1 "my.cnf"  $HOMEPATHWEBUSERS/$1/.my.cnf

                #Финальная проверка существования файла "$HOMEPATHWEBUSERS/$1/.my.cnf"
                if [ -f $HOMEPATHWEBUSERS/$1/.my.cnf ] ; then
                    #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" существует
                    return 0
                    #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" существует (конец)
                else
                    #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" не существует
                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"\"${COLOR_RED} не существует${COLOR_NC}"
                    return 3
                    #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" не существует (конец)
                fi
                #Финальная проверка существования файла "$HOMEPATHWEBUSERS/$1/.my.cnf" (конец)

			fi
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
				echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения скрипта dbSetMyCnfFile${COLOR_NC}".
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetMyCnfFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Отобразить список всех баз данных, владельцем которой является пользователь mysql $1_%
#$1-user ;
#return 0 - базы данных найдены, 1 - не переданы параметры, 2 - базы данных не найдены
dbViewBasesByUsername() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SHOW DATABASES LIKE '$1\_%';") ]]; then
					#непустой результат
					echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL пользователя ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
			        mysql -e "SHOW DATABASES LIKE '$1\_%';"
			        return 0
					#непустой результат (конец)
				else
				    #пустой результат
					echo -e "${COLOR_LIGHT_RED}Базы данных, в имени которых содержится значение ${COLOR_GREEN}\"$1\"${COLOR_LIGHT_RED} отсутствуют${COLOR_NC}"
					#пустой результат (конец)
					return 2
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

#
#Вывод всех таблиц базы данных $1
#$1-dbname ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - база данных не существует
dbShowTables() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#проверка существования базы данных "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
			then
			#база $1 - существует
				mysql -e "SHOW TABLES FROM $1;"
				return 0
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbShowTables\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Отобразить список всех пользователей mysql,содержащих в названии переменную $1
#$1-переменная для поиска пользователя ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователи отсутствуют
dbViewAllUsersByContainName() {
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
		    			echo -e "${COLOR_RED}Пользователи, в имени которых содержится значение ${COLOR_GREEN}\"$1\"${COLOR_RED} отсутствуют. Функция ${COLOR_GREEN}\"dbViewAllUsersByContainName\"${COLOR_NC}"
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

#
#Вывод списка всех баз данных
dbViewAllBases() {
    echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL ${COLOR_NC}"
	mysql -e "show databases;"
}

#
#Вывод списка всех пользователей mysql
dbViewAllUsers() {
    echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL ${COLOR_NC}"
	mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user;"
}

#
#Отобразить список всех баз данных mysql с названием, содержащим переменную $1
#$1-Переменная, по которой необходимо осуществить поиск баз данных ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователи отсутствуют
dbViewBasesByTextContain() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SHOW DATABASES LIKE '%$1%';") ]]; then
					#непустой результат
					echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL содержащих в названии слово ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
			        mysql -e "SHOW DATABASES LIKE '%$1%';"
			        return 0
					#непустой результат (конец)
				else
				    #пустой результат
					echo -e "${COLOR_LIGHT_RED}Пользователи, в имени которых содержится значение ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} отсутствуют${COLOR_NC}"
					return 2
					#пустой результат (конец)
				fi
		#Конец проверки на пустой результат
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewBasesByTextContain\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Вывод прав пользователя mysql на все базы
#$1-user ; $2-host ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователь не существует
dbViewUserGrant() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then
		#Пользователь mysql "$1" существует
		    mysql -e "SHOW GRANTS FOR '$1'@'$2';"
		    return 0
		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"dbViewUserGrant\"${COLOR_NC}"
		    return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewUserGrant\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}