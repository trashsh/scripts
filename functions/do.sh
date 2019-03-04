#!/bin/bash

############################backups######################
declare -x -f dbBackupBase #Создание бэкапа указанной базы данных

############################users########################
declare -x -f userAddSystem
############################ssh########################
declare -x -f sshKeyGenerateToUser
declare -x -f sshKeyAddToUser

############################archive########################

declare -x -f tarFile ##архивация файла ($1-путь к исходному файлу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
declare -x -f tarFolder ##архивация каталога ($1-путь к исходному каталогу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
declare -x -f untarFile #разархивация архива по указанному пути: ($1-ссылка на архив ; $2-ссылка на каталог назначения ; $3-mode:rewrite/norewrite ; $4-mode: showinfo/silent; $5 - mode:createfolder/nocreatefolder/querrycreatefolder)



############################backups######################
#Полностью готово
#Создание бэкапа указанной базы данных
#$1-user,
#$2-dbname ;
#$3 - full_info/error_only - вывод сообщений о выполнении операции
#$4 - mode - data/structure
#$5-В параметре $5 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;

#return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - отсутствует база данных,
#3 - отменено пользователем создание каталога
#4 - ошибка при финальной проверке создания бэкапа,
#5 - ошибка передачи параметра mode: full_info/error_only,
#6 - не существует пользователь
#7 - не передан параметр mode: data/structure
dbBackupBase() {
	#	d=`date +%Y.%m.%d`;
    #	dt=`date +%Y.%m.%d_%H.%M.%S`;
    date=$DATEFORMAT
    datetime=$DATETIMEFORMAT

    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
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
                        if [ -n "$5" ]
                        then
                        #Параметры запуска существуют
                            DESTINATIONFOLDER=$5
                        #Параметры запуска существуют (конец)
                        else
                        #Параметры запуска отсутствуют
                            DESTINATIONFOLDER=$BACKUPFOLDER_DAYS/$1/$sitedomain_trim_dbname/$date
                        #Параметры запуска отсутствуют (конец)
                        fi
                        #Конец проверки существования параметров запуска скрипта

                        #пусть к файлу с бэкапом без расширения
                        FILENAME=$DESTINATIONFOLDER/sql.$1-"$2"-$datetime

                        #Проверка существования каталога "$DESTINATIONFOLDER"
                        if [ -d $DESTINATIONFOLDER ] ; then

                            #Каталог "$DESTINATIONFOLDER" существует
                            case "$3" in
                                error_only)
                                    #параметр 4 - выгрузка базы с данными или только структуры
                                    case "$4" in
                                        data)
                                            mysqldump --databases $2 > $FILENAME.sql;
                                            tarFile $FILENAME.sql $FILENAME.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                            chModAndOwnFile $FILENAME.sql.tar.gz $1 www-data 644;
                                            dbCheckExportedBase $2 error_only $FILENAME.sql.tar.gz;
                                            return 0
                                            ;;
                                        structure)
                                            mysqldump --databases $2 > ${FILENAME}_structure.sql;
                                            mysqldump --databases $2  --no-data > ${FILENAME}_structure.sql;
                                            #mysqldump database_name  --no-data;
                                            tarFile ${FILENAME}_structure.sql ${FILENAME}_structure.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                            chModAndOwnFile ${FILENAME}_structure.sql.tar.gz $1 www-data 644;
                                            dbCheckExportedBase $2 error_only ${FILENAME}_structure.sql.tar.gz;
                                            return 0
                                            ;;
                                    	*)
                                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: (date/structure)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    	    return 7
                                    	    ;;
                                    esac
                                    #параметр 4 - выгрузка базы с данными или только структуры (конец)
                                    ;;
                                full_info)
                                    #параметр 4 - выгрузка базы с данными или только структуры
                                    case "$4" in
                                        data)
                                            mysqldump --databases $2 > $FILENAME.sql;
                                            tarFile $FILENAME.sql $FILENAME.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                            chModAndOwnFile $FILENAME.sql.tar.gz $1 www-data 644;
                                            dbCheckExportedBase $2 full_info $FILENAME.sql.tar.gz;
                                            return 0
                                            ;;
                                        structure)
                                            mysqldump --databases $2  --no-data > ${FILENAME}_structure.sql;
                                            #mysqldump database_name  --no-data;
                                            tarFile ${FILENAME}_structure.sql ${FILENAME}_structure.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                            chModAndOwnFile ${FILENAME}_structure.sql.tar.gz $1 www-data 644;
                                            dbCheckExportedBase $2 full_info ${FILENAME}_structure.sql.tar.gz;
                                            return 0
                                            ;;
                                    	*)
                                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: (date/structure)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    	    return 7
                                    	    ;;
                                    esac
                                    #параметр 4 - выгрузка базы с данными или только структуры (конец)
                                    ;;
                                *)
                                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\" (error_only/full_info)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    return 6
                                    ;;
                            esac
                            #Каталог "$DESTINATIONFOLDER" существует (конец)

                        else
                            #Каталог "$DESTINATIONFOLDER" не существует
                            case "$3" in
                                error_only)
                                    #параметр 4 - выгрузка базы с данными или только структуры
                                    case "$4" in
                                        data)
                                            #mkdir -p $DESTINATIONFOLDER;
                                            mkdirWithOwn $DESTINATIONFOLDER $1 www-data 755;
                                            chown $1:www-data $BACKUPFOLDER_DAYS/$1/ -R;
                                            mysqldump --databases $2 > $FILENAME.sql;
                                            tarFile $FILENAME.sql $FILENAME.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                            dbCheckExportedBase $2 error_only $FILENAME.sql.tar.gz;
                                            chModAndOwnFile $FILENAME.sql.tar.gz $1 www-data 644;
                                            return 0
                                            ;;
                                        structure)
                                            #mkdir -p $DESTINATIONFOLDER;
                                            mkdirWithOwn $DESTINATIONFOLDER $1 www-data 755;
                                            chown $1:www-data $BACKUPFOLDER_DAYS/$1/ -R;
                                            mysqldump --databases $2 --no-data > ${FILENAME}_structure.sql;
                                            #mysqldump database_name --no-data;
                                            tarFile ${FILENAME}_structure.sql ${FILENAME}_structure.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                            dbCheckExportedBase $2 error_only ${FILENAME}_structure.sql.tar.gz;
                                            chModAndOwnFile ${FILENAME}_structure.sql.tar.gz $1 www-data 644;
                                            return 0
                                            ;;
                                    	*)
                                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: (date/structure)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    	    return 7
                                    	    ;;
                                    esac
                                    #параметр 4 - выгрузка базы с данными или только структуры (конец)
                                    ;;
                                full_info)
                                    #параметр 4 - выгрузка базы с данными или только структуры
                                    case "$4" in
                                        data)
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
                                                    mysqldump --databases $2 > $FILENAME.sql;
                                                    tarFile $FILENAME.sql $FILENAME.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                                    dbCheckExportedBase $2 full_info $FILENAME.sql.tar.gz;
                                                    chModAndOwnFile $FILENAME.sql.tar.gz $1 www-data 644
                                                    return 0;
                                                    break;;
                                                n|N)
                                                    echo -e "${COLOR_RED}Операция по созданию базы данных ${COLOR_GREEN}\"$2\"${COLOR_RED} отменена пользователем.${COLOR_NC}"
                                                    return 3;;
                                                esac
                                            done
                                            ;;
                                        structure)
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
                                                    mysqldump --databases $2 --no-data > ${FILENAME}_structure.sql;
                                                    #mysqldump database_name --no-data
                                                    tarFile ${FILENAME}_structure.sql ${FILENAME}_structure.sql.tar.gz nostr_rem silent rewrite $1 www-data 644;
                                                    dbCheckExportedBase $2 full_info ${FILENAME}_structure.sql.tar.gz;
                                                    chModAndOwnFile ${FILENAME}_structure.sql.tar.gz $1 www-data 644
                                                    return 0;
                                                    break;;
                                                n|N)
                                                    echo -e "${COLOR_RED}Операция по созданию базы данных ${COLOR_GREEN}\"$2\"${COLOR_RED} отменена пользователем.${COLOR_NC}"
                                                    return 3;;
                                                esac
                                            done
                                            ;;
                                    	*)
                                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: (date/structure)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
                                    	    return 7
                                    	    ;;
                                    esac
                                    #параметр 4 - выгрузка базы с данными или только структуры (конец)
                                    ;;
                                *)
                                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (full_info/error_only)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBase\"${COLOR_NC}";
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

