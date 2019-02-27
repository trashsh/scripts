#!/bin/bash


########################################################### mysql ###########################################################
declare -x -f dbCreateBase          #Создание базы данных $1:
                                    #$1-dbname ;
                                    #$2-CHARACTER SET (например utf8) ;
                                    #$3-COLLATE (например utf8_general_ci) ;
                                    #$4 - режим (normal/silent)

                                    #return 0 - выполнено успешно.
                                    #1 - не переданы параметры,
                                    #2 - база данных уже существует
                                    #3 - ошибка при проверке наличия базы после ее создания,
                                    #4 - ошибка в параметре mode - silent/normal

declare -x -f dbUseradd             #Добавление пользователя mysql
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

declare -x -f dbCheckExportedBase
                                    #Проверка успешности выгрузки базы данных mysql $1 в архив $3
                                    #$1 - Имя базы данных ;
                                    #$2 - Режимы: silent/error_only/full_info  - вывод сообщений о выполнении операции
                                    #$3 - Путь к архиву ;

                                    #return 0 - файл существует,
                                    #1 - ошибка передачи параметров,
                                    #2 - файл не существует,
                                    #3 - ошибка передачи параметра mode
                                    #4 - база данных не существует

#declare -x -f dbInsertToDbUsers     #Добавление записи в базу mysql-webserver-users
                                    #$1-username ;
                                    #$2-homedir ;

                                    #return 0 - выполнено успешно, 1 - отсутствуют параметры
                                    #2 - отсутствует база данных
                                    #3 - пользователь уже имелся в базе данных mysql
                                    #4 - после попытки создания записи, запись не обнаружена

declare -x -f dbAddRecordToDb       #добавление записи в таблицу
                                    #$1-dbname ;
                                    #$2-table;
                                    #$3 - столбец для вставки;
                                    #$4 - текст вставки;
                                    #$5-подтверждение "insert"

                                    #return 0 - выполнено успешно
                                    #1 - отсутствуют параметры запуска
                                    #2 - не существует база данных $2
                                    #3 - таблица не существует
                                    #4 - столбец не существует для поиска
                                    #5  - отсутствует подтверждение

declare -x -f dbDeleteRecordFromDb  #удаление записи из таблицы
                                    #$1-dbname ; $2-table; $3 - столбец; $4 - текст для поиска; $5-подтверждение "delete"
                                    #return 0 - выполнено успешно
                                    #1 - отсутствуют параметры запуска
                                    #2 - не существует база данных $2
                                    #3 - таблица не существует
                                    #4 - столбец не существует
                                    #5 - запись отсутствует
                                    #6  - отсутствует подтверждение
declare -x -f dbUpdateRecordToDb    #обновление записи в таблице
                                    #$1-dbname ;
                                    #$2-table;
                                    #$3 - столбец для поиска;
                                    #$4 - текст для поиска;
                                    #$5 - обновляемый столбец,
                                    #$6 - вставляемый текст,
                                    #$7-подтверждение "update"

                                    #return 0 - выполнено успешно
                                    #1 - отсутствуют параметры запуска
                                    #2 - не существует база данных $2
                                    #3 - таблица не существует
                                    #4 - столбец не существует для поиска
                                    #5 - запись отсутствует
                                    #6  - отсутствует подтверждение
                                    #7 - отсутствует столбец для вставки текста

########################################################### backup ###########################################################
declare -x -f dbBackupBase #Создание бэкапа указанной базы данных: ($1-dbname ; $2-В параметре $2 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` )


########################################################### users ###########################################################
declare -x -f userAddSystem #Добавление системного пользователя: ($1-user ;)

########################################################### mysql ###########################################################
####НЕ ТРОГАТЬ
#Создание базы данных $1
#$1-dbname ;
#$2-CHARACTER SET (например utf8) ;
#$3-COLLATE (например utf8_general_ci) ;
#$4 - режим (normal/silent)

