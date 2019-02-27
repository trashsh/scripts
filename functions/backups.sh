#!/bin/bash

declare -x -f backupImportantFile #Создание бэкапа в папку BACKUPFOLDER_IMPORTANT: ($1-user ; $2-destination_folder ; $3-архивируемый файл ;)
declare -x -f dbBackupTable #Создание бэкапа отдельной таблицы: ($1-dbname ; $2-tablename ; $3-В параметре $3 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d`)


######ПОЛНОСТЬЮ ПРОТЕСТИРОВАНО
declare -x -f viewBackupsRange          #Вывод бэкапов конкретный день ($1-DATE)
                                        #Проверка на существование параметров запуска скрипта
                                        #return 0 - выполнено успешно, 1 - отсутствуют параметры
                                        #2 - бэкапы за указанный диапазон отсутствуют
declare -x -f viewBackupsToday          #Вывод бэкапов за сегодня
                                        #return 0 - выполнено успешно, 1 - каталог не найден
declare -x -f viewBackupsYestoday       #Вывод бэкапов за вчерашний день
                                        #return 0 - выполнено успешно, 1 - каталог не найден
declare -x -f viewBackupsWeek           #Вывод бэкапов за последнюю неделю
                                        #return 0 - выполнено успешно, 1 - каталог не найден
declare -x -f viewBackupsRangeInput     #Вывод бэкапов за указанный диапазон дат ($1-date1, $2-data2)
                                        #Вывод бэкапов за указанный диапазон дат ($1-date1, $2-data2)
                                        #return 0 - выполнено, 1 - отсутствуют параметры
declare -x -f dbBackupBases             #Создание бэкапа всех пользовательских баз данных mysql:
                                        #$1-user ; $2-В параметре $2 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d ;
                                        #return 0 - выполнено успешно, 1 - не переданы параметры, 2 - пользователь не существует, 3 - пользователь отменил создание папки
declare -x -f dbBackupBasesOneUser #Создание бэкапа все баз данных указанного пользователя mysql:
                                    #return 0 - выполнено успешно, 1 - не переданы параметры, 2 - пользователь не существует, 3 - пользователь отменил создание папки

declare -x -f backupSiteFiles #Создание бэкапа файлов сайта
                                        #$1-user ; $2-domain ; $3-path ;
                                        #return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - каталог не существует,4 - пользователь отменил создание каталога



declare -x -f backupUserSitesFiles #Создание бэкапов файлов всех сайтов указанного пользователя: ($1-username ; $2-path)
#Создание бэкапов файлов всех сайтов указанного пользователя
#return 0 - выполнено успешно, 1 - нет параметров, 2 - нет пользователя
#$1-username ; $2-path
backupUserSitesFiles() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				i=1
                ls -d $HOMEPATHWEBUSERS/$1/$1_* | cut -d'_' -f 2 | while read line >>/dev/null
                do
                    #array[$i]="$line"
                    #temp=$line
                    #echo $line
                    backupSiteFiles $1 $line $2
                    (( i++ ))
                    #backupSiteFiles $1 $line
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


#
#Создание бэкапа в папку BACKUPFOLDER_IMPORTANT
#$1-user ; $2-destination_folder ; $3-архивируемый файл ;
backupImportantFile() {
	dt=`date +%Y.%m.%d_%H.%M.%S`;
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$3"
		if [ -f $3 ] ; then
		    #Файл "$3" существует
		    #Проверка существования каталога "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1"
			if ! [ -d "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1" ] ; then
				mkdir -p $BACKUPFOLDER_IMPORTANT/$2/$1
			fi
			#Проверка существования каталога "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1" (конец)
	        tar_file_structure $3 $BACKUPFOLDER_IMPORTANT/$2/$1/$2_$1_$dt.tar.gz
		    #Файл "$3" существует (конец)
		else
		    #Файл "$3" не существует
		    echo -e "${COLOR_RED} Файл ${COLOR_YELLOW}\"$3\"${COLOR_RED} не существует${COLOR_NC}"
		    #Файл "$3" не существует (конец)
		fi
		#Конец проверки существования файла "$3"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupImportantFile\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

}



