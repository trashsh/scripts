
declare -x -f backupImportantFile
#Создание бэкапа в папку BACKUPFOLDER_IMPORTANT
###!Полностью готово. Не трогать больше
###input:
#$1-user ;
#$2-destination_folder (название катала в $BACKUPFOLDER_IMPORTANT);
#$3-архивируемый файл ;
###return:
#0 - выполнено успешно
#1 - отпутствуют параметры
#2 - пользователь $2 - не существует
#3 - файл $3 не найден
#4 - в процессе архивации возникла ошибка
backupImportantFile() {
	date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    #Проверка существования системного пользователя "$1"
	    	grep "^$1:" /etc/passwd >/dev/null
	    	if  [ $? -eq 0 ]
	    	then
	    	#Пользователь $1 существует
                #Проверка существования файла "$3"
                if [ -f $3 ] ; then
                    #Файл "$3" существует
                    #Проверка существования каталога "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1"/"$date"
                    if ! [ -d "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1"/"$date" ] ; then
                        sudo mkdir -p $BACKUPFOLDER_IMPORTANT/$2/$1/$date
                    fi
                    #Проверка существования каталога "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1" (конец)
                        tarFile $3 $BACKUPFOLDER_IMPORTANT/$2/$1/$date/$2.$1__$datetime.tar.gz str silent rewrite $1 users 644 && return 0 || return 4
                    #Файл "$3" существует (конец)
                else
                    #Файл "$3" не существует
                    echo -e "${COLOR_RED} Файл ${COLOR_YELLOW}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_YELLOW}\"backupImportantFile\"${COLOR_NC}"
                    return 3
                    #Файл "$3" не существует (конец)
                fi
                #Конец проверки существования файла "$3"
	    	#Пользователь $1 существует (конец)
	    	else
	    	#Пользователь $1 не существует
	    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"backupImportantFile\"${COLOR_NC}"
	    		return 2
	    	#Пользователь $1 не существует (конец)
	    	fi
	    #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupImportantFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f dbBackupBase
#Создание бэкапа указанной базы данных
###!Полностью готово. Не трогать больше
###input
#$1-dbname ;
#$2 - full_info/error_only - вывод сообщений о выполнении операции
#$3 - mode - data/structure
#$4-В параметре $4 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - ошибка передачи параметров mode - data/structure
#3 - база данных не существует
#4 - ошибка передачи параметров mode - full_info/error_only
#5 - выполнено с ошибками
dbBackupBase() {
    date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`

    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
    then
    #Параметры запуска существуют
    case "$3" in
        data|structure)
            true
            ;;
    	*)
    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
    	    return 2
    	    ;;
    esac

    case "$2" in
        full_info|error_only)
            true
         ;;
    	*)
    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: full_info/error_only\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
    	    return 4
    	    ;;
    esac

    #Проверка существования базы данных "$1"
    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
    	then
    	#база $1 - существует
    		#извлечение имени владельца
             dbExtractUser=${1%\_*}
             #echo $dbExtractUser
             #основная база и дополнительная
             dbNameWithDopBase=${1#$dbExtractUser\_}
             #echo $dbNameWithDopBase
             #извлечение названия дополнительной базы
             dbNameDopBase=${dbNameWithDopBase#*--*}
             #echo $dbNameDopBase
             #извлечения названия основной базы (домена)
             dbNameMainBase=${dbNameWithDopBase%--$dbNameDopBase}
             #echo $dbNameMainBase

             #Проверка на существование параметров запуска скрипта
            if [ -n "$4" ]
            then
            #Параметры запуска существуют
                DESTINATIONFOLDER=$4
            #Параметры запуска существуют (конец)
            else
            #Параметры запуска отсутствуют
                DESTINATIONFOLDER=$BACKUPFOLDER_DAYS/$dbExtractUser/$dbNameMainBase/$date
            #Параметры запуска отсутствуют (конец)
            fi
            #Конец проверки существования параметров запуска скрипта

            #Проверка существования каталога "$DESTINATIONFOLDER"
            if ! [ -d $DESTINATIONFOLDER ] ; then
                #Проверка существования системного пользователя "$dbExtractUser"
                	grep "^$dbExtractUser:" /etc/passwd >/dev/null
                	if  [ $? -eq 0 ]
                	then
                	#Пользователь $dbExtractUser существует
                	    mkdirWithOwn $DESTINATIONFOLDER $dbExtractUser www-data 755
                	    sudo chown -R $dbExtractUser:www-data $BACKUPFOLDER_DAYS/$dbExtractUser
                	#Пользователь $dbExtractUser существует (конец)
                	else
                	#Пользователь $dbExtractUser не существует
                	    mkdirWithOwn $DESTINATIONFOLDER $USERLAMER www-data 755
                	#Пользователь $dbExtractUser не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $dbExtractUser
            fi
            #Конец проверки существования каталога "$DESTINATIONFOLDER"

            case "$3" in
                data)
                    #пусть к файлу с бэкапом без расширения
                    FILENAME=$DESTINATIONFOLDER/mysql.$dbExtractUser=="$1"__$datetime
                    mysqldump --databases $1 > $FILENAME.sql
                    ;;
                structure)
                    #пусть к файлу с бэкапом без расширения
                    FILENAME=$DESTINATIONFOLDER/mysql.$dbExtractUser=="$1"__$datetime\#str
                    mysqldump --databases $1 --no-data > $FILENAME.sql
                    ;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
            	    ;;
            esac

            #Проверка существования системного пользователя "$dbExtractUser"
                grep "^$dbExtractUser:" /etc/passwd >/dev/null
                if  [ $? -eq 0 ]
                then
                #Пользователь $dbExtractUser существует
                    tarFile $FILENAME.sql $FILENAME.sql.tar.gz nostr_rem silent rewrite $dbExtractUser www-data 644
                    chModAndOwnFile $FILENAME.sql.tar.gz $dbExtractUser www-data 644
                #Пользователь $dbExtractUser существует (конец)
                else
                #Пользователь $dbExtractUser не существует
                    tarFile $FILENAME.sql $FILENAME.sql.tar.gz nostr_rem silent rewrite $USERLAMER www-data 644
                    chModAndOwnFile $FILENAME.sql.tar.gz root www-data 644
                #Пользователь $dbExtractUser не существует (конец)
                fi
            #Конец проверки существования системного пользователя $dbExtractUser

            case "$2" in
                full_info)
                    dbCheckExportedBase $1 full_info $FILENAME.sql.tar.gz;
                    ;;
            	error_only)
            		dbCheckExportedBase $1 error_only $FILENAME.sql.tar.gz;
            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode:full_info/structure\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
            	    return 4
            	    ;;
            esac

            #Проверка на успешность выполнения предыдущей команды
            if [ $? -eq 0 ]
            	then
            		#предыдущая команда завершилась успешно
            		return 0
            		#предыдущая команда завершилась успешно (конец)
            	else
            		#предыдущая команда завершилась с ошибкой
            		return 5
            		#предыдущая команда завершилась с ошибкой (конец)
            fi
            #Конец проверки на успешность выполнения предыдущей команды


    	#база $1 - существует (конец)
    	else
    	#база $1 - не существует
    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupBase\" ${COLOR_NC}"
    	     return 3
    	#база $1 - не существует (конец)
    fi
    #конец проверки существования базы данных $1


    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}


declare -x -f dbBackupAllBases
#создание бэкапа всех баз данных
###!Полностью готово. Не трогать больше
###input
#$1-mode:full_info/error_only ;
#$2-mode:data/structure
#$3-Каталог выгрузки ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - ошибка передачи параметра mode:full_info/error_only ;
#3 - ошибка передачи параметра mode:data|structure ;
dbBackupAllBases() {

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
        #Параметры запуска существуют
        case "$1" in
            full_info|error_only)
                case "$2" in
                    data|structure)
                        true
                        ;;
                	*)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: data|structure\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_NC}";
                	    return 3
                	    ;;
                esac
                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_NC}";
        	    return 2
        	    ;;
        esac

        #Проверка на существование параметров запуска скрипта
        if [ -n "$3" ]
        then
        #Параметры запуска существуют
            DESTINATION=$3
        #Параметры запуска существуют (конец)
        else
        #Параметры запуска отсутствуют
             DESTINATION=""
        #Параметры запуска отсутствуют (конец)
        fi
        #Конец проверки существования параметров запуска скрипта


        date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`
        databases=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`


        #выгрузка баз данных
        for db in $databases; do
           if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then


            case "$1" in
                full_info)
                    case "$2" in
                        data)
                            dbBackupBase $db full_info data $DESTINATION
                            ;;
                        structure)
                            dbBackupBase $db full_info structure $DESTINATION
                            ;;
                    esac
                    ;;
                error_only)
                    case "$2" in
                        data)
                            dbBackupBase $db error_only data $DESTINATION
                            ;;
                        structure)
                            dbBackupBase $db error_only structure $DESTINATION
                            ;;
                    esac
                    ;;
            esac

            fi
        done
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f dbBackupBasesOneUser
#создание бэкапа всех баз данных одного пользователя
###!Полностью готово. Не трогать больше
###input
#$1-user ;
#$2 - full_info/error_only - вывод сообщений о выполнении операции
#$3 - mode - data/structure
#$4 - mode - DeleteBase/NoDeleteBase  - удалить ли базы после создания бэкапов
#$5-В параметре $5 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - ошибка передачи параметра mode: full_info/error_only
#3 - ошибка передачи параметра mode: data|structure
#4 - ошибка передачи параметра mode: DeleteBase/NoDeleteBase
dbBackupBasesOneUser() {
    #Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`

        #Параметры запуска существуют
        case "$3" in
            data|structure)
                case "$4" in
                    DeleteBase|NoDeleteBase)
                        true
                        ;;
                    *)
                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: DeleteBase/NoDeleteBase\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                        return 4
                        ;;
                esac
                ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: data/structure\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                return 3
                ;;
        esac

        case "$2" in
            full_info|error_only)
                true
             ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: full_info/error_only\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                return 2
                ;;
        esac

        #Проверка на существование параметров запуска скрипта
        if [ -n "$5" ]
        then
        #Параметры запуска существуют
            DESTINATION=$5
        #Параметры запуска существуют (конец)
        else
        #Параметры запуска отсутствуют
             DESTINATION=""
        #Параметры запуска отсутствуют (конец)
        fi
        #Конец проверки существования параметров запуска скрипта

        databases=`mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like '$1\_%'" | tr -d "| " | grep -v SCHEMA_NAME`

                        #выгрузка баз данных
                        for db in $databases; do
                        echo $db
                           # if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then

								#извлечение имени владельца
                                dbExtractUser=${db%\_*}
                                #echo $dbExtractUser
                                #основная база и дополнительная
                                dbNameWithDopBase=${db#$dbExtractUser\_}
                                #echo $dbNameWithDopBase
                                #извлечение названия дополнительной базы
                                dbNameDopBase=${dbNameWithDopBase#*--*}
                                #echo $dbNameDopBase
                                #извлечения названия основной базы (домена)
                                dbNameMainBase=${dbNameWithDopBase%--$dbNameDopBase}
                                #echo $dbNameMainBase
                           #  fi

                             case "$2" in
                                full_info)
                                    case "$3" in
                                        data)
                                            dbBackupBase $db full_info data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db full_info structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                                error_only)
                                    case "$2" in
                                        data)
                                            dbBackupBase $db error_only data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db error_only structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                            esac

                            case "$4" in
                                DeleteBase)
                                    dbDropBase $db drop
                                    ;;
                                NoDeleteBase)
                                   true
                                    ;;
                            esac
                        done
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f dbBackupTable
#Создание бэкапа отдельной таблицы
###!Полностью готово. Не трогать больше
###input
#$1-dbname ;
#$2-tablename ;
#$3-path-Путь по желанию ;
###return
#0-выполнено успешно
#1-отсутствуют параметры запуска
#2-нет базы данных
#3-нет таблицы
#4-ошибка проверки после экспорта
dbBackupTable() {

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		d=`date +%Y.%m.%d`;
	    dt=`date +%Y.%m.%d-%H.%M.%S`;
	    #проверка существования базы данных "$1"
	    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
	    	then
	    	#база $1 - существует

	    		#Проверка существования таблицы в базе денных $1
	    		if [[ ! -z "`mysql -qfsBe "SHOW TABLES FROM $1 LIKE '$2'" 2>&1`" ]];
	    			then
	    			#таблица $2 существует

	    				    #Проверка на существование параметров запуска скрипта
	    		if [ -n "$3" ]
	    		then
	    		#Параметры запуска существуют
	    		    DESTINATION=$3
	    		#Параметры запуска существуют (конец)
	    		else

	    		                user1=${1%_*}
								user=${user1%_*}

								#обрезаем пользователя слева
								domain1=${1#${user}_}
								#echo domain1 - $domain1
								#обрезаем дополнительную базу справа
								domain=${domain1%_*}

	    		#Параметры запуска отсутствуют
	    		    DESTINATION=$BACKUPFOLDER_DAYS/$dbExtractUser/$domain/$d
			        mkdir -p $DESTINATION
	    		#Параметры запуска отсутствуют (конец)
	    		fi
	    		#Конец проверки существования параметров запуска скрипта

	    		#пусть к файлу с бэкапом без расширения
        		FILENAME=$DESTINATION/mysqlTable-"$2"."$1"-$datetime
                #FILENAME=$DESTINATION/mysql
                    #Проверка существования каталога "$DESTINATION"
                    if [ -d $DESTINATION ] ; then
                        #Каталог "$DESTINATION" существует
            #            mysql -e "mysqldump -c $1 $2 > $FILENAME.sql;"
            		    mysqldump -c $1 $2 > $FILENAME.sql
                        #tar_file_without_structure_remove
                        tarFile $FILENAME.sql $FILENAME.sql.tar.gz str_rem silent rewrite
                        dbCheckExportedBase $1 error_only $FILENAME.sql.tar.gz
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                        	then
                        		#предыдущая команда завершилась успешно
                        		return 0
                        		#предыдущая команда завершилась успешно (конец)
                        	else
                        		#предыдущая команда завершилась с ошибкой
                        		return 4
                        		#предыдущая команда завершилась с ошибкой (конец)
                        fi
                        #Конец проверки на успешность выполнения предыдущей команды
                        #Каталог "$DESTINATION" существует (конец)
                    else
                        #Каталог "$DESTINATION" не существует
                        echo -e "${COLOR_RED} Каталог ${COLOR_YELLOW}\"$DESTINATION\"${COLOR_NC}${COLOR_RED} не найден. Создать его? Функция ${COLOR_GREEN}\"dbBackupTable\"${COLOR_NC}"
                        echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$DESTINATION\"${COLOR_nC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                        while read
                        do
                        echo -n ": "
                            case "$REPLY" in
                            y|Y)
                                mkdir -p $DESTINATION;
                                mysqldump -c $1 $2 > $FILENAME.sql
                                #tar_file_without_structure_remove $FILENAME.sql $FILENAME.sql.tar.gz
                                tarFile $FILENAME.sql $FILENAME.sql.tar.gz str_rem silent rewrite
                                dbCheckExportedBase $1 error_only $FILENAME.sql.tar.gz
                                    #Проверка на успешность выполнения предыдущей команды
                                    if [ $? -eq 0 ]
                                        then
                                            #предыдущая команда завершилась успешно
                                            return 0
                                            #предыдущая команда завершилась успешно (конец)
                                        else
                                            #предыдущая команда завершилась с ошибкой
                                            return 4
                                            #предыдущая команда завершилась с ошибкой (конец)
                                    fi
                                    #Конец проверки на успешность выполнения предыдущей команды
                                break;;
                            n|N)
                                 break;;
                            esac
                        done
                        #Каталог "$DESTINATION" не существует (конец)
                    fi
                    #Конец проверки существования каталога "$DESTINATION"

	    			#таблица $2 существует (конец)
	    			else
	    			#таблица $2 не существует
	    			    echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupTable\" ${COLOR_NC}"
	    			    return 3
	    			#таблица $2 не существует (конец)
	    		fi
	    		#Проверка существования таблицы в базе денных $1 (конец)





	    	#база $1 - существует (конец)
	    	else
	    	#база $1 - не существует
	    	    echo -e "${COLOR_RED}Ошибка создания бэкапа базы данных ${COLOR_YELLOW}\"$1\"${COLOR_NC}${COLOR_RED}. Указанная база не существует${COLOR_NC}"
	    	    return 2
	    	#база $1 - не существует (конец)
	    fi
	    #конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupTable\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f backupUserSitesFiles