############################users########################
#Выполенние операций по созданию системного пользователя
#$1-username ; $2-homedir ; $3-путь к интерпритатору команд ; $4 - основная группа пользователей; $5 - type (ssh/ftp), $6 - password, $7 системный пользователь, который выполняет команду
#return 1 - отпутствуют параметры, 2 -пользователь существует, 3 - каталог пользователя уже существует
#4 - интерпритатор не существует, 5 - группа не существует,6 - ошибка передачи параметра type
#7 - не существует системный пользователь, от которого запускается скрипт
userAddSystem()
{
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ] && [ -n "$7" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует
			echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Операция прервана. Функция ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_RED}  ${COLOR_NC}"
			return 2
		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    #Проверка существования каталога "$2"
		    if [ -d $2 ] ; then
		        #Каталог "$2" существует
		        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует. Операция прервана. Функция ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_RED}  ${COLOR_NC}"
		        return 3
		        #Каталог "$2" существует (конец)
		    else
		        #Каталог "$2" не существует
		        #Проверка существования интерпритатора "$3"
		        if [ -f $3 ] ; then
		            #интерпритатор "$3" существует
		            #Проверка существования системного пользователя "$7"
		            	grep "^$7:" /etc/passwd >/dev/null
		            	if  [ $? -eq 0 ]
		            	then
		            	#Пользователь $7 существует

                            #Проверка существования системной группы пользователей "$4"
                            if grep -q $4 /etc/group
                                then
                                    #Группа "$4" существует
                                     case "$5" in
                                         ssh|ftp)
                                         mkdir $2
                                         useradd -N -g $4 -d $2/$1 -s $3 $1
                                         chown $1:$4 $2
                                         chmod 777 $2

                                         echo "$1:$6" | chpasswd

                                        mkdirWithOwn $2/.backups $1 $4 777
                                        mkdirWithOwn $2/.backups/auto $1 $4 755
                                        mkdirWithOwn $2/.backups/manually $1 $4 755


                                        #mysql-добавление информации о пользователе
                                        dt=$DATETIMESQLFORMAT
                                        dbAddRecordToDb $WEBSERVER_DB users username $1 insert
                                        dbUpdateRecordToDb $WEBSERVER_DB users username $1 homedir $2 update
                                        dbUpdateRecordToDb $WEBSERVER_DB users username $1 created "$dt" update
                                        dbUpdateRecordToDb $WEBSERVER_DB users username $1 created_by "$7" update
                                        dbUpdateRecordToDb $WEBSERVER_DB users username $1 isAdminAccess 0 update


                                            case "$5" in
                                                ssh)
                                                    touchFileWithModAndOwn $2/.bashrc $1 $4 644
                                                    touchFileWithModAndOwn $2/.sudo_as_admin_successful $1 $4 644
                                                    echo "source /etc/profile" >> $2/.bashrc
                                                    sed -i '$ a source $SCRIPTS/include/include.sh'  $2/.bashrc
                                                   # sed -i '$ a $SCRIPTS/menu'  $2/.bashrc
                                                    ;;
                                                ftp)
                                                    echo "ftp"
                                                    ;;
                                            esac
                                             ;;
                                        *)
                                            echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"type\"${COLOR_RED} в функцию ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_NC}";
                                            return 6
                                            ;;
                                     esac
                                    #Группа "$4" существует (конец)

                                    viewUserFullInfo $1
                                else
                                    #Группа "$4" не существует
                                    echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_NC}"
                                    return 5
                                    #Группа "$4" не существует (конец)
                                fi
                            #Конец проверки существования системного пользователя $4

		            	#Пользователь $7 существует (конец)
		            	else
		            	#Пользователь $7 не существует
		            	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$7\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_NC}"
		            		return 7
		            	#Пользователь $7 не существует (конец)
		            	fi
		            #Конец проверки существования системного пользователя $7
		            #интерпритатор "$3" существует (конец)
		        else
		            #интерпритатор "$3" не существует
		            echo -e "${COLOR_RED}Интерпритатор ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_NC}"
		            return 4
		            #интерпритатор "$3" не существует (конец)
		        fi
		        #Конец проверки существования интерпритатора "$3"


		        #Каталог "$2" не существует (конец)
		    fi
		    #Конец проверки существования каталога "$2"


		#Пользователь $1 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $1



	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userAddSystem_do\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