#return 0 - выполнено успешно.
#1 - не переданы параметры,
#2 - база данных уже существует
#3 - ошибка при проверке наличия базы после ее создания,
#4 - ошибка в параметре mode - silent/normal
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
	    	     		mysql -e "CREATE DATABASE IF NOT EXISTS $1 CHARACTER SET $2 COLLATE $3;";
	    	     		#Финальная проверка существования базы данных "$1"
                         if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                            then
                            #база $1 - существует
                                return 0
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
	    	     		mysql -e "CREATE DATABASE IF NOT EXISTS $1 CHARACTER SET $2 COLLATE $3;";
	    	     		#Финальная проверка существования базы данных "$1"
                         if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                            then
                            #база $1 - существует
                                echo -e "${COLOR_GREEN}База данных ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно создана ${COLOR_NC}"
                                return 0
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
	    	     		mysql -e "CREATE DATABASE IF NOT EXISTS $1 CHARACTER SET $2 COLLATE $3;";
	    	     		#Финальная проверка существования базы данных "$1"
                         if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
                            then
                            #база $1 - существует
                                return 0
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
                        echo -e "${COLOR_GREEN}Пользователь mysql ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно создан ${COLOR_NC}"
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


###НЕ ТРОГАТЬ
#Проверка успешности выгрузки базы данных mysql $1 в архив $3
#$1 - Имя базы данных ;
#$2 - Режимы: silent/error_only/full_info  - вывод сообщений о выполнении операции
#$3 - Путь к архиву ;

#return 0 - файл существует,
#1 - ошибка передачи параметров,
#2 - файл не существует,
#3 - ошибка передачи параметра mode
#4 - база данных не существует
dbCheckExportedBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    #Проверка существования базы данных "$1"
	    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
	    	then
	    	#база $1 - существует
	    		case "$2" in
	    			silent)
	    				#Проверка существования файла "$3"
	    				if [ -f $3 ] ; then
	    				    #Файл "$3" существует
	    				    return 0;
	    				    #Файл "$3" существует (конец)
	    				else
	    				    #Файл "$3" не существует
	    				    return 2;
	    				    #Файл "$3" не существует (конец)
	    				fi
	    				#Конец проверки существования файла "$3"
	    				;;
	    			full_info)
	    			    #Проверка существования файла "$3"
	    				if [ -f $3 ] ; then
	    				    #Файл "$3" существует
	    				    echo -e "${COLOR_GREEN}Выгрузка базы данных MYSQL:${COLOR_NC} ${COLOR_YELLOW}\"$1\"${COLOR_NC} ${COLOR_GREEN}успешно завершилась в файл ${COLOR_NC}${COLOR_YELLOW} \"$3\"${COLOR_NC}"
	    				    return 0;
	    				    #Файл "$3" существует (конец)
	    				else
	    				    #Файл "$3" не существует
	    				     echo -e "${COLOR_RED}Выгрузка базы данных: ${COLOR_NC}${COLOR_YELLOW}\"$1\"${COLOR_NC}${COLOR_RED} в файл ${COLOR_YELLOW}\"$3\"${COLOR_NC}${COLOR_RED} завершилась с ошибкой. Указанный файл отсутствует${COLOR_NC}"
	    				    return 2;
	    				    #Файл "$3" не существует (конец)
	    				fi
	    				#Конец проверки существования файла "$3"
	    				;;
	    			error_only)
	    			    #Проверка существования файла "$3"
	    				if [ -f $3 ] ; then
	    				    #Файл "$3" существует
	    				    return 0;
	    				    #Файл "$3" существует (конец)
	    				else
	    				    #Файл "$3" не существует
	    				     echo -e "${COLOR_RED}Выгрузка базы данных: ${COLOR_NC}${COLOR_YELLOW}\"$1\"${COLOR_NC}${COLOR_RED} в файл ${COLOR_YELLOW}\"$3\"${COLOR_NC}${COLOR_RED} завершилась с ошибкой. Указанный файл отсутствует${COLOR_NC}"
	    				    return 2;
	    				    #Файл "$3" не существует (конец)
	    				fi
	    				#Конец проверки существования файла "$3"
	    				;;
	    			*)
	    				echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbCheckExportedBase\"${COLOR_NC}";
	    				return 3;;

	    		esac
	    	#база $1 - существует (конец)
	    	else
	    	#база $1 - не существует
	    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbCheckExportedBase\" ${COLOR_NC}"
	    	     return 4
	    	#база $1 - не существует (конец)
	    fi
	    #конец проверки существования базы данных $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbCheckExportedBase\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




