#!/bin/bash
declare -x -f dbSetMyCnfFile
###Полностью готово. Не трогать. 07.03.2019 г.
#Смена пароля и создание файла ~/.my.cnf (только файл)
###input:
#$1-system user home dir ;
#$2-mysql user ;
#$3-mysql password ;
#$4-system user;
#return:
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - каталог пользователя не существует
#3 - после выполнения функции файл my.cnf не найден
#4 - пользователь mysql $2 - не существует
dbSetMyCnfFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then

        #Проверка существования каталога "$1"
        if [ -d $1 ] ; then
            #Каталог "$1" существует
                    #Проверка на существование пользователя mysql "$2"
				if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$2'" 2>&1`" ]];
				then
				#Пользователь mysql "$2" существует
                    #Проверка существования файла ""$1"/"my.cnf""
                    if [ -f "$1"/"my.cnf" ] ; then
                        #Файл ""$1"/"my.cnf"" существует
                             backupImportantFile $4 "my.cnf"  $1/.my.cnf
                             sudo sed -i "s/.*password=.*/password=$3/" $1/.my.cnf
                        #Файл ""$1"/"my.cnf"" существует (конец)
                    else
                        #Файл ""$1"/"my.cnf"" не существует
                            sudo touch $1/.my.cnf
                            sudo chmod 666 /$1/.my.cnf
                            sudo cat $1/.my.cnf | sudo grep $HOMEPATHWEBUSERS
                                                {
                                        echo '[mysqld]'
                                        echo 'init_connect=‘SET collation_connection=utf8_general_ci’'
                                        echo 'character-set-server=utf8'
                                        echo 'collation-server=utf8_general_ci'
                                        echo ''
                                        echo '[client]'
                                        echo 'default-character-set=utf8'
                                        echo 'user='$2
                                        echo 'password='$3
                                        } > $1/.my.cnf
                            sudo chmod 600 $1/.my.cnf
                            sudo chown $1:users $1/.my.cnf

                            backupImportantFile $4 "my.cnf"  $1/.my.cnf

                            #Финальная проверка существования файла "$1/.my.cnf"
                            if [ -f $1/.my.cnf ] ; then
                                #Файл "$1/.my.cnf" существует
                                return 0
                                #Файл "$1/.my.cnf" существует (конец)
                            else
                                #Файл "$1/.my.cnf" не существует
                                echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1/.my.cnf\"${COLOR_RED} не существует${COLOR_NC}"
                                return 3
                                #Файл "$1/.my.cnf" не существует (конец)
                            fi
                            #Финальная проверка существования файла "$1/.my.cnf" (конец)

                        #Файл ""$1"/"my.cnf"" не существует (конец)
                    fi
                    #Конец проверки существования файла ""$1"/"my.cnf""

				#Пользователь mysql "$2" существует (конец)
				else
				#Пользователь mysql "$2" не существует
				    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetMyCnfFile\" ${COLOR_NC}"
				    return 4
				#Пользователь mysql "$2" не существует (конец)
				fi
				#Конец проверки на существование пользователя mysql "$2"
            #Каталог "$1" существует (конец)
        else
            #Каталог "$1" не существует
            echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetMyCnfFile\"${COLOR_NC}"
            return 2
            #Каталог "$1" не существует (конец)
        fi
        #Конец проверки существования каталога "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetMyCnfFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}






declare -x -f dbUserSetAccessToBase
#установка прав доступа пользователю на базу
###input
#$1-mysql user ;
#$2-dbname ;
#$3-type - lanAccess (localhost/%) ;
#4 - type-standart/adminGrant/select_only
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь mysql не существует
#3 - база данных не существует
#4 - ошибка передачи параметра lanAccess (localhost/%) ;
dbUserSetAccessToBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют

	    case "$3" in
	        %)
	            lanAccess="%"
	            ;;
	        localhost)
	            lanAccess="localhost"
	            ;;
	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode lanAccess (localhost/%)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbUserSetAccessToBase\"${COLOR_NC}";
	    	    return 4
	    	    ;;
	    esac

		#Проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then
		#Пользователь mysql "$1" существует
            #Проверка существования базы данных "$2"
            if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$2'" 2>&1`" ]];
            	then
            	#база $2 - существует
            		case "$4" in
            		    standart)
                            mysql -e "REVOKE ALL PRIVILEGES ON \`$2\`.* FROM '$1'@'$lanAccess';";
                            mysql -e "GRANT USAGE ON \`$2\`.* TO '$1'@'$lanAccess';";
                            #mysql -e "GRANT OPTION FROM '$1'@'$lanAccess';";
                            mysql -e "FLUSH PRIVILEGES;"
            		        ;;
            		    adminGrant)
                            mysql -e "REVOKE ALL PRIVILEGES ON \`$2\`.* FROM '$1'@'$lanAccess';";
                            mysql -e "GRANT ALL PRIVILEGES ON \`$2\`.* TO '$1'@'$lanAccess' WITH GRANT OPTION;";
                            mysql -e "FLUSH PRIVILEGES;"
            		        ;;
            			select_only)
            			    mysql -e "REVOKE ALL PRIVILEGES ON \`$2\`.* FROM '$1'@'$lanAccess';";
            			    #mysql -e "REVOKE GRANT OPTION ON \`$2\`.* FROM '$1'@'$lanAccess';";
                            mysql -e "GRANT SELECT ON \`$2\`.* TO '$1'@'$lanAccess';";
                            mysql -e "FLUSH PRIVILEGES;"

            				;;
            			*)
            			    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
            			    ;;
            		esac
            	#база $2 - существует (конец)
            	else
            	#база $2 - не существует
            	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"\" ${COLOR_NC}"
            	     return 3
            	#база $2 - не существует (конец)
            fi
            #конец проверки существования базы данных $2


		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserSetAccessToBase\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUserSetAccessToBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f dbExistTable
