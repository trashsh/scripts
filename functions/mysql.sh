#!/bin/bash


declare -x -f dbCreateBase
declare -x -f dbDropBase

declare -x -f dbSetMyCnfFile
declare -x -f dbUseradd
declare -x -f dbDropUser
declare -x -f dbSetFullAccessToBase
declare -x -f dbViewUserGrant
declare -x -f dbShowTables
declare -x -f dbViewAllUsers
declare -x -f dbViewAllBases
declare -x -f dbViewBasesByTextContain
declare -x -f dbViewUserInfo
declare -x -f dbExistTable
declare -x -f dbChangeUserPassword
declare -x -f dbUserChangeAccess
declare -x -f dbBackupBasesOneDomain
declare -x -f dbSetUpdateInfoAccessToBase
declare -x -f dbUserSetAccessToBase


declare -x -f dbUserdel

#Удаление пользователя mysql
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
###input:
#$1-user ;
#$2-"drop"-подтверждение ;
###return 0 - выполнено успешно,
#1 - не переданы параметры;
#2 - пользователь не существует;
#3 - подтверждение на удаление не получено
#$4 - пользователь не удалился
dbUserdel() {
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
                    echo -e "${COLOR_GREEN}Пользователь mysql ${COLOR_YELLOW}$1${COLOR_GREEN} удален ${COLOR_NC}"
                    return 0
                #Пользователь mysql "$1" не существует (конец)
                fi
                #Конец проверки на существование пользователя mysql "$1"


            #Пользователь mysql "$1" существует (конец)
            else
            #Пользователь mysql "$1" не существует
                echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserdel\" ${COLOR_NC}"
                return 2
            #Пользователь mysql "$1" не существует (конец)
            fi
            #Конец проверки на существование пользователя mysql "$1"
            #Получено подтверждение на удаление - конец
        else
            #Не получено подтверждение на удаление
            echo -e "${COLOR_RED}Подтверждение на удаление пользователя ${COLOR_GREEN}\"$1\"${COLOR_RED} не получено. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserdel\"${COLOR_NC}"
            return 3
            #Не получено подтверждение на удаление (конец)
		fi
		#Проверка наличия подтверждения на удаление (конец)
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUserdel\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

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



#Вывод списка всех пользователей mysql
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
dbViewAllUsers() {
    echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL ${COLOR_NC}"
	mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user;"
}

#Вывод списка всех баз данных
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
dbViewAllBases() {
    echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL ${COLOR_NC}"
	mysql -e "show databases;"
}


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

###Полностью готово. Не трогать. 07.03.2019 г.
#Смена пароля и создание файла ~/.my.cnf (только файл)
###input:
#$1-system user ;
#$2-mysql user ;
#$3-mysql password ;
#return:
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователь не существует
#3 - после выполнения функции файл my.cnf не найден
#4 - пользователь mysql $2 - не существует
dbSetMyCnfFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				#Проверка на существование пользователя mysql "$2"
				if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$2'" 2>&1`" ]];
				then
				#Пользователь mysql "$2" существует
                    #Проверка существования файла ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf""
                    if [ -f "$HOMEPATHWEBUSERS"/"$1"/"my.cnf" ] ; then
                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" существует
                             backupImportantFile $1 "my.cnf"  $HOMEPATHWEBUSERS/$1/.my.cnf
                             sudo sed -i "s/.*password=.*/password=$3/" $HOMEPATHWEBUSERS/$1/.my.cnf
                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" существует (конец)
                    else
                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" не существует
                            sudo touch $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo chmod 666 $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo cat $HOMEPATHWEBUSERS/$1/.my.cnf | sudo grep $HOMEPATHWEBUSERS
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
                                        } > $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo chmod 600 $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo chown $1:users $HOMEPATHWEBUSERS/$1/.my.cnf

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

                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" не существует (конец)
                    fi
                    #Конец проверки существования файла ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf""

				#Пользователь mysql "$2" существует (конец)
				else
				#Пользователь mysql "$2" не существует
				    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetMyCnfFile\" ${COLOR_NC}"
				    return 4
				#Пользователь mysql "$2" не существует (конец)
				fi
				#Конец проверки на существование пользователя mysql "$2"
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetMyCnfFile\"${COLOR_NC}"
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
				mysql -e "GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$2\`@\`$3\`; FLUSH PRIVILEGES;"
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