#Создание бэкапов файлов всех сайтов указанного пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 27.03.2019
###input
#$1-username ;
#$2-mode:createDestFolder/querryCreateDestFolder
#$3-path destination
###return
#0 - выполнено успешно,
#1 - нет параметров,
#2 - нет пользователя
backupUserSitesFiles() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				i=1
                #ls -d $HOMEPATHWEBUSERS/$1/$1_* | cut -d'_' -f 2 | while read line >>/dev/null
                ls $HOMEPATHWEBUSERS/$1 | while read line >>/dev/null
                do
                    #Проверка на существование параметров запуска скрипта
                    if [ -n "$3" ]
                    then
                    #Параметры запуска существуют
                        backupSiteFiles $1 $line createDestFolder $3
                    #Параметры запуска существуют (конец)
                    else
                    #Параметры запуска отсутствуют
                        backupSiteFiles $1 $line createDestFolder
                    #Параметры запуска отсутствуют (конец)
                    fi
                    #Конец проверки существования параметров запуска скрипта
                    (( i++ ))
                done

			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"backupUserSitesFiles\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupUserSitesFiles\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f backupSiteWebserverConfig
#создание копии конфигов для вебсервера у сайта
###!Полностью готово. Не трогать больше
###input
#$1-user ;
#$2-domain ;
#$3-mode:full_info/error_only
#$4-path-не обязательный - назначение.
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
#3 - ошибка передачи параметра mode:full_info/error_only
#4 - не выполнена операция
backupSiteWebserverConfig() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
        date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`

        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка на существование параметров запуска скрипта
                if [ -n "$4" ]
                then
                #Параметры запуска существуют
                    DESTINATION=$4
                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют
                    DESTINATION=$BACKUPFOLDER_DAYS/$1/$2/$date
                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта

                FILENAME=wserv.$1==$2__$datetime

                #Проверка существования каталога "$DESTINATION/$1_$2"
                if ! [ -d $DESTINATION/$1_$2 ] ; then
                    #Каталог "$DESTINATION" не существует
                    sudo mkdir -p $DESTINATION/$1_$2
                    #Каталог "$DESTINATION" не существует (конец)
                fi
                #Конец проверки существования каталога "$DESTINATION/$1_$2"


                if [ -f "$NGINXENABLED"/"$1_$2.conf" ] ; then
                    sudo cp -R "$NGINXENABLED"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--ngEnabled"
                fi

                if [ -f "$NGINXAVAILABLE"/"$1_$2.conf" ] ; then
                    sudo cp -R "$NGINXAVAILABLE"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--ngAvailable"
                fi

                if [ -f "$APACHEENABLED"/"$1_$2.conf" ] ; then
                    sudo cp -R "$APACHEENABLED"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--apEnabled"
                fi

                if [ -f "$APACHEAVAILABLE"/"$1_$2.conf" ] ; then
                    sudo cp -R "$APACHEAVAILABLE"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--apAvailable"
                fi

                #Проверка существования системного пользователя "$1"
                	grep "^$1:" /etc/passwd >/dev/null
                	if  [ $? -eq 0 ]
                	then
                	#Пользователь $1 существует
                		chModAndOwnFolderAndFiles "$DESTINATION"/"$1_$2" 644 755 $1 www-data
                	#Пользователь $1 существует (конец)
                	else
                	#Пользователь $1 не существует
                        chModAndOwnFolderAndFiles "$DESTINATION"/"$1_$2" 644 755 $USERLAMER www-data
                	#Пользователь $1 не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $1

                tarFolder $DESTINATION/$1_$2 $DESTINATION/$FILENAME.tar.gz nostr_rem silent rewrite $1 www-data 644

                #Проверка существования файла ""$DESTINATION/$FILENAME.tar.gz""
                if [ -f "$DESTINATION/$FILENAME.tar.gz" ] ; then
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" существует
                    case "$3" in
                        full_info)
                            echo -e "${COLOR_YELLOW}Архивация файлов конфигурации веб-серверов для домена ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} выполнена в архив ${COLOR_GREEN}\"$DESTINATION/$FILENAME.tar.gz\"${COLOR_YELLOW}  ${COLOR_NC}";
                            return 0
                            ;;
                        error_only)
                            return 0
                            ;;
                        *)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_NC}";
                	    ;;
                    esac
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" существует (конец)
                else
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" не существует
                    case "$3" in
                        full_info)
                            echo -e "${COLOR_RED}Архивация файлов конфигурации веб-серверов для домена ${COLOR_YELLOW}\"$2\"${COLOR_RED} не выполнена ${COLOR_NC}";
                            return 4
                            ;;
                        error_only)
                            return 4
                            ;;
                        *)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_NC}";
                	    ;;
                    esac
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" не существует (конец)
                fi
                #Конец проверки существования файла ""$DESTINATION/$FILENAME.tar.gz""




        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1




	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f backupSiteFiles
#Создание бэкапа файлов сайта
###!Полностью готово. Не трогать больше
# Каталог по умолчанию в режиме querryCreateDestFolder при отсутствии папки все равно создается
###input
#$1-user ;
#$2-domain ;
#$3-mode:createDestFolder/querryCreateDestFolder
#$4-path destination; - не обязательно
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#3 - каталог не существует,
#4 - пользователь отменил создание каталога
#5 - ошибка передачи параметра mode:createDestFolder/querryCreateDestFolder
#6 - ошибка при проверке заархивированного файла
backupSiteFiles() {
    date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    #Проверка существования каталога "$HOMEPATHWEBUSERS/$1/$2"
	    if [ -d $HOMEPATHWEBUSERS/$1/$2 ] ; then
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует
            #Проверка на существование параметров запуска скрипта
            if [ -n "$4" ]
            then
            #Параметры запуска существуют
                #Проверка существования каталога "$4"
                if [ -d $4 ] ; then
                    #Каталог "$4" существует
                    DESTINATION=$4
                    #Каталог "$4" существует (конец)
                else
                    case "$3" in
                        createDestFolder)
                            mkdirWithOwn $4 $1 www-data 755;
                            DESTINATION=$4
                            ;;
                        querryCreateDestFolder)
                            echo -n -e "${COLOR_YELLOW}Каталог ${COLOR_GREEN}\"$4\"${COLOR_YELLOW} не существует. Введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW} для создания каталога или для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                    while read
                                    do
                                        case "$REPLY" in
                                            y|Y)
                                                sudo mkdirWithOwn $4 $1 www-data 755;
                                                DESTINATION=$4;
                                                break
                                                ;;
                                            n|N)
                                                return 4
                                                break
                                                ;;
                                            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                               ;;
                                        esac
                                    done
                            ;;
                    	*)
                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode:createDestFolder/querryCreateDestFolder\"${COLOR_RED} в функцию ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_NC}";
                    	    return 5
                    	    ;;
                    esac
                fi
                #Конец проверки существования каталога "$4"

            #Параметры запуска существуют (конец)
            else
            #Параметры запуска отсутствуют
                DESTINATION=$BACKUPFOLDER_DAYS/$1/$2/$date
            #Параметры запуска отсутствуют (конец)
            fi
            #Конец проверки существования параметров запуска скрипта
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует (конец)


	        if ! [ -d $DESTINATION ] ; then
                        #Каталог "$DESTINATION" не существует
                        mkdirWithOwn $DESTINATION $1 www-data 755
                        #Каталог "$DESTINATION" не существует (конец)
            fi

            FILENAME=site.$1==$2__$datetime.tar.gz
            #tar_folder_structure $HOMEPATHWEBUSERS/$1/$2 $DESTINATION/$FILENAME
            tarFolder $HOMEPATHWEBUSERS/$1/$2 $DESTINATION/$FILENAME str silent rewrite $1 www-data 644

            #Проверка существования файла "$DESTINATION/$FILENAME"
            if [ -f $DESTINATION/$FILENAME ] ; then
                #Файл "$DESTINATION/$FILENAME" существует
                return 0
                #Файл "$DESTINATION/$FILENAME" существует (конец)
            else
                #Файл "$DESTINATION/$FILENAME" не существует
                echo -e "${COLOR_RED}Произошла ошибка при создании бэкапа сайта ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2\"${COLOR_RED} в архив ${COLOR_GREEN}\"$DESTINATION/$FILENAME\"${COLOR_NC}"
                return 6

                #Файл "$DESTINATION/$FILENAME" не существует (конец)
            fi
            #Конец проверки существования файла "$DESTINATION/$FILENAME"

	    else
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" не существует
	        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_NC}"
	        return 3
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" не существует (конец)
	    fi
	    #Конец проверки существования каталога "$HOMEPATHWEBUSERS/$1/$2"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f dbCheckExportedBase
#Проверка успешности выгрузки базы данных mysql $1 в архив $3
###!Полностью готово. Не трогать больше
###input
#$1 - Имя базы данных ;
#$2 - Режимы: silent/error_only/full_info  - вывод сообщений о выполнении операции
#$3 - Путь к архиву ;
###return
#0 - файл существует,
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