#Проверка существования таблицы
#Полностью проверено. 14.03.2019
###input
#$1-dbname ;
#$2-table
###return
#0 - таблица существует
#1- не переданы параметры
#2- база данных $1 не существует
#3-таблица не существует
dbExistTable() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования базы данных "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
			then
			#база $1 - существует

			    #Проверка существования таблицы в базе денных $1
			    if [[ ! -z "`mysql -qfsBe "SHOW TABLES FROM $1 LIKE '$2'" 2>&1`" ]];
			    	then
			    	#таблица $2 существует
			    		return 0
			    	#таблица $2 существует (конец)
			    	else
			    	#таблица $2 не существует
			    	     return 3
			    	    echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"\" ${COLOR_NC}"
			    	#таблица $2 не существует (конец)
			    fi
			    #Проверка существования таблицы в базе денных $1 (конец)

			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbExistTable\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbExistTable\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f dbViewUserInfo
#Вывести информацию о пользователе mysql $1. Проверка существования пользователя
#Полностью готово. 13.03.2019
###input
#$1-user ;
#$2-если в параметре значение "0", то результат не выводится, если "1" - результат выводится
###return
#0 - пользователь существует,
#1 - параметры не переданы
#2 - пользователь не существует;
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
			        		echo -e "${COLOR_YELLOW}\nИнформация о пользователе MYSQL ${COLOR_GREEN}\"$1\" ${COLOR_NC}";
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
				    	0)  return 2
				    		;;
				    	1)
				    		echo -e "${COLOR_LIGHT_RED}Пользователь mysql ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} не существует ${COLOR_NC}";
					        return 2;;
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
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f dbViewBasesByTextContain
#Отобразить список всех баз данных mysql с названием, содержащим переменную $1
#Полностью готово. 12.03.2019
###input:
#$1-Переменная, по которой необходимо осуществить поиск баз данных ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователи отсутствуют
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
					echo -e "${COLOR_LIGHT_RED}\nБазы данных, в имени которых содержится значение ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} отсутствуют${COLOR_NC}"
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


declare -x -f dbViewAllUsers
#Вывод списка всех пользователей mysql
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
dbViewAllUsers() {
    echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL ${COLOR_NC}"
	mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user;"
}

declare -x -f dbViewAllBases
#Вывод списка всех баз данных
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
dbViewAllBases() {
    echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL ${COLOR_NC}"
	mysql -e "show databases;"
}

declare -x -f dbViewUserGrant
#Вывод прав пользователя mysql на все базы
#Готово, но лучше проверить. 11.03.2019 г.
###input
#$1-user ;
#$2-host ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователь не существует
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

declare -x -f dbShowTables
#Вывод всех таблиц базы данных $1
###input:
#$1-dbname ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - база данных не существует
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