############################ssh########################
#Генерация ssh-ключа для пользователя
#$1-user ; $2 - домашний каталог пользователя
#return 0 - выполнено без ошибок, 1 - отсутствуют параметры запуска
#2 - нет указанного пользователя
sshKeyGenerateToUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует

                        DATE=`date '+%Y-%m-%d__%H-%M-%S'`
                        DATE_TYPE2=$DATETIMESQLFORMAT
                    #Проверка существования каталога "$2/.ssh"
                        if [ -d $2/.ssh ] ; then
                            #Каталог "$2/.ssh" существует
                            tar_folder_structure $2/.ssh/ $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_backuped_$DATE.tar.gz
                            #Каталог "$2/.ssh" существует (конец)
                        fi
                    #Конец проверки существования каталога "$2/.ssh"
                        #mkdir -p $2/.ssh
                        mkdirWithOwn $2/.ssh $1 users 766
                        cd $2/.ssh
                        echo -e "\n${COLOR_YELLOW} Генерация ключа. Сейчас необходимо будет установить пароль на ключевой файл.Минимум - 5 символов${COLOR_NC}"
                        ssh-keygen -t rsa -f ssh_$1 -C "ssh_$1 ($DATE_TYPE2)"
                        #echo -e "\n${COLOR_YELLOW} Конвертация ключа в формат программы Putty. Необходимо ввести пароль на ключевой файл, установленный на предыдушем шаге ${COLOR_NC}"
                        sudo puttygen $2/.ssh/ssh_$1 -C "ssh_$1 ($DATE_TYPE2)" -o $2/.ssh/ssh_$1.ppk
                        mkdirWithOwn $BACKUPFOLDER_IMPORTANT/ssh/$1 $1 users 766
                        cat $2/.ssh/ssh_$1.pub >> $2/.ssh/authorized_keys
                        tar_folder_structure $2/.ssh/ $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_generated_$DATE.tar.gz
                        chModAndOwnFile $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_generated_$DATE.tar.gz $1 users 644

                        #chModAndOwnFolderAndFiles $2/.ssh 700 600 $1 users
                        usermod -G ssh-access -a $1
                        return 0

		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyGenerateToUser\"${COLOR_NC}"
			return 2
		#Пользователь $1 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshKeyGenerateToUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Добавление существующего ключа $2 пользователю $1
