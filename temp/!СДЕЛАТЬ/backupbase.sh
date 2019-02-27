#!/bin/bash
source $SCRIPTS/include/include.sh




#Проверка на существование параметров запуска скрипта
#	d=`date +%Y.%m.%d`;
#	dt=`date +%Y.%m.%d_%H.%M.%S`;
    d=$DATEFORMAT
    dt=$DATETIMEFORMAT
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		    #проверка существования базы данных "$2"
	    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$2'" 2>&1`" ]];
	    	then
	    	#база $2 - существует
	    	    #извлекае
	    	    # м название домена из на
	    	    # звания базы
	    	    domain_fcut=${2#$1_}
	    	    domain_cut=${domain_fcut%_*}
	    		#Проверка на существование параметров запуска скрипта
	    		if [ -n "$4" ]
	    		then
	    		#Параметры запуска существуют
	    		    DESTINATION=$4
	    		#Параметры запуска существуют (конец)
	    		else
	    		#Параметры запуска отсутствуют
	    		    DESTINATION=$BACKUPFOLDER_DAYS/$1/$domain_cut/$d
			        mkdir -p $DESTINATION
	    		#Параметры запуска отсутствуют (конец)
	    		fi
	    		#Конец проверки существования параметров запуска скрипта


	    		#пусть к файлу с бэкапом без расширения
        		FILENAME=$DESTINATION/sql.$1-"$2"-$dt.sql

		#Проверка существования каталога "$DESTINATION"
		if [ -d $DESTINATION ] ; then
		    #Каталог "$DESTINATION" существует
		    mysqldump --databases $2 > $FILENAME
			tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz
			dbCheckExportedBase $2 error_only $FILENAME.tar.gz
			chModAndOwnFile $FILENAME.tar.gz $1 www-data 644
		    #Каталог "$DESTINATION" существует (конец)
		else
		    #Каталог "$DESTINATION" не существует

		    #Проверка на существование параметров запуска скрипта
		    if [ $3 = normal ]
		    then
		    #Параметры запуска существуют

		            echo -e "${COLOR_RED} Каталог ${COLOR_YELLOW}\"$DESTINATION\"${COLOR_NC}${COLOR_RED} не найден. Создать его? Функция ${COLOR_GREEN}\"dbBackupBase\".${COLOR_NC}"
                    echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$DESTINATION\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                    while read
                    do
                    echo -n ": "
                        case "$REPLY" in
                        y|Y)
                            mkdir -p $DESTINATION;
                            mysqldump --databases $2 > $FILENAME
                            tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz
                            dbCheckExportedBase $2 error_only $FILENAME.tar.gz
                            break;;
                        n|N)
                             return 3;;
                        esac
                    done


		    #Параметры запуска существуют (конец)
		    else
		    #Параметры запуска отсутствуют
                if [ $3 = silent ]; then

                        mkdir -p $DESTINATION;
                        mysqldump --databases $2 > $FILENAME
                        tar_file_without_structure_remove $FILENAME $FILENAME.tar.gz
                        dbCheckExportedBase $2 error_only $FILENAME.tar.gz
                        break

                else
                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"normal/silent\"${COLOR_RED} в функции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}"
                    return 5
                fi
		    #Параметры запуска отсутствуют (конец)
		    fi
		    #Конец проверки существования параметров запуска скрипта

		fi
		#Конец проверки существования каталога "$DESTINATION"

        #Проверка существования файла "$FILENAME.tar.gz"
        if [ -f $FILENAME.tar.gz ] ; then
            #Файл "$FILENAME.tar.gz" существует
            return 0
            #Файл "$FILENAME.tar.gz" существует (конец)
        else
            #Файл "$FILENAME.tar.gz" не существует
            echo -e "${COLOR_RED}Произошла ошибка при создании бэкапа базы данных ${COLOR_GREEN}\"$2\"${COLOR_RED} в файл ${COLOR_GREEN}\"$FILENAME.tar.gz\"${COLOR_RED}  ${COLOR_NC}"
            return 4
            #Файл "$FILENAME.tar.gz" не существует (конец)
        fi
        #Конец проверки существования файла "$FILENAME.tar.gz"

	    	#база $2 - существует (конец)
	    	else
	    	#база $2 - не существует
	    	    echo -e "${COLOR_RED}Ошибка создания бэкапа базы данных ${COLOR_YELLOW}\"$2\"${COLOR_NC}${COLOR_RED}. Указанная база не существует${COLOR_NC}"
	    	    return 2
	    	#база $2 - не существует (конец)
	    fi
	    #конец проверки существования базы данных $2

        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}"
                return 5
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