#удаление записи из таблицы
#$1-dbname ; $2-table; $3 - столбец; $4 - текст для поиска; $5-подтверждение "delete"
#return 0 - выполнено успешно
#1 - отсутствуют параметры запуска
#2 - не существует база данных $2
#3 - таблица не существует
#4 - столбец не существует
#5 - запись отсутствует
#6  - отсутствует подтверждение
dbDeleteRecordFromDb() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
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
                        #Проверка существования столбца $3 в таблице $2
                        if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$2'" 2>&1`" ]];
                        	then
                        	#столбец $2 существует
                                #Проверка существования записи в базе денных
                                if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM $1.$2 WHERE $3='$4'" 2>&1`" ]];
                                	then
                                	#запись существует
                                		case "$5" in
                                			delete)
                                				mysql -e "DELETE FROM $2 WHERE $3 = '$4'" $1
                                				return 0
                                				;;
                                			*)
                                				echo -e "${COLOR_RED}Ошибка передачи подтверждения в функцию ${COLOR_GREEN}\"dbDeleteRecordFromDb\"${COLOR_NC}"
                                				return 6
                                				;;
                                		esac
                                	#запись существует (конец)	
                                	else
                                	#запись не существует
                                        return 5
                                	#запись не существует
                                fi
                                #Проверка существования записи в базе денных (конец)
                        	#столбец $2 существует (конец)
                        	else
                        	#столбец $2 не существует

                        	    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$2\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
                        	    return 4
                        	#столбец $2 не существует (конец)
                        fi
                        #Проверка существования столбца $3 в таблице $2 (конец)
					#таблица $2 существует (конец)
					else
					#таблица $2 не существует
					     echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
					     return 3
					#таблица $2 не существует (конец)
				fi
				#Проверка существования таблицы в базе денных $1 (конец)
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#обновление записи в таблице
#$1-dbname ; $2-table; $3 - столбец для поиска; $4 - текст для поиска; $5 - обновляемый столбец, $6 - вставляемый текст, $7-подтверждение "update"
#return 0 - выполнено успешно
#1 - отсутствуют параметры запуска
#2 - не существует база данных $2
#3 - таблица не существует
#4 - столбец не существует для поиска
#5 - запись отсутствует
#6  - отсутствует подтверждение
#7 - отсутствует столбец для вставки текста
dbUpdateRecordToDb() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
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
                        #Проверка существования столбца $3 в таблице $2
                        if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$2'" 2>&1`" ]];
                        	then
                        	#столбец $2 существует
                                #Проверка существования записи в базе денных
                                if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM $1.$2 WHERE $3='$4'" 2>&1`" ]];
                                	then
                                	#запись существует
                                		#Проверка существования столбца $5 в таблице $2
                                		if [[ ! -z "`mysql -qfsBe "SELECT '$5' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$2'" 2>&1`" ]];
                                			then
                                			#столбец $5 существует
                                				 case "$7" in
                                                        update)
                                                            mysql -e "UPDATE $1.$2 SET $5='$6' where $3='$4';"
                                                            return 0
                                                            ;;
                                                        *)
                                                            echo -e "${COLOR_RED}Ошибка передачи подтверждения в функцию ${COLOR_GREEN}\"dbUpdateRecordToDb\"${COLOR_NC}"
                                                            return 6
                                                            ;;
                                                    esac
                                			#столбец $5 существует (конец)
                                			else
                                			#столбец $5 не существует
                                			    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$5\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbUpdateRecordToDb\" ${COLOR_NC}"
                                			    return 7
                                			#столбец $5 не существует (конец)
                                		fi
                                		#Проверка существования столбца $5 в таблице $2 (конец)

                                	#запись существует (конец)
                                	else
                                	#запись не существует
                                        return 5
                                	#запись не существует

                                fi
                                #Проверка существования записи в базе денных (конец)
                        	#столбец $2 существует (конец)
                        	else
                        	#столбец $2 не существует

                        	    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$2\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
                        	    return 4
                        	#столбец $2 не существует (конец)
                        fi
                        #Проверка существования столбца $3 в таблице $2 (конец)
					#таблица $2 существует (конец)
					else
					#таблица $2 не существует
					     echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
					     return 3
					#таблица $2 не существует (конец)
				fi
				#Проверка существования таблицы в базе денных $1 (конец)
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#добавление записи в таблицу
#$1-dbname ;
#$2-table;
#$3 - столбец для вставки;
#$4 - текст вставки;
#$5-подтверждение "insert"