#Создание бэкапа отдельной таблицы
#$1-dbname ; $2-tablename ; $3-path-Путь по желанию ; ;
dbBackupTable() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		d=`date +%Y.%m.%d`;
	    dt=`date +%Y.%m.%d_%H.%M`;
	    #проверка существования базы данных "$1"
	    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
	    	then
	    	#база $1 - существует
	    		#Проверка на существование параметров запуска скрипта
	    		if [ -n "$3" ]
	    		then
	    		#Параметры запуска существуют
	    		    DESTINATION=$3
	    		#Параметры запуска существуют (конец)
	    		else
	    		#Параметры запуска отсутствуют
	    		    DESTINATION=$BACKUPFOLDER_DAYS/$d
			        mkdir -p $BACKUPFOLDER_DAYS/$d
	    		#Параметры запуска отсутствуют (конец)
	    		fi
	    		#Конец проверки существования параметров запуска скрипта

	    		#пусть к файлу с бэкапом без расширения
        		FILENAME=$DESTINATION/mysql."$db"-$dt

		#Проверка существования каталога "$DESTINATION"
		if [ -d $DESTINATION ] ; then
		    #Каталог "$DESTINATION" существует
		    mysql -e "mysqldump -c $1 $2 > $FILENAME.sql;"
#		    mysqldump -c $1 $2 > $FILENAME.sql
			tar_file_without_structure_remove $FILENAME.sql $FILENAME.sql.tar.gz
			dbCheckExportedBase $1 $FILENAME.sql.tar.gz
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
					tar_file_without_structure_remove $FILENAME.sql $FILENAME.sql.tar.gz
					dbCheckExportedBase $1 $FILENAME.sql.tar.gz
					break;;
				n|N)
					 break;;
				esac
			done
		    #Каталог "$DESTINATION" не существует (конец)
		fi
		#Конец проверки существования каталога "$DESTINATION"


	    	#база $1 - существует (конец)
	    	else
	    	#база $1 - не существует
	    	    echo -e "${COLOR_RED}Ошибка создания бэкапа базы данных ${COLOR_YELLOW}\"$1\"${COLOR_NC}${COLOR_RED}. Указанная база не существует${COLOR_NC}"
	    	#база $1 - не существует (конец)
	    fi
	    #конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBase\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

}



######ПОЛНОСТЬЮ ПРОТЕСТИРОВАНО

#Вывод бэкапов за сегодня
#return 0 - выполнено успешно, 1 - каталог не найден
viewBackupsToday(){
	echo ""
	DATE=$(date +%Y.%m.%d)
	if [ -d "$BACKUPFOLDER_DAYS"/"$DATE"/"mysql" ] ; then
		echo -e "${COLOR_YELLOW}"Список бэкапов за сегодня - $DATE" ${COLOR_NC}"
		echo -e "${COLOR_BROWN}"$BACKUPFOLDER_DAYS/$DATE/mysql:" ${COLOR_NC}"
		ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
		return 0
	else
		echo -e "${COLOR_RED}Бэкапы mysql за $(date --date today "+%Y.%m.%d") отсутствуют${COLOR_NC}"
		return 1
	fi

}

#Вывод бэкапов за вчерашний день
#return 0 - выполнено успешно, 1 - каталог не найден
viewBackupsYestoday(){
	echo ""
	DATE=$(date --date yesterday "+%Y.%m.%d")
	 if [ -d "$BACKUPFOLDER_DAYS"/"$DATE"/"mysql" ] ; then
		echo -e "${COLOR_YELLOW}"Список бэкапов за сегодня - $DATE" ${COLOR_NC}"
		echo -e "${COLOR_BROWN}"$BACKUPFOLDER_DAYS/$DATE/mysql:" ${COLOR_NC}"
		ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
		return 0
	else
		echo -e "${COLOR_RED}Бэкапы mysql за $(date --date yesterday "+%Y.%m.%d") отсутствуют${COLOR_NC}"
		return 1
	fi
}

#Вывод бэкапов за последнюю неделю
#return 0 - выполнено успешно, 1 - каталог не найден
viewBackupsWeek(){
	echo ""
	TODAY=$(date +%Y.%m.%d)
	DATE=$(date --date='7 days ago' "+%Y.%m.%d")
	echo -e "${COLOR_YELLOW}"Список бэкапов за Неделю - $DATE-$TODAY" ${COLOR_NC}"

	for ((i=0; i<7; i++))
	do
		DATE=$(date --date=''$i' days ago' "+%Y.%m.%d");
		if [ -d "$BACKUPFOLDER_DAYS"/"$DATE" ] ; then
			echo -e "$COLOR_BROWN"$DATE:" ${COLOR_NC}"
			ls -l $BACKUPFOLDER_DAYS/$DATE/
			return 0
		else
		    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$BACKUPFOLDER_DAYS/$DATE/\"${COLOR_RED}не найден${COLOR_NC}"
		    return 1
		fi
	done
}