#$1-user ; 2 - group; $3 - путь к ключу ; $4 - домашний каталог пользователя
#return 1 - отсутствуют параметры,2 - пользователь не существует, 3 - группа не существует
#4 - ключ не найден, 5 - каталог не найден, $6 - не выполнена финальная провека существования файла $4/.ssh/authorized_keys
sshKeyAddToUser()
{
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
    then
    #Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка существования системной группы пользователей "$2"
        		if grep -q $2 /etc/group
        		    then
        		        #Группа "$2" существует
                        #Проверка существования файла "$3"
                        if [ -f $3 ] ; then
                            #Файл "$3" существует
                            #Проверка существования каталога "$4"
                            if [ -d $4 ] ; then
                                #Каталог "$4" существует
                                 mkdirWithOwn $4/.ssh $1 $2 755
                                 DATE=`date '+%Y-%m-%d__%H-%M-%S'`
                                 mkdirWithOwn $BACKUPFOLDER_IMPORTANT/ssh/$1 $1 $2 755
                                 cat $3 >> $4/.ssh/authorized_keys
                                 echo "" >> $4/.ssh/authorized_keys
                                 tar_file_structure $4/.ssh/authorized_keys $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz
                                 chModAndOwnFile $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz $1 $2 644
                                 chModAndOwnFile $4/.ssh/authorized_keys $1 $2 600
                                 chown $1:$2 $4/.ssh
                                 usermod -G ssh-access -a $1


                                 #финальная проверка импорта ключа
                                 #Проверка существования файла "$4/.ssh/authorized_keys"
                                 if [ -f $4/.ssh/authorized_keys ] ; then
                                     #Файл "$4/.ssh/authorized_keys" существует
                                     echo -e "\n${COLOR_YELLOW} Импорт ключа ${COLOR_LIGHT_PURPLE}\"$3\"${COLOR_YELLOW} пользователю ${COLOR_LIGHT_PURPLE}\"$1\"${COLOR_YELLOW} выполнен${COLOR_NC}"
                                     return 0
                                     #Файл "$4/.ssh/authorized_keys" существует (конец)
                                 else
                                     #Файл "$4/.ssh/authorized_keys" не существует
                                     echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$4/.ssh/authorized_keys\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                                     return 6
                                     #Файл "$4/.ssh/authorized_keys" не существует (конец)
                                 fi
                                 #Конец проверки существования файла "$4/.ssh/authorized_keys"

                                 #финальная проверка импорта ключа (конец)
                                #Каталог "$4" существует (конец)
                            else
                                #Каталог "$4" не существует
                                echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                                return 5
                                #Каталог "$4" не существует (конец)
                            fi
                            #Конец проверки существования каталога "$4"

                            #Файл "$3" существует (конец)
                        else
                            #Файл "$3" не существует
                            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                            return 4
                            #Файл "$3" не существует (конец)
                        fi
                        #Конец проверки существования файла "$3"

        		        #Группа "$2" существует (конец)
        		    else
        		        #Группа "$2" не существует
        		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
        				return 3
        				#Группа "$2" не существует (конец)
        		    fi
        		#Конец проверки существования системной группы пользователей $2


        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}