#return 0 - выполнено успешно
#1 - отсутствуют параметры запуска
#2 - не существует база данных $2
#3 - таблица не существует
#4 - столбец не существует для поиска
#5  - отсутствует подтверждение
dbAddRecordToDb() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
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
                        #Проверка существования столбца $3 в таблице $2
                        if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$2'" 2>&1`" ]];
                        	then

                                				 case "$5" in
                                                        insert)
                                                            mysql -e "INSERT INTO $1.$2 ($3) VALUES ('$4');"
                                                            return 0
                                                            ;;
                                                        *)
                                                            echo -e "${COLOR_RED}Ошибка передачи подтверждения в функцию ${COLOR_GREEN}\"dbUpdateRecordToDb\"${COLOR_NC}"
                                                            return 5
                                                            ;;
                                                    esac


                        	#столбец $2 существует (конец)
                        	else
                        	#столбец $2 не существует

                        	    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$2\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
                        	    return 4
                        	#столбец $2 не существует (конец)
                        fi
                        #Проверка существования столбца $3 в таблице $2 (конец)
					#таблица $2 существует (конец)
					else
					#таблица $2 не существует
					     echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
					     return 3
					#таблица $2 не существует (конец)
				fi
				#Проверка существования таблицы в базе денных $1 (конец)
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Добавление записи в базу mysql-webserver-users
#$1-username ;
#$2-homedir ;

: '
#return 0 - выполнено успешно, 1 - отсутствуют параметры
#2 - отсутствует база данных
#3 - пользователь уже имелся в базе данных mysql
#4 - после попытки создания записи, запись не обнаружена
dbInsertToDbUsers() {
    dt=$DATETIMESQLFORMAT
    user=$(whoami)
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования базы данных "$WEBSERVER_DB"
		if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$WEBSERVER_DB'" 2>&1`" ]];
			then
			#база $WEBSERVER_DB - существует
                    #Проверка существования каталога "$2"
                    if [ -d $2 ] ; then
                        #Каталог "$2" существует    
                        
                        #Проверка существования записи в базе денных
                        if [[ ! -z "`mysql -qfsBe "SELECT * FROM lamer_webserver.users WHERE username='$1'" 2>&1`" ]];
                        	then
                        	#запись существует
                        		echo -e "${COLOR_YELLOW}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} уже имеется в базе данных ${COLOR_GREEN}\"$WEBSERVER_DB\"${COLOR_YELLOW}  ${COLOR_NC}"
                        		return 3
                        	#запись существует (конец)	
                        	else
                        	#запись не существует
                        	     echo "INSERT INTO users (id_user,username,homedir,isAdminAccess,isSudo,isSshAccess,isFtpAccess,created,created_by) VALUES (null, '$1', '$2',null,null,null,null,'$dt','$user');" | mysql lamer_webserver;


                        	     #Окончательная проверка существования записи в базе денных
                        	     if [[ ! -z "`mysql -qfsBe "SELECT * FROM lamer_webserver.users WHERE username='$1'" 2>&1`" ]];
                        	     	then
                        	     	#запись существует
                        	     	    echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно добавлен в базу данных ${COLOR_YELLOW}\"$WEBSERVER_DB\"${COLOR_GREEN}  ${COLOR_NC}"
                        	     		return 0
                        	     	#запись существует (конец)
                        	     	else
                        	     	#запись не существует
                        	     	     return 4
                        	     	#запись не существует
                        	     fi
                        	     #Окончательная проверка существования записи в базе денных (конец)
                        	#запись не существует
                        fi
                        #Проверка существования записи в базе денных (конец)
                        
                        

                        #Каталог "$2" существует (конец)
                    else
                        #Каталог "$2" не существует   
                        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbInsertToDbUsers\"${COLOR_NC}"
                        
                        #Каталог "$2" не существует (конец)
                    fi
                    #Конец проверки существования каталога "$2"

			#база $WEBSERVER_DB - существует (конец)
			else
			#база $WEBSERVER_DB - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$WEBSERVER_DB\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbInsertToDbUsers\" ${COLOR_NC}"
			     return 2
			#база $WEBSERVER_DB - не существует (конец)
		fi
		#конец проверки существования базы данных $WEBSERVER_DB


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbInsertToDbUsers\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}
########################################################### backup ###########################################################
'