#Вывод бэкапов за указанный диапазон дат ($1-date1, $2-data2)
#return 0 - выполнено, 1 - отсутствуют параметры
viewBackupsRangeInput(){
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ]
    then
    #Параметры запуска существуют
        echo -e "${COLOR_YELLOW}"Список бэкапов $(date --date $1 "+%Y.%m.%d") - $(date --date $2 "+%Y.%m.%d")" ${COLOR_NC}"
        start_ts=$(date -d "$1" '+%s')
        end_ts=$(date -d "$2" '+%s')
        range=$(( ( end_ts - start_ts )/(60*60*24) ))
        echo -e "$COLOR_BROWN" Базы данных mysql:" ${COLOR_NC}"
        n=0
        for ((i=0; i<${range#-}+1; i++))
        do
            DATE=$(date --date=''$i' days ago' "+%Y.%m.%d");
            if [ -d "$BACKUPFOLDER_DAYS"/"$DATE" ] ; then
                echo -e "$COLOR_BROWN"$DATE:" ${COLOR_NC}"
                ls -l $BACKUPFOLDER_DAYS/$DATE/
                n=$(($n+1))

            fi

        done
        echo $n
        return 0
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewBackupsRangeInput\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта

}

#Вывод бэкапов конкретный день ($1-DATE)
viewBackupsRange(){
#Проверка на существование параметров запуска скрипта
#return 0 - выполнено успешно, 1 - отсутствуют параметры
#2 - бэкапы за указанный диапазон отсутствуют
if [ -n "$1" ]
then
#Параметры запуска существуют
    echo ''
    if [ -d "$BACKUPFOLDER_DAYS"/"$1"/ ] ; then
        echo -e "${COLOR_YELLOW}"Список бэкапов $(date --date $1 "+%Y.%m.%d")" ${COLOR_NC}"
        echo -e "$COLOR_BROWN"$1 - Базы данных mysql:" ${COLOR_NC}"
        ls -l $BACKUPFOLDER_DAYS/$1/
        return 0
    else
        echo -e "${COLOR_RED}Бэкапы за $(date --date $1 "+%Y.%m.%d") отсутствуют${COLOR_NC}"
        return 2
    fi
#Параметры запуска существуют (конец)
else
#Параметры запуска отсутствуют
    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewBackupsRange\"${COLOR_RED} ${COLOR_NC}"
    return 1
#Параметры запуска отсутствуют (конец)
fi
#Конец проверки существования параметров запуска скрипта
}

#Создание бэкапа всех пользовательских баз данных mysql
#$1-В параметре может быть указан путь к каталогу сохранения бэкапов.Если путь не указан, то выгрузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;
#return - 0 - выполнено успешно;
dbBackupBases() {
	d=`date +%Y.%m.%d`;
	dt=`date +%Y.%m.%d_%H.%M`;

	databases=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`



#выгрузка баз данных
	for db in $databases; do
		if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then
			echo -e "---\nВыгрузка базы данных MYSQL: ${COLOR_YELLOW}$db${COLOR_NC}"

            user_fcut=${db%_*}
            user=${user_fcut%_*}

echo $db

            domain_fcut=${db%_}
            #domain=${domain_fcut##_*}


            echo $domain_fcut


            #Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

	    #Проверка существования файла "$1"
	    if ! [ -d $1 ] ; then
	        #Файл "$1" не существует
	        echo -e "${COLOR_RED} Каталог \"$1\" не найден для создания бэкапа всех баз данных mysql. Создать его? Функция ${COLOR_GREEN}\"dbBackupBases\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$1\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p "$1";
				DESTINATION=$1
				echo $DESTINATION
					break;;
				n|N)
					 break;;
				esac
			done
	        #Файл "$1" не существует (конец)
	    else
	        #Файл "$1" существует
			DESTINATION=$1
	        #Файл "$1" существует (конец)
	    fi
	    #Конец проверки существования файла "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		#каталог устанавливается по умолчанию
		DESTINATION=$BACKUPFOLDER_DAYS/$user/$domain/$d
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта


     #Проверка существования каталога "$DESTINATION"
    if ! [ -d $DESTINATION ] ; then
        #Каталог "$DESTINATION" не существует
        mkdir -p "$DESTINATION"
    fi
    #Конец проверки существования каталога "$DESTINATION"












#            echo $user
           # echo $user
			filename=mysql.$user-"$db"-$dt.sql
			mysqldump --databases $db > $DESTINATION/$filename
#архивация выгруженной базы и удаление оригинального файла sql
			tar_file_without_structure_remove	$DESTINATION/$filename $DESTINATION/$filename.tar.gz
#проверка на существование выгруженных и заархививанных баз данных
            chModAndOwnFile $DESTINATION/$filename.tar.gz $user www-data 644
			if  [ -f "$DESTINATION/$filename.tar.gz" ] ; then
				echo -e "${COLOR_GREEN}Выгрузка базы данных MYSQL:${COLOR_NC} ${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_GREEN}успешно завершилась в файл${COLOR_NC}${COLOR_YELLOW} \"$DESTINATION/$filename.tar.gz\"${COLOR_NC}\n---"
			else
				echo -e "${COLOR_RED}Выгрузка базы данных: ${COLOR_NC}${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_RED}завершилась с ошибкой${COLOR_NC}\n---"
			fi
	    fi
    done
    return 0
}

#
#Создание бэкапа все баз данных указанного пользователя mysql
#$1-user ; $2-В параметре $2 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d ;
#return 0 - выполнено успешно, 1 - не переданы параметры, 2 - пользователь не существует, 3 - пользователь отменил создание папки
dbBackupBasesOneUser() {
    #Проверка на существование параметров запуска скрипта
    d=`date +%Y.%m.%d`;
    dt=`date +%Y.%m.%d_%H.%M`;

    if [ -n "$1" ]
    then
    #Параметры запуска существуют
        #Проверка на существование пользователя mysql "$1"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
        then
        #Пользователь mysql "$1" существует

                #Проверка на существование параметров запуска скрипта
                if [ -n "$2" ]
                then
                #Параметры запуска существуют
                    if ! [ -d $2 ] ; then
                        #каталог "$2" не существует
                        echo -e "${COLOR_RED} Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не найден. Создать его? Функция ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}"
                        echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$2\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                        while read
                        do
                        echo -n ": "
                            case "$REPLY" in
                            y|Y)
                                mkdir -p "$2";
                                DESTINATION=$2
                                #echo $DESTINATION
                                break;;
                            n|N)
                                 return 3;;
                            esac
                        done
                        #каталог "$2" не существует (конец)
                    else
                    #каталог "$2" существует
                    DESTINATION=$2
                    #Файл "$2" существует (конец)
                    fi
                    #Конец проверки существования каталога "$2"


                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют
                    DESTINATION=$BACKUPFOLDER_DAYS/$1/
                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта

                #Проверка существования каталога "$DESTINATION"
                if ! [ -d $DESTINATION ] ; then
                    #Каталог "$DESTINATION" не существует
                    mkdir -p "$DESTINATION"
                fi
                #Конец проверки существования каталога "$DESTINATION"



                databases=`mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like '$1_%'" | tr -d "| " | grep -v SCHEMA_NAME`

                #выгрузка баз данных
                    for db in $databases; do
                        if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then
                        dbase=$db | cut -d'_' -f 2
     #                   echo $dbase
                        dbBackupBase $1 $db $DESTINATION
    #
    #
    #                        echo -e "---\nВыгрузка базы данных MYSQL: ${COLOR_YELLOW}$db${COLOR_NC}"
    #                         filename=mysql."$1"-"$db"-$dt.sql
    #                        mysqldump --databases $db > $DESTINATION/$filename
                #архивация выгруженной базы и удаление оригинального файла sql
    #                        tar_file_without_structure_remove	$DESTINATION/$filename $DESTINATION/$filename.tar.gz
                #проверка на существование выгруженных и заархививанных баз данных
    #                        if  [ -f "$DESTINATION/$filename.tar.gz" ] ; then
    #                            echo -e "${COLOR_GREEN}Выгрузка базы данных MYSQL:${COLOR_NC} ${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_GREEN}успешно завершилась в файл${COLOR_NC}${COLOR_YELLOW} \"$DESTINATION/$filename.tar.gz\"${COLOR_NC}\n---"
    #                        else
    #                            echo -e "${COLOR_RED}Выгрузка базы данных: ${COLOR_NC}${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_RED}завершилась с ошибкой${COLOR_NC}\n---"
    #                        fi
                         fi
                    done


        #Пользователь mysql "$1" существует (конец)
        else
        #Пользователь mysql "$1" не существует
            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует ${COLOR_NC}"
            return 2
        #Пользователь mysql "$1" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$1"
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}


#Создание бэкапа файлов сайта
#$1-user ; $2-domain ; $3-path ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - каталог не существует,4 - пользователь отменил создание каталога
backupSiteFiles() {
    d=`date +%Y.%m.%d`;
	dt=`date +%Y.%m.%d_%H.%M.%S`;
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
	    #Проверка существования системного пользователя "$1"
	    	grep "^$1:" /etc/passwd >/dev/null
	    	if  [ $? -eq 0 ]
	    	then
	    	#Пользователь $1 существует
                #Проверка существования каталога "$HOMEPATHWEBUSERS/$1/$1_$2"
                if [ -d $HOMEPATHWEBUSERS/$1/$1_$2 ] ; then
                    #Каталог "$HOMEPATHWEBUSERS/$1/$1_$2" существует    
                    #Проверка на существование параметров запуска скрипта
                    if [ -n "$3" ]
                    then
                    #Параметры запуска существуют
                        #Проверка существования каталога "$3"
                        if [ -d $3 ] ; then
                            #Каталог "$3" существует
                            DESTINATION=$3
                            #Каталог "$3" существует (конец)
                        else
                            #Каталог "$3" не существует
                            echo -n -e "${COLOR_YELLOW}Каталог ${COLOR_GREEN}\"$3\"${COLOR_YELLOW} не существует. Введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW} для создания каталога или для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                while read
                                do
                                    case "$REPLY" in
                                        y|Y)
                                            mkdir -p "$3";
                                            DESTINATION=$3;
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

                            #Каталог "$3" не существует (конец)
                        fi
                        #Конец проверки существования каталога "$3"

                    #Параметры запуска существуют (конец)
                    else
                    #Параметры запуска отсутствуют
                        DESTINATION=$BACKUPFOLDER_DAYS/$1/$2/$d/
                    #Параметры запуска отсутствуют (конец)
                    fi
                    #Конец проверки существования параметров запуска скрипта
                    #Каталог "$HOMEPATHWEBUSERS/$1/$1_$2" существует (конец)
                else
                    #Каталог "$HOMEPATHWEBUSERS/$1/$1_$2" не существует   
                    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$1_$2\"${COLOR_RED} не существует${COLOR_NC}"
                    return 3
                    #Каталог "$HOMEPATHWEBUSERS/$1/$1_$2" не существует (конец)
                fi
                #Конец проверки существования каталога "$HOMEPATHWEBUSERS/$1/$1_$2"

                if ! [ -d $DESTINATION ] ; then
                        #Каталог "$DESTINATION" не существует
                        mkdir -p "$DESTINATION"
                        #Каталог "$DESTINATION" не существует (конец)
                fi

                FILENAME=site.$1_$2_$dt.tar.gz
                tar_folder_structure $HOMEPATHWEBUSERS/$1/$1_$2 $DESTINATION/$FILENAME
                chModAndOwnFile $DESTINATION/$FILENAME $1 users 644

                #Проверка существования файла "$DESTINATION/$FILENAME"
                if [ -f $DESTINATION/$FILENAME ] ; then
                    #Файл "$DESTINATION/$FILENAME" существует
                    return 0
                    #Файл "$DESTINATION/$FILENAME" существует (конец)
                else
                    #Файл "$DESTINATION/$FILENAME" не существует
                    echo -e "${COLOR_RED}Произошла ошибка при создании бэкапа сайта ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$1_$2\"${COLOR_RED} в архив ${COLOR_GREEN}\"$DESTINATION/$FILENAME\"${COLOR_NC}"
                    #Файл "$DESTINATION/$FILENAME" не существует (конец)
                fi
                #Конец проверки существования файла "$DESTINATION/$FILENAME"

	    	#Пользователь $1 существует (конец)
	    	else
	    	#Пользователь $1 не существует
                echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка в функции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_RED}  ${COLOR_NC}"
                return 2

	    	#Пользователь $1 не существует (конец)
	    	fi
	    #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