declare -x -f dbSetUpdateInfoAccessToBase
#обновление инфомрации в базе данных:
###input:
#$1-dbname ;
#$2-user ;
#$3-host ;
###return:
#0 - выполнено успешно;
#1 - отсутствуют параметры;
#2 - пользователь не существует;
#3 - База данных не существует
dbSetUpdateInfoAccessToBase() {
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
				mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON \`$1\`.* TO '$2'@'$3';"
				return 0
		    	#база $1 - существует (конец)
		    	else
		    	#база $1 - не существует
		    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetUpdateInfoAccessToBase\" ${COLOR_NC}"
		    	     return 3
		    	#база $1 - не существует (конец)
		    fi
		    #конец проверки существования базы данных $1

		#Пользователь mysql "$2" существует (конец)
		else
		#Пользователь mysql "$2" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetUpdateInfoAccessToBase\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$2" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$2"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetUpdateInfoAccessToBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f dbSetFullAccessToBase
#удалить. замена функции - dbUserSetAccessToBase
#Предоставление всех прав пользователю $1 на базу данных $1
###input:
#$1-dbname ;
#$2-user ;
#$3-host ;
###return:
#0 - выполнено успешно;
#1 - отсутствуют параметры;
#2 - пользователь не существует;
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
				mysql -e "GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$2\`@\`$3\` WITH GRANT OPTION; FLUSH PRIVILEGES;"
				return 0
		    	#база $1 - существует (конец)
		    	else
		    	#база $1 - не существует
		    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetFullAccessToBase\" ${COLOR_NC}"
		    	     return 3
		    	#база $1 - не существует (конец)
		    fi
		    #конец проверки существования базы данных $1

		#Пользователь mysql "$2" существует (конец)
		else
		#Пользователь mysql "$2" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetFullAccessToBase\" ${COLOR_NC}"
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






declare -x -f dbChangeUserPassword
#Смена пароля пользователю mysql
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
###input
#$1-user ;
#$2-host ;
#$3-password ;
#$4-autentification type (mysql_native_password) ;
#$5 - system user (не обязательно. Без этого параметра в файл my.cnf изменение не записывается. Можно использовать для дополнительного пользователя mysql)
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователь не существует
#3 - системный пользователь $5 не существует
dbChangeUserPassword() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$5"
			grep "^$5:" /etc/passwd >/dev/null

				#проверка на существование пользователя mysql "$1"
                if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
                then
                #Пользователь mysql "$1" существует
                    mysql -e "ALTER USER '$1'@'$2' IDENTIFIED WITH '$4' BY '$3';"
                    echo -e "${COLOR_LIGHT_PURPLE}Пароль пользователя $1 изменен ${COLOR_NC}"
                    return 0
            #Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbChangeUserPassword\"${COLOR_NC}"
			return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbChangeUserPassword\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f dbUserChangeAccess
#смена прав доступа на сервер для пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 29.03.2019
###input
#$1-type ; 1 - grant , 2 - admin , 3 - user
#$2-host ;
#$3-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь mysql не существует
#3 - ошибка host_type
#4 - ошибка mode_access
dbUserChangeAccess() {
    #Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
        #Проверка на существование пользователя mysql "$3"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$3'" 2>&1`" ]];
        then
        #Пользователь mysql "$3" существует
            username=$3
        #Пользователь mysql "$3" существует (конец)
        else
        #Пользователь mysql "$3" не существует
            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserChangeAccess\" ${COLOR_NC}"
            return 2
        #Пользователь mysql "$3" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$3"

        #Проверка на существование параметров запуска скрипта
        if [ -n "$2" ]
        then
        #Параметры запуска существуют
            case "$2" in
                localhost)
                    host="localhost"
                    ;;
                %)
                    host="%"
                    ;;
                *)
                    echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"dbUserChangeAccess\" ${COLOR_NC}";
                    return 3
                    ;;
            esac
        #Параметры запуска существуют (конец)
		fi
		#Проверка на существование параметров запуска скрипта
        if [ -n "$1" ]
        then
        #Параметры запуска существуют
            case "$1" in
#                    1)
#                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT USAGE ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
#                        mysql -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$username'@'$2';";
#                        mysql -e "FLUSH PRIVILEGES;"
#                        ;;
#                    2)
#                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT RELOAD, PROCESS,  SHOW DATABASES, SUPER, LOCK TABLES, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
#                        mysql -e "FLUSH PRIVILEGES;"
#                        ;;
#                    3)
#                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; GRANT RELOAD, PROCESS, SHOW DATABASES, SUPER, LOCK TABLES, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO '$username'@'$2' REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
#                        mysql -e "FLUSH PRIVILEGES;"
#                        ;;

                    1)
                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT ALL PRIVILEGES ON *.* TO '$username'@'$2' WITH GRANT OPTION;";
                        mysql -e "FLUSH PRIVILEGES;"
                        ;;

                    2)
                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EXECUTE ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
                        mysql -e "FLUSH PRIVILEGES;"
                        ;;
                    3)
                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, FILE, INDEX, ALTER, CREATE TEMPORARY TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
                        mysql -e "FLUSH PRIVILEGES;"
                        ;;
                   *)
                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_dbUserChangeAccess\"${COLOR_NC}";
                        return 4
                        ;;
                esac

        #Параметры запуска существуют (конец)
		fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUserChangeAccess\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта


}