#############################archive##############################################
#не трогать
#архивация файла
#($1-путь к исходному файлу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - отсутствует исходный файл, 3 - отсутствует каталог назначения, 4 -неправильно указаны параметры (str, str_rem, nostr, nostr_rem),
#5-неправильно указаны параметры  mode (full_info,querry,silent,error_only), ошибка значения переменной $showSuccessResult
#6 - не существует пользователь системы, 7 - не существует группа, 8 - финальная проверка существования файла завершилась с ошибкой
#9 - ошибка передачи параметра Mode (rewrite/norewrite), #10 - файл $2 уже существует, а из-за параметра 9(norewrite) не будет перезаписан
tarFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют

	#Проверка существования файла "$2" и параметра перезаписи файла назначения
	if [ -f $2 ] ; then
	    #Файл "$2" существует

	        case "$5" in
                rewrite)
                    echo -e "${COLOR_YELLOW}Файл ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} уже существует и будет перезаписан. Выполняется архивация файла ${COLOR_GREEN}\"$1\"${COLOR_YELLOW}  ${COLOR_NC}"
                    ;;
                norewrite)
                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует и не будет перезаписан. Операция архивирования прервана${COLOR_NC}";
                    return 10
                    ;;
                *)
                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
                    return 9
                    ;;
            esac

	    #Файл "$2" существует (конец)
	fi
	#Конец проверки существования файла "$2"

		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    case "$4" in
		        full_info)
		            #Проверка существования каталога "`dirname $2`"
		            if [ -d `dirname $2` ] ; then
		                #Каталог "`dirname $2`" существует
		                showSuccessResult=1 #Показывать ли успешный результат
		                folder=`dirname $2`
		                #Каталог "`dirname $2`" существует (конец)
		            else
		                #Каталог "`dirname $2`" не существует
		                echo -e "${COLOR_RED}Каталог назначения ${COLOR_GREEN}\"`dirname $2`\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
		                return 3
		                #Каталог "`dirname $2`" не существует (конец)
		            fi
		            #Конец проверки существования каталога "`dirname $2`"

		            ;;
		        silent)
		            showSuccessResult=0; #Показывать ли успешный результат
		            folder=`dirname $2`;
		            mkdir -p $folder
		            ;;
		        querry)
		             #Проверка существования каталога "`dirname $2`"
		             showSuccessResult=1 #Показывать ли успешный результат
		            if [ -d `dirname $2` ] ; then
		                #Каталог "`dirname $2`" существует
		                folder=`dirname $2`
		                #Каталог "`dirname $2`" существует (конец)
		            else
		                #Каталог "`dirname $2`" не существует
		                echo -n -e "${COLOR_RED}Каталог ${COLOR_YELLOW}`dirname $2`${COLOR_RED} не существует. ${COLOR_YELLOW} Введите ${COLOR_BLUE}\"y\"${COLOR_NC}${COLOR_YELLOW} для его создания, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
		                	while read
		                	do
		                    	echo -n ": "
		                    	case "$REPLY" in
		                	    	y|Y)
		                	    	    folder=`dirname $2`;
		                                mkdir -p $folder;
		                                #echo -e "${COLOR_GREEN}Файл ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно заархивирован в ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
		                                break
		                                ;;
		                		    n|N)
		                		        echo -e "${COLOR_RED}Создание каталога ${COLOR_GREEN}\"`dirname $2`\"${COLOR_RED} отменено пользователем. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
		                                return 3;
		                			    break;;
		                	    esac
		                	done

		                #Каталог "`dirname $2`" не существует (конец)
		            fi
		            #Конец проверки существования каталога "`dirname $2`"
		            ;;
		    	error_only)
		    		#Проверка существования каталога "`dirname $2`"
		            if [ -d `dirname $2` ] ; then
		                #Каталог "`dirname $2`" существует
		                showSuccessResult=0 #Показывать ли успешный результат
		                folder=`dirname $2`
		                #Каталог "`dirname $2`" существует (конец)
		            else
		                #Каталог "`dirname $2`" не существует
		                echo -e "${COLOR_RED}Каталог назначения ${COLOR_GREEN}\"`dirname $2`\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
		                return 3
		                #Каталог "`dirname $2`" не существует (конец)
		            fi
		            #Конец проверки существования каталога "`dirname $2`"
		    		;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (full_info,querry,error_only)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
		    	    return 5
		    	    ;;
		    esac


            #тип архивации (с сохранением структуры, дополнительно с удалением исходника, без структуры, доп. с удалением исходника)
		    case "$3" in
		        str)
                    tar -czpf $2 -P $1
		            ;;
		        str_rem)
                    tar -czpf $2 -P $1 --remove-files
		            ;;
		    	nostr)
                    cd `dirname $1` && tar -czpf $2 `basename $1`
		    		;;
		    	nostr_rem)
                    cd `dirname $1` && tar -czpf $2 `basename $1` --remove-files
		    		;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (str, str_rem, nostr, nostr_rem)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
		    	    return 4
		    	    ;;
		    esac
		    #тип архивации (с сохранением структуры, дополнительно с удалением исходника, без структуры, доп. с удалением исходника) (конец)

            #Если указаны дополнительные параметры
            #Проверка на существование параметров запуска скрипта
            if [ -n "$6" ] && [ -n "$7" ] && [ -n "$8" ]
            then
            #Параметры запуска существуют
                #Проверка существования системного пользователя "$6"
                	grep "^$6:" /etc/passwd >/dev/null
                	if  [ $? -eq 0 ]
                	then
                	#Пользователь $6 существует
                		#Проверка существования системной группы пользователей "$7"
                		if grep -q $7 /etc/group
                		    then
                		        #Группа "$67 существует
                                chmod $8 $2
                                chown $6:$7 $2
                		        #Группа "$7" существует (конец)
                		    else
                		        #Группа "$7" не существует
                		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$7\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
                				return 7
                				#Группа "$7" не существует (конец)
                		    fi
                		#Конец проверки существования системной группы пользователей $7


                	#Пользователь $6 существует (конец)
                	else
                	#Пользователь $6 не существует
                	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$6\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
                	    return 6

                	#Пользователь $6 не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $6
            #Параметры запуска существуют (конец)
            else
            #Параметры запуска отсутствуют
                return 0
            #Параметры запуска отсутствуют (конец)
            fi
            #Конец проверки существования параметров запуска скрипта

		    #финальная проверка существования архива $2
		    #Проверка существования файла "$2"
		    if [ -f $2 ] ; then
		        #Файл "$2" существует
		        case $showSuccessResult in
		            0)
                        return 0
		                ;;
		            1)
                        echo -e "${COLOR_GREEN}Файл ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно заархивирован в ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                        return 0
		                ;;
		        	*)
		        	    echo -e "${COLOR_RED}Ошибка значения переменной ${COLOR_GREEN}\"showSuccessResult\"${COLOR_RED} в функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
		        	    echo $showSuccessResult;
		        	    return 6
		        	    ;;
		        esac
		        #Файл "$2" существует (конец)
		    else
		        #Файл "$2" не существует
		        echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"\"${COLOR_NC}"

		        #Файл "$2" не существует (конец)
		    fi
		    #Конец проверки существования файла "$2"
            #финальная проверка существования архива $2 (конец)

		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
            return 2
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tarFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#не трогать
#архивация каталога
#($1-путь к исходному каталогу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога и выводится результат,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - отсутствует исходный каталог, 3 - отсутствует каталог назначения, 4 -неправильно указаны параметры (str, str_rem, nostr, nostr_rem),
#5-неправильно указаны параметры  mode (full_info,querry,silent,error_only), ошибка значения переменной $showSuccessResult
#6 - не существует пользователь системы, 7 - не существует группа, 8 - финальная проверка существования файла завершилась с ошибкой
#9 - ошибка передачи параметра Mode (rewrite/norewrite), #10 - файл $2 уже существует, а из-за параметра 9(norewrite) не будет перезаписан
tarFolder() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют

	#Проверка существования файла "$2" и параметра перезаписи файла назначения
	if [ -f $2 ] ; then
	    #Файл "$2" существует

	        case "$5" in
                rewrite)
                    echo -e "${COLOR_YELLOW}Файл ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} уже существует и будет перезаписан. Выполняется архивация файла ${COLOR_GREEN}\"$1\"${COLOR_YELLOW}  ${COLOR_NC}"
                    ;;
                norewrite)
                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует и не будет перезаписан. Операция архивирования прервана${COLOR_NC}";
                    return 10
                    ;;
                *)
                    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
                    return 9
                    ;;
            esac

	    #Файл "$2" существует (конец)
	fi
	#Конец проверки существования файла "$2"

		#Проверка существования каталога "$1"
		if [ -d $1 ] ; then
		    case "$4" in
		        full_info)
		            #Проверка существования каталога "`dirname $2`"
		            if [ -d `dirname $2` ] ; then
		                #Каталог "`dirname $2`" существует
		                showSuccessResult=1 #Показывать ли успешный результат
		                folder=`dirname $2`
		                #Каталог "`dirname $2`" существует (конец)
		            else
		                #Каталог "`dirname $2`" не существует
		                echo -e "${COLOR_RED}Каталог назначения ${COLOR_GREEN}\"`dirname $2`\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
		                return 3
		                #Каталог "`dirname $2`" не существует (конец)
		            fi
		            #Конец проверки существования каталога "`dirname $2`"

		            ;;
		        silent)
		            showSuccessResult=0; #Показывать ли успешный результат
		            folder=`dirname $2`;
		            mkdir -p $folder
		            ;;
		        querry)
		             #Проверка существования каталога "`dirname $2`"
		             showSuccessResult=1 #Показывать ли успешный результат
		            if [ -d `dirname $2` ] ; then
		                #Каталог "`dirname $2`" существует
		                folder=`dirname $2`
		                #Каталог "`dirname $2`" существует (конец)
		            else
		                #Каталог "`dirname $2`" не существует
		                echo -n -e "${COLOR_RED}Каталог ${COLOR_YELLOW}`dirname $2`${COLOR_RED} не существует. ${COLOR_YELLOW} Введите ${COLOR_BLUE}\"y\"${COLOR_NC}${COLOR_YELLOW} для его создания, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
		                	while read
		                	do
		                    	echo -n ": "
		                    	case "$REPLY" in
		                	    	y|Y)
		                	    	    folder=`dirname $2`;
		                                mkdir -p $folder;
		                               # echo -e "${COLOR_GREEN}Каталог ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно заархивирован в ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
		                                break
		                                ;;
		                		    n|N)
		                		        echo -e "${COLOR_RED}Создание каталога ${COLOR_GREEN}\"`dirname $2`\"${COLOR_RED} отменено пользователем. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
		                                return 3;
		                			    break;;
		                	    esac
		                	done

		                #Каталог "`dirname $2`" не существует (конец)
		            fi
		            #Конец проверки существования каталога "`dirname $2`"
		            ;;
		    	error_only)
		    		#Проверка существования каталога "`dirname $2`"
		            if [ -d `dirname $2` ] ; then
		                #Каталог "`dirname $2`" существует
		                showSuccessResult=0 #Показывать ли успешный результат
		                folder=`dirname $2`
		                #Каталог "`dirname $2`" существует (конец)
		            else
		                #Каталог "`dirname $2`" не существует
		                echo -e "${COLOR_RED}Каталог назначения ${COLOR_GREEN}\"`dirname $2`\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
		                return 3
		                #Каталог "`dirname $2`" не существует (конец)
		            fi
		            #Конец проверки существования каталога "`dirname $2`"
		    		;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (full_info,querry,error_only)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
		    	    return 5
		    	    ;;
		    esac


            #тип архивации (с сохранением структуры, дополнительно с удалением исходника, без структуры, доп. с удалением исходника)
		    case "$3" in
		        str)
                    tar -czpf $2 -P $1
		            ;;
		        str_rem)
                    tar -czpf $2 -P $1 --remove-files
		            ;;
		    	nostr)
                    cd `dirname $1` && tar -czpf $2 `basename $1`
		    		;;
		    	nostr_rem)
                    cd `dirname $1` && tar -czpf $2 `basename $1` --remove-files
		    		;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (str, str_rem, nostr, nostr_rem)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
		    	    return 4
		    	    ;;
		    esac
		    #тип архивации (с сохранением структуры, дополнительно с удалением исходника, без структуры, доп. с удалением исходника) (конец)

            #Если указаны дополнительные параметры
            #Проверка на существование параметров запуска скрипта
            if [ -n "$6" ] && [ -n "$7" ] && [ -n "$8" ]
            then
            #Параметры запуска существуют
                #Проверка существования системного пользователя "$6"
                	grep "^$6:" /etc/passwd >/dev/null
                	if  [ $? -eq 0 ]
                	then
                	#Пользователь $6 существует
                		#Проверка существования системной группы пользователей "$7"
                		if grep -q $7 /etc/group
                		    then
                		        #Группа "$67 существует
                                chmod $8 $2
                                chown $6:$7 $2
                		        #Группа "$7" существует (конец)
                		    else
                		        #Группа "$7" не существует
                		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$7\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
                				return 7
                				#Группа "$7" не существует (конец)
                		    fi
                		#Конец проверки существования системной группы пользователей $7


                	#Пользователь $6 существует (конец)
                	else
                	#Пользователь $6 не существует
                	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$6\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
                	    return 6

                	#Пользователь $6 не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $6
            #Параметры запуска существуют (конец)
            else
            #Параметры запуска отсутствуют
                return 0
            #Параметры запуска отсутствуют (конец)
            fi
            #Конец проверки существования параметров запуска скрипта

		    #финальная проверка существования архива $2
		    #Проверка существования файла "$2"
		    if [ -f $2 ] ; then
		        #Файл "$2" существует
		        case $showSuccessResult in
		            0)
                        return 0
		                ;;
		            1)
                        echo -e "${COLOR_GREEN}Каталог ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно заархивирован в ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                        return 0
		                ;;
		        	*)
		        	    echo -e "${COLOR_RED}Ошибка значения переменной ${COLOR_GREEN}\"showSuccessResult\"${COLOR_RED} в функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}";
		        	    echo $showSuccessResult;
		        	    return 6
		        	    ;;
		        esac
		        #Файл "$2" существует (конец)
		    else
		        #Файл "$2" не существует
		        echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"\"${COLOR_NC}"

		        #Файл "$2" не существует (конец)
		    fi
		    #Конец проверки существования файла "$2"
            #финальная проверка существования архива $2 (конец)

		else
		    #каталог "$1" не существует
		    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"tarFile\"${COLOR_NC}"
            return 2
		    #каталог "$1" не существует (конец)
		fi
		#Конец проверки существования каталога
		# "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tarFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#разархивация архива по указанному пути