#Полностью готово
#Создание бэкапа указанной базы данных
#$1-user,
#$2-dbname ;
#$3 - full_info/silent - вывод сообщений о выполнении операции
#$4-В параметре $4 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;

#return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - отсутствует база данных,
#3 - отменено пользователем создание каталога
#4 - ошибка при финальной проверке создания бэкапа,
#5 - ошибка передачи параметра full_info/silent,
#6 - не существует пользователь
dbBackupBase() {
	#	d=`date +%Y.%m.%d`;
    #	dt=`date +%Y.%m.%d_%H.%M.%S`;
    date=$DATEFORMAT
    datetime=$DATETIMEFORMAT

    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
    then
    #Параметры запуска существуют

        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		    #Проверка существования базы данных "$2"
            if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$2'" 2>&1`" ]];
            	then
            	#база $2 - существует

                        #Пользователь mysql "$1" существует

                        #извлечение названия базы данных (с учетом, что это может быть дополнительная база данных к сайту)
                        dopdbname_trim_dbname=${2#$1_}
                        #извлечение названия сайта из названия базы данных
                        sitedomain_trim_dbname=${dopdbname_trim_dbname%_*}

                        #Проверка на существование параметров запуска скрипта
                        if [ -n "$4" ]
                        then
                        #Параметры запуска существуют
                            DESTINATIONFOLDER=$4
                        #Параметры запуска существуют (конец)
                        else
                        #Параметры запуска отсутствуют
                            DESTINATIONFOLDER=$BACKUPFOLDER_DAYS/$1/$sitedomain_trim_dbname/$date
                        #Параметры запуска отсутствуют (конец)
                        fi
                        #Конец проверки существования параметров запуска скрипта

                        #пусть к файлу с бэкапом без расширения
                        FILENAME=$DESTINATIONFOLDER/sql.$1-"$2"-$datetime.sql

                        #Проверка существования каталога "$DESTINATIONFOLDER"
                        if [ -d $DESTINATIONFOLDER ] ; then

                            #Каталог "$DESTINATIONFOLDER" существует
                            case "$3" in
                                silent)
                                    mysqldump --databases $2 > $FILENAME
                                    tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz
                                    chModAndOwnFile $FILENAME.tar.gz $1 www-data 644
                                    dbCheckExportedBase $2 error_only $FILENAME.tar.gz
                                    return 0
                                    ;;
                                full_info)
                                    mysqldump --databases $2 > $FILENAME
                                    tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz
                                    chModAndOwnFile $FILENAME.tar.gz $1 www-data 644
                                    dbCheckExportedBase $2 full_info $FILENAME.tar.gz
                                    return 0
                                    ;;
                                *)
                                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    return 6
                                    ;;
                            esac
                            #Каталог "$DESTINATIONFOLDER" существует (конец)

                        else
                            #Каталог "$DESTINATIONFOLDER" не существует
                            case "$3" in
                                silent)
                                    #mkdir -p $DESTINATIONFOLDER;
                                    mkdirWithOwn $DESTINATIONFOLDER $1 www-data 755
                                    chown $1:www-data $BACKUPFOLDER_DAYS/$1/ -R
                                    mysqldump --databases $2 > $FILENAME;
                                    tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz;
                                    dbCheckExportedBase $2 error_only $FILENAME.tar.gz
                                    chModAndOwnFile $FILENAME.tar.gz $1 www-data 644
                                    return 0
                                    ;;
                                full_info)
                                    echo -e "${COLOR_RED} Каталог ${COLOR_YELLOW}\"$DESTINATIONFOLDER\"${COLOR_NC}${COLOR_RED} не найден. Создать его? Функция ${COLOR_GREEN}\"dbBackupBase\".${COLOR_NC}"
                                    echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$DESTINATIONFOLDER\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                                    while read
                                    do
                                    echo -n ": "
                                        case "$REPLY" in
                                        y|Y)
                                            #mkdir -p $DESTINATIONFOLDER;
                                            mkdirWithOwn $DESTINATIONFOLDER $1 www-data 755
                                            chown $1:www-data $BACKUPFOLDER_DAYS/$1/ -R
                                            mysqldump --databases $2 > $FILENAME;
                                            tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz;
                                            dbCheckExportedBase $2 full_info $FILENAME.tar.gz;
                                            chModAndOwnFile $FILENAME.tar.gz $1 www-data 644
                                            return 0;
                                            break;;
                                        n|N)
                                            echo -e "${COLOR_RED}Операция по созданию базы данных ${COLOR_GREEN}\"$2\"${COLOR_RED} отменена пользователем.${COLOR_NC}"
                                            return 3;;
                                        esac
                                    done
                                    ;;
                                *)
                                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    return 5
                                    ;;
                            esac
                            #Каталог "$DESTINATIONFOLDER" не существует (конец)
                        fi
                        #Пользователь mysql "$1" существует (конец)

            	#база $2 - существует (конец)
            	else
            	#база $2 - не существует
            	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupBase\" ${COLOR_NC}"
            	     return 2
            	#база $2 - не существует (конец)
            fi
            #конец проверки существования базы данных $2
        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}"
                return 6

        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1



    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}