#Добавление пользователя mysql
#$1-user ;
#$2-password ;
#$3-host ;
#$4-autentification_type {pass,sha,socket}  ;
#$5-usertype ; {user, admin, adminGrant}
#return 0 - выполнено успешно,
# 1 - отсутствуют параметры запуска
# 2 - неверный параметр usertype,
# 3 - пользователь уже существует,
# 4 - ошибка после выполнения команды на создание пользователя,
# 5 - неверный параметр autentification_type
dbUseradd() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
    #Проверка существования пользователя mysql $1

        #Проверка на существование пользователя mysql "$1"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
        then
        #Пользователь mysql "$1" существует
            echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUseradd\"${COLOR_NC}"
            return 3
        #Пользователь mysql "$1" существует (конец)
        else
        #Пользователь mysql "$1" не существует
            #Проверка правильности параметра $4-autentification_type
            case "$4" in
                        "pass")
                            auth="mysql_native_password";;
                        "sha")
                            auth="sha256_password";;
                        "socket")
                            auth="auth_socket";;
                        *)
                            echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_GREEN}\"dbUseradd-dbViewUserInfo-autentification_type\"${COLOR_NC}";
                            return 5;;
                    esac

                #Проверка правильности параметра $4-autentification_type (конец)
                    #Проверка правильности параметра $5 - тип пользователя
                    case "$5" in
                        "user")  #обычный пользователь
                            mysql -e "CREATE USER '$1'@'$3' IDENTIFIED BY '$2'; GRANT USAGE ON *.* TO '$1'@'$3' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
                            mysql -e "FLUSH PRIVILEGES;"
                            ;;
                        "admin")  mysql -e "GRANT ALL PRIVILEGES ON *.* To '$1'@'$3' IDENTIFIED BY '$2';";
                            mysql -e "FLUSH PRIVILEGES;";
                            ;;
                        "adminGrant")  mysql -e "GRANT ALL PRIVILEGES ON *.* To '$1'@'$3' IDENTIFIED BY '$2' WITH GRANT OPTION;";
                            mysql -e "FLUSH PRIVILEGES;";
                            ;;
                        *)
                            echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_GREEN}\"dbUseradd-dbViewUserInfo-usertype\"${COLOR_NC}";
                            return 2;;
                    esac
                    #Проверка правильности параметра $5 - тип пользователя(конец)

                    #Проверка на существование пользователя mysql "$1" после выполнения всех действий
                    if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
                    then
                    #Пользователь mysql "$1" существует
                        echo -e "${COLOR_GREEN}\nПользователь mysql ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно создан ${COLOR_NC}"
                        #dbAddRecordToDb lamer_webserver db_users username $1 insert
                        infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt

                        fileAddLineToFile $infoFile "---
                        "
                        fileAddLineToFile $infoFile "Mysql-User:"
                        fileAddLineToFile $infoFile "Phpmyadmin: http://$MYSERVER:$APACHEHTTPPORT/$PHPMYADMINFOLDER"
                        fileAddLineToFile $infoFile "Server: $MYSERVER"
                        fileAddLineToFile $infoFile "Port: 3306"
                        fileAddLineToFile $infoFile "Username: $1"
                        fileAddLineToFile $infoFile "Password: $2"
                        fileAddLineToFile $infoFile "Host: $3"
                        fileAddLineToFile $infoFile "------------------------"

                        #Проверка существования системного пользователя "$1"
                        	grep "^$1:" /etc/passwd >/dev/null
                        	if  [ $? -eq 0 ]
                        	then
                        	#Пользователь $1 существует
                        	    dbSetMyCnfFile $1 $1 $2

                        	#Пользователь $1 существует (конец)
                        	fi
                        #Конец проверки существования системного пользователя $1

                        return 0
                    #Пользователь mysql "$1" существует (конец)
                    else
                    #Пользователь mysql "$1" не существует
                        echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не был создан. Произошла ошибка. ${COLOR_NC}"
                        return 4
                    #Пользователь mysql "$1" не существует (конец)
                    fi
                    #Конец проверки на существование пользователя mysql "$1"
                #Пользователь mysql - $1 не существует (конец)
        #Пользователь mysql "$1" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$1"


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUseradd\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Создание базы данных $1
###input
#$1-dbname ;
#$2-CHARACTER SET (например utf8) ;
#$3-COLLATE (например utf8_general_ci) ;
#$4 - режим (full_info/error_only/silent)
###return
#0 - выполнено успешно.
#1 - не переданы параметры,
#2 - база данных уже существует
#3 - ошибка при проверке наличия базы после ее создания,
#4 - ошибка в параметре mode - full_info/error_only/silent
dbCreateBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
	    #Проверка существования базы данных "$1"
	    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
	    	then
	    	#база $1 - существует
	    		echo -e "${COLOR_RED}Ошибка создания базы данных. База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Функция ${COLOR_GREEN}\"dbCreateBase\" ${COLOR_NC}"
				return 2
	    	#база $1 - существует (конец)
	    	else
	    	#база $1 - не существует
	    	     case "$4" in
	    	     	silent)
	    	     		mysql -e "CREATE DATABASE IF NOT EXISTS \`$1\` CHARACTER SET \`$2\` COLLATE \`$3\`;";
	    	     		#Финальная проверка существования базы данных "$1"
                         if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                            then
                            #база $1 - существует
                                true
                            #база $1 - существует (конец)
                            else
                            #база $1 - не существует
                                 echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не была создана.Функция ${COLOR_GREEN}\"dbCreateBase\"${COLOR_NC}"
                                 return 3
                            #база $1 - не существует (конец)
                         fi
                         #Финальная проверка существования базы данных $1 (конец)
	    	     		;;
	    	     	full_info)
	    	     		mysql -e "CREATE DATABASE IF NOT EXISTS \`$1\` CHARACTER SET \`$2\` COLLATE \`$3\`;";
	    	     		#Финальная проверка существования базы данных "$1"
                         if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                            then
                            #база $1 - существует
                                echo -e "${COLOR_GREEN}База данных ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно создана ${COLOR_NC}"
                            #база $1 - существует (конец)
                            else
                            #база $1 - не существует
                                 echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не была создана.Функция ${COLOR_GREEN}\"dbCreateBase\"${COLOR_NC}"
                                 return 3
                            #база $1 - не существует (конец)
                         fi
                         #Финальная проверка существования базы данных $1 (конец)
	    	     		;;
	    	     	error_only)
	    	     		mysql -e "CREATE DATABASE IF NOT EXISTS \`$1\` CHARACTER SET \`$2\` COLLATE \`$3\`;";
	    	     		#Финальная проверка существования базы данных "$1"
                         if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                            then
                            #база $1 - существует
                                true
                            #база $1 - существует (конец)
                            else
                            #база $1 - не существует
                                 echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не была создана.Функция ${COLOR_GREEN}\"dbCreateBase\"${COLOR_NC}"
                                 return 3
                            #база $1 - не существует (конец)
                         fi
                         #Финальная проверка существования базы данных $1 (конец)

	    	     		;;
	    	     	*)
	    	     		echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbCreateBase\"${COLOR_NC}";
	    	     		return 4;;
	    	     esac

	    	#база $1 - не существует (конец)


	    fi
	    #конец проверки существования базы данных $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbCreateBase\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Удаление базы данных mysql
###input:
#$1-dbname ;
#$2-"drop"-подтверждение ;
###return
#0 - успешно удалена база;
#1 - отсутствуют параметры;
#2 - подтверждение на удаление не получено
#3 - база данных не существует;
#4 - после выполнения команды на удаление база удалена не была
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
                   # mysql -e "DROP DATABASE IF EXISTS '$1';"
                    echo "DROP DATABASE IF EXISTS \`$1\`;" | mysql
                    #Финальная проверка существования базы данных "$1"
                    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                    	then
                    	#база $1 - существует
                    	    echo -e "${COLOR_RED}Произошла ошибка удаления базы данных ${COLOR_GREEN}\"$1\"${COLOR_RED} Функция ${COLOR_GREEN}\"dbDropBase\"${COLOR_RED}  ${COLOR_NC}"
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