#$1-ссылка на архив ; $2-ссылка на каталог назначения ; $3-mode:rewrite/norewrite ; $4-mode: showinfo/silent ; $5 - mode:createfolder/nocreatefolder/querrycreatefolder; $6 - mode:structure/nostructure
#return 0 - выполнено успешно, 1 - параметры не переданы, 2 - нет архива, 3 - ошибка параметра mode (createfolder/nocreatefolder/querrycreatefolder)
#4 - каталог назначения не существует при параметре nocreatefolder, 5 - ошибка параметра mode (showinfo/silent),
#6 - ошибка параметра mode (rewrite/norewrite), 7 - ошибка параметра mode (structure/nostructure), 8 - пользователем отменена операция создания каталога $2
untarFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    case "$5" in
		        createfolder)
                    #Проверка существования каталога "$2"
                    if ! [ -d $2 ] ; then
                        #Каталог "$2" не существует
                        mkdir -p $2
                        #Каталог "$2" не существует (конец)
                    fi
                    #Конец проверки существования каталога "$2"
		            ;;
		        nocreatefolder)
                    #Проверка существования каталога "$2"
                    if ! [ -d $2 ] ; then
                        #Каталог не "$2" существует
                        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"untarFile\"${COLOR_NC}"
                        #Каталог не "$2" существует (конец)
                        return 4
                    fi
                    #Конец проверки существования каталога "$2"

		            ;;
		        querrycreatefolder)
		            #Проверка существования каталога "$2"
                    if ! [ -d $2 ] ; then
                        echo -e "${COLOR_YELLOW}Каталог ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} не существует${COLOR_NC}"
                        echo -n -e "${COLOR_YELLOW}Введите ${COLOR_BLUE}\"y\"${COLOR_NC}${COLOR_YELLOW} для создания каталога  ${COLOR_GREEN}\"$2\"${COLOR_NC}${COLOR_YELLOW}, для отмены операции - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                            while read
                            do
                                echo -n ": "
                                case "$REPLY" in
                                    y|Y)
                                        mkdir -p $2;
                                        break;;
                                    n|N)
                                        echo -e "${COLOR_RED}Создание каталога ${COLOR_GREEN}\"$2\"${COLOR_RED} отменено пользователем при распаковке архива ${COLOR_GREEN}\"$1\"${COLOR_NC}";
                                        return 9;;
                                esac
                            done
                    fi
                    #Конец проверки существования каталога "$2"

		            ;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (createfolder/nocreatefolder/querrycreatefolder)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
		    	    return 3
		    	    ;;
		    esac
		    #Файл "$1" существует (конец)

		    case "$6" in
		        structure)
                        case "$4" in
                            showinfo)
                                case "$3" in
                                    rewrite)
                                        tar -xzpf $1 -P -C $2 && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xzkpf $1 -P -C $2 && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            silent)
                                case "$3" in
                                    rewrite)
                                        tar -xzpf $1 -P -C $2;
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xzkpf $1 -P -C $2;
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            *)
                                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (showinfo/silent)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                return 5
                                ;;
                        esac
		            ;;
		        nostructure)
                        case "$4" in
                            showinfo)
                                case "$3" in
                                    rewrite)
                                        tar -xpf $1 --strip-components 1 -P -C $2 && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xpkf $1 --strip-components 1 -P -C $2  && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            silent)
                                case "$3" in
                                    rewrite)
                                        tar -xpf $1 --strip-components 1 -P -C $2;
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xpkf $1 --strip-components 1 -P -C $2;
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            *)
                                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (showinfo/silent)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                return 5
                                ;;
                        esac
		            ;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (structure/nosctucture)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
		    	    return 7
		    	    ;;
		    esac
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"untarFile\"${COLOR_NC}"
		    return 2
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"untarFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}