########################################################### users ###########################################################

#Готово. Можно добавить доп.функционал
#Добавление системного пользователя
#$1-user ;
#return 0 - выполнено успешно, 1 - пользователь уже существует
#2 - пользователь отменил создание пользователя
userAddSystem() {
    echo -e "${COLOR_YELLOW}"Список имеющихся пользователей системы:"${COLOR_NC}"
	viewGroupUsersAccessAll
	#Проверка на существование параметров запуска скрипта

	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    username=$1
	    dt=$DATETIMESQLFORMAT

	else
	    echo -e -n "${COLOR_BLUE}"Введите имя нового пользователя: "${COLOR_NC}"
		read username
	fi
	    grep "^$username:" /etc/passwd >/dev/null

	    #Проверка на успешность выполнения предыдущей команды
	    if [ $? -eq 0 ]
	    	then
	    		#Пользователь уже существует
	    		echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} уже существует${COLOR_NC}"
	    		return 1
	    		#Пользователь уже существует (конец)
	    else
                #Пользователь не существует и будет добавлен
                echo -n -e "${COLOR_YELLOW}Подтвердите добавление пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введя ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, или для отмены операции ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                while read
                do
                    case "$REPLY" in
                        y|Y)
                            echo -e "${COLOR_YELLOW}Выполнение операций по созданию пользователя ${COLOR_GREEN}\"$username\"${COLOR_NC}"
                            echo -n -e "${COLOR_YELLOW}Установите пароль пользователя ${COLOR_GREEN}$username: ${COLOR_NC}: "
                            read password

                            #Проверка на пустое значение переменной
                            if [[ -z "$password" ]]; then
                                #переменная имеет пустое значение
                                echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя"${COLOR_NC}"
                                #переменная имеет пустое значение (конец)
                            else
                                #переменная имеет не пустое значение
                                mkdir -p $HOMEPATHWEBUSERS/$username
                                useradd -N -g users -G ftp-access -d $HOMEPATHWEBUSERS/$username -s /bin/bash $username

                                dbAddRecordToDb $WEBSERVER_DB users username $username insert
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username homedir $HOMEPATHWEBUSERS/$username update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username created "$dt" update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username created_by $(whoami) update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username isAdminAccess 0 update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username isFtpAccess 1 update

                                echo "$username:$password" | chpasswd

                                mkdirWithOwn $HOMEPATHWEBUSERS/$username/.backups $username users 777
                                mkdirWithOwn $HOMEPATHWEBUSERS/$username/.backups/auto $username users 755
                                mkdirWithOwn $HOMEPATHWEBUSERS/$username/.backups/manually $username users 755
                                touchFileWithModAndOwn $HOMEPATHWEBUSERS/$username/.bashrc $username users 644
                                touchFileWithModAndOwn $HOMEPATHWEBUSERS/$username/.sudo_as_admin_successful $username users 644
                                echo "source /etc/profile" >> $HOMEPATHWEBUSERS/$username/.bashrc
                                sed -i '$ a source $SCRIPTS/include/include.sh'  $HOMEPATHWEBUSERS/$username/.bashrc
                                dbSetMyCnfFile $username $password
                                chModAndOwnFile $HOMEPATHWEBUSERS/$username/.my.cnf $username users 600
                                #chModAndOwnFolderAndFiles $HOMEPATHWEBUSERS/$username 755 644 $username users
                                #добавление в группу sudo
                                userAddToGroup $username sudo 1

                                #Проверка на успешность выполнения предыдущей команды
                                if [ $? -eq 0 ]
                                	then
                                		#предыдущая команда завершилась успешно
                                		    dbUpdateRecordToDb $WEBSERVER_DB users username $username isSudo 1 update
                                		#предыдущая команда завершилась успешно (конец)
                                	else
                                		#предыдущая команда завершилась с ошибкой
                                		    dbUpdateRecordToDb $WEBSERVER_DB users username $username isSudo 0 update
                                		#предыдущая команда завершилась с ошибкой (конец)
                                fi
                                #Конец проверки на успешность выполнения предыдущей команды

                                echo -n -e "${COLOR_YELLOW}Введите ${COLOR_BLUE}\"g\"${COLOR_NC}${COLOR_YELLOW} для генерации ssh-ключа, ${COLOR_GREEN}\"i\"${COLOR_NC}${COLOR_YELLOW} - для импорта существующего на сервер ключа, ${COLOR_BLUE}\"q\"${COLOR_YELLOW} - для отмены добавления ssh-ключа${COLOR_NC}: "
                                	while read
                                	do
                                    	echo -n ": "
                                    	case "$REPLY" in
                                	    	g|G) sshKeyGenerateToUser $username;
                                	    	     sshKeyAddToUser $username 0 $sshAdminKeyFilePath;
                                	    	     dbUpdateRecordToDb $WEBSERVER_DB users username $username isSshAccess 1 update
                                		    	break;;
                                		    i|I)
                                                sshKeyAddToUser $username 1;
                                                sshKeyAddToUser $username 0 $sshAdminKeyFilePath;
                                                dbUpdateRecordToDb $WEBSERVER_DB users username $username isSshAccess 1 update
                                		    	break;;
                                		    q|Q)
                                		        dbUpdateRecordToDb $WEBSERVER_DB users username $username isSshAccess 0 update
                                			    break;;
                                	    esac
                                	done

                                #создание пользователя mysql
                                dbUseradd $username $password % pass user
                                dbAddRecordToDb $WEBSERVER_DB db_users username $username insert
                                dbUpdateRecordToDb $WEBSERVER_DB db_users username $username created "$dt" update
                                dbUpdateRecordToDb $WEBSERVER_DB db_users username $username created_by $(whoami) update



                                echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$username\"${COLOR_GREEN} успешно добавлен${COLOR_YELLOW}\"\"${COLOR_GREEN} ${COLOR_NC}"
                                viewUserFullInfo $username

                                return 0
                            fi
                            #Проверка на пустое значение переменной (конец)

                            break
                            ;;
                        n|N)
                            echo -e "${COLOR_RED}Отмена создания пользователя ${COLOR_GREEN}\"$username\"${COLOR_NC}"
                            return 2
                            break
                            ;;
                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                           ;;
                    esac
                done

	##Здесь описать порядок действий при создании пользователя
	return 0
                #Пользователь не существует и будет добавлен (конец)
	    fi
	    #Конец проверки на успешность выполнения предыдущей команды
	#Параметры запуска существуют (конец)
}
