#!/bin/bash
source $SCRIPTS/external_scripts/dev-shell-essentials-master/dev-shell-essentials.sh
############################mysql########################
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

declare -x -f dbChangeUserPassword #Смена пароля пользователю mysql: ($1-user ; $2-host ; $3-password ; $4-autentification type (mysql_native_password) ; )

############################backups######################
declare -x -f dbBackupBase #Создание бэкапа указанной базы данных
declare -x -f dbBackupAllBases #создание бэкапа всех баз данных: ($1-user owner ; $2-owner group ; $3-разрешения на файл ; $4-mode:createfolder/nocreatefolder/querrycreatefolder ; $5-Каталог выгрузки (необязательный параметр) ;)
declare -x -f dbBackupBasesOneUser #Создание бэкапа все баз данных указанного пользователя mysql:
                                    #return 0 - выполнено успешно, 1 - не переданы параметры, 2 - пользователь не существует, 3 - пользователь отменил создание папки

############################site#########################
declare -x -f viewFtpAccess				#отобразить реквизиты доступа к серверу FTP
                                        #$1 - user; $2 - password
                                        #return 0 - выполнено успешно, 1 - не переданы параметры
declare -x -f viewSshAccess				#отобразить реквизиты доступа к серверу SSH
                                        #$1 - user
                                        #return 0 - выполнено успешно, 1 - отсутствуеют параметры
declare -x -f viewMysqlAccess			#отобразить реквизиты доступа к серверу MYSQL
                                        #$1 - user
                                        #return 0 - выполнено успешно, 1 - не переданы параметры, 2 - файл my.cnf не найден
declare -x -f viewSiteConfigsByName		#Вывод перечня сайтов указанного пользователя (конфиги веб-сервера)
                                        # $1 - имя пользователя
                                        #return 0 - выполнено успешно, 1 - не передан параметр, 2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
declare -x -f viewSiteFoldersByName		#Вывод перечня сайтов указанного пользователя
                                        # $1 - имя пользователя
                                        #return 0  - выполнено успешно, 1 - не передан параметр, 2 - отсутствует каталог $HOMEPATHWEBUSERS/$1

declare -x -f mkdirWithOwn
############################users########################






############################ssh########################
declare -x -f sshKeyGenerateToUser
declare -x -f sshKeyAddToUser

############################archive########################

declare -x -f tarFile ##архивация файла ($1-путь к исходному файлу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
declare -x -f tarFolder ##архивация каталога ($1-путь к исходному каталогу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
declare -x -f untarFile #разархивация архива по указанному пути: ($1-ссылка на архив ; $2-ссылка на каталог назначения ; $3-mode:rewrite/norewrite ; $4-mode: showinfo/silent; $5 - mode:createfolder/nocreatefolder/querrycreatefolder)


############################ufw#############################
declare -x -f ufwAddPort            #Добавление порта с исключением в firewall ufw: ($1-port ; $2-protocol ; $3-комментарий ;)
                                    #return 0 - выполнено успешно, 1 - не переданы параметры



############################разное##########################
declare -x -f ufwOpenPorts          #Вывод открытых портов ufw
declare -x -f viewPHPVersion        #вывод информации о версии PHP
declare -x -f webserverRestart      #Перезапуск Веб-сервера

declare -x -f folderExistWithInfo   #проверка существования папки с выводом информации о ее существовании: ($1-path ; $2-type (create/exist))
                                    #return 0 - выполнено успешно, 1 - не переданы параметры,2 - ошибка передачи параметров
                                    #3 - каталог не создан, 4 -каталог создан, 5 - каталог не существует, 6 - каталог существует
declare -x -f fileExistWithInfo	    #проверка существования файла с выводом информации о ее существовании: ($1-path ; $2-type (create/exist))
                                    #return 0 - выполнено успешно, 1 - не переданы параметры,2 - ошибка передачи параметров
                                    #3 - файл не создан, 4 -файл создан, 5 - файл не существует, 6 - файл существует
						   













#################################################################################################
#################################################################################################
#################################################################################################

#Создание папки и применение ей владельца и прав доступа
#$1-путь к папке ; $2-user ; $3-group ; $4-разрешения ;
#return 0 - выполнено успешно, 1 - не переданы параметры, 2 - пользователь не существует, 3 - группа не существует
mkdirWithOwn() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		    #Проверка существования системного пользователя "$2"
		    	grep "^$2:" /etc/passwd >/dev/null
		    	if  [ $? -eq 0 ]
		    	then
		    	#Пользователь $2 существует
		    		#Проверка существования системной группы пользователей "$3"
		    		if grep -q $3 /etc/group
		    		    then
		    		        #Группа "$3" существует
		    		            sudo mkdir -p $1
		    		            sudo chmod $4 $1
				                sudo chown $2:$3 $1
				                return 0
		    		        #Группа "$3" существует (конец)
		    		    else
		    		        #Группа "$3" не существует
		    		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
                            return 3
		    				#Группа "$3" не существует (конец)
		    		    fi
		    		#Конец проверки существования системного пользователя $3
		    	#Пользователь $2 существует (конец)
		    	else
		    	#Пользователь $2 не существует
		    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
		    	    return 2
		    	#Пользователь $2 не существует (конец)
		    	fi
		    #Конец проверки существования системного пользователя $2


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




























#не проверно
#USERS
#Полностью проверено
declare -x -f existGroup                                #Существует ли группа $1
                                                        #функция возвращает значение 0-если группа $1 существует. 1- если группа не существует
                                                        #Если передан параметр $2, равный 1, то выведется текст сообщения о существовании группы
                                                        #$1-group
                                                        #return 0 - группа $1 существует, 1 - группа $1 не существует

declare -x -f userExistInGroup                          #состоит ли пользователь $1 в группе $2
                                                        #функция возвращает значение 0-если пользователь состоит в группе "$2", 1- если не состоит в группе "$2"
                                                        #ничего не выводится
                                                        #$1-user ; $2-group; $3-может быть передан параметр 3, равеный 1, тогда выведется сообщение о присутствии или отсутствии пользвоателя в группе
                                                        #return 0 - нет ошибок, 1 - пользователь не существует, 2 - не переданы параметры
declare -x -f viewUserGroups                            #Вывод списка групп, в которых состоит пользователь (полное совпадение): ($1-user ;)
declare -x -f userAddToGroup                            #Добавить пользователя в группу
                                                        #$1-user ; $2-группа; Если есть параметр 3, равный 1, то добавление происходит с запросом подтверждения, если без - в тихом режиме
                                                        #return 0 - успешно выполнено; 1 - не существует пользователь; 2 - отмена пользователем
                                                        #3 - пользователь уже присутствует в группе $1
declare -x -f userDeleteFromGroup                       #Удаление пользователя $1 из группы $2
                                                        #$1-user ; $2-group ;
                                                        #return 0 - пользователь удален; 1 - отмена удаления пользователем
                                                        #2 - пользователя $1 нет в группе $2; 3 - группа $2 не существует

declare -x -f viewUsersInGroup                            #Вывод списка пользователей, входящих в группу $1: ($1-группа ;)
                                                        #return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
declare -x -f viewUsersInGroupByPartName                  #Вывод списка пользователей, входящих в группу $2 по части имени пользователя $1
                                                        #$1-часть имени ; $2 - название группы
                                                        #return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
declare -x -f viewUserInGroupUsersByPartName            #Вывод списка пользователей, входящих в группу users по части имени пользователя $1
                                                        #$1-часть имени
                                                        #return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
declare -x -f viewUserInGroupByName						#Вывод групп, в которых состоит указанный пользователь
                                                        # $1 - имя пользователя
                                                        #return 0 - выполнено успешно, 1 - не передан параметр
declare -x -f useraddFtp                                #Добавление пользователя ftp: ($1-user ; $2-path ;)
                                                        #$1-user ; $2-path ; 3 - pass
                                                        #return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь уже существует
                                                        #3 - каталог уже существует, 4 - произошла ошибка при создании пользователя

#Полностью протестировано
declare -x -f chOwnFolderAndFiles #Смена владельца на файлы в папке и саму папку: ($1-path; $2-user; $3-group)
                    #return 0 - выполнено успешно, 1 - каталог не существует, 2 - пользователь не существует, 3 - группа не существует
declare -x -f chModAndOwnFolderAndFiles #Смена разрешений на каталог и файлы, а также владельца: ($1-путь к каталогу; $2-права на каталог ; $3-Права на файлы ; $4-Владелец-user ; $5-Владелец-группа ;)
                            #return 0 - выполнено успешно, 1 - отсутствуют параметры запуска,
                            #2 - не существует каталог, 3 - не существует пользователь, 4 - не существует группа
declare -x -f chModAndOwnFile #Смена владельна и прав доступа на файл: ($1-путь к файлу ; $2-user ; $3-group ; $4-права доступа на файл ;)
                                #$1-путь к файлу ; $2-user ; $3-group ; $4-права доступа на файл ;
                                #return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - отсутствует файл
                                #3 - отсутствует пользователь, #4 - отсутствует группа



declare -x -f touchFileWithModAndOwn    #создание файла и применение прав к нему и владельца: #$1-путь к файлу ; $2-user ; $3-group ; $4-права доступ ;
                                        #return 0 - выполнено успешно, 1 - файл существовал, применены лишь права, 2 - пользователь не существует, 3 - группа не существует

declare -x -f createSite_Laravel #Создание сайта: # $1 - домен ($DOMAIN), $2 - имя пользователя, $3 - путь к папке с сайтом,  $4 - шаблон виртуального хоста apache, $5 - шаблон виртуального хоста nginx

declare -x -f addSite_php #:Добавление сайта php $1-$USERNAME process $2 - домен ($DOMAIN), $3 - имя пользователя, $4 - путь к папке с сайтом,  $5 - шаблон виртуального хоста apache, $6 - шаблон виртуального хоста nginx
#


#запрос на добавление сайта laravel
declare -x -f inputSite_Laravel





#####################ПОЛНОСТЬЮ ГОТОВО
declare -x -f dbViewUserInfo #Вывести информацию о пользователе mysql. #$1-user ;
                             #return 0 - пользователь существует, 1 - пользователь не существует;

#mysql

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

#backups

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



declare -x -f backupSiteFiles #Создание бэкапа файлов сайта
                                        #$1-user ; $2-domain ; $3-path ;
                                        #return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - каталог не существует,4 - пользователь отменил создание каталога
declare -x -f backupUserSitesFiles #Создание бэкапов файлов всех сайтов указанного пользователя: ($1-username ; $2-path)



#ALLFUNCTIONS
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





############################mysql########################
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

#
#Смена пароля пользователю mysql
#$1-user ; $2-host ; $3-password ; $4-autentification type (mysql_native_password) ; $5- ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - пользователь не существует 
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


#создание бэкапа всех баз данных
#$1-user owner ; $2-owner group ; $3-разрешения на файл ; $4-mode:createfolder/nocreatefolder/querrycreatefolder ; $5-Каталог выгрузки ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - группа не существует
#4 - проверка выгруженного файла завершилась с ошибкой

dbBackupAllBases() {

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

                        d=$DATEFORMAT;
                        dt=$DATETIMEFORMAT;
                        databases=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`


                        #выгрузка баз данных
                        for db in $databases; do
                            if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then
                                #echo -e "---\nВыгрузка базы данных MYSQL: ${COLOR_YELLOW}$db${COLOR_NC}"
                               # echo db = $db
                               # user_fcut=${db%_*}
                               # user=${user_fcut%_*}

                               # echo user_fcut - $user_fcut
                               # echo user - $user

                               # domain_fcut=${db##$user_}
                               # echo domain_fcut - $domain_fcut
                               # domain=${domain_fcut%_*}
                               # echo domain - $domain
								#echo DB: $db
								 #user_fcut=${db%_*}
								user1=${db%_*}
								user=${user1%_*}
								#echo user - $user
								#${user_fcut%_*}

								#обрезаем пользователя слева
								domain1=${db#${user}_}
								#echo domain1 - $domain1
								#обрезаем дополнительную базу справа
								domain=${domain1%_*}
								#echo domain - $domain
								#echo $db

                                #Проверка на существование параметров запуска скрипта
                        if [ -n "$5" ]
                        then
                        #Параметры запуска существуют

                            #Проверка существования каталога "$5"
                            if ! [ -d $5 ] ; then
                                #Каталог "$5" не существует
                                echo -e "${COLOR_RED} Каталог \"$5\" не найден для создания бэкапа всех баз данных mysql. Создать его? Функция ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_NC}"
                                echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$5\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                                while read
                                do
                                echo -n ": "
                                    case "$REPLY" in
                                    y|Y)
                                        mkdir -p "$5";
                                        DESTINATION=$5
                                        #echo $DESTINATION
                                        break;;
                                    n|N)
                                         break;;
                                    esac
                                done
                                #Каталог "$6" не существует (конец)
                            else
                                #Каталог "$5" существует
                                DESTINATION=$5
                                #Файл "$5" существует (конец)
                            fi
                            #Конец проверки существования каталога "$5"

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

                                #echo $1
                               # echo $user
                                filename=mysql.$user-"$db"-$dt.sql
                                mysqldump --databases $db > $DESTINATION/$filename
                                #архивация выгруженной базы и удаление оригинального файла sql
                                #tarFile	$DESTINATION/$filename $DESTINATION/$filename.tar.gz
                                tarFile $DESTINATION/$filename $DESTINATION/$filename.tar.gz nostr_rem silent rewrite;
                                #проверка на существование выгруженных и заархививанных баз данных
                                chModAndOwnFile $DESTINATION/$filename.tar.gz $user www-data 644
                                if  [ -f "$DESTINATION/$filename.tar.gz" ] ; then
                                    echo -e "${COLOR_GREEN}Выгрузка базы данных MYSQL:${COLOR_NC} ${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_GREEN}успешно завершилась в файл${COLOR_NC}${COLOR_YELLOW} \"$DESTINATION/$filename.tar.gz\"${COLOR_NC}\n---"
                                    #return 0
                                else
                                    echo -e "${COLOR_RED}Выгрузка базы данных: ${COLOR_NC}${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_RED}завершилась с ошибкой${COLOR_NC}\n---"
                                    return 4
                                fi
                            fi
                        done
						
						return 0

        		        #Группа "$2" существует (конец)
        		    else
        		        #Группа "$2" не существует
        		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_NC}"
        				return 3
        				#Группа "$2" не существует (конец)
        		    fi
        		#Конец проверки существования системной группы пользователей $2




        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"dbBackupAllBases\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#создание бэкапа всех баз данных одного пользователя
#$1-user ; $2-owner group ; $3-разрешения на файл ; $4-mode:createfolder/nocreatefolder/querrycreatefolder ; $5-Каталог выгрузки ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - группа не существует
#4 - проверка выгруженного файла завершилась с ошибкой
dbBackupBasesOneUser() {
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

                        d=$DATEFORMAT;
                        dt=$DATETIMEFORMAT;
                        databases=`mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like '$1_%'" | tr -d "| " | grep -v SCHEMA_NAME`


                        #выгрузка баз данных
                        for db in $databases; do
                            if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then
                                #echo -e "---\nВыгрузка базы данных MYSQL: ${COLOR_YELLOW}$db${COLOR_NC}"
                               # echo db = $db
                               # user_fcut=${db%_*}
                               # user=${user_fcut%_*}

                               # echo user_fcut - $user_fcut
                               # echo user - $user

                               # domain_fcut=${db##$user_}
                               # echo domain_fcut - $domain_fcut
                               # domain=${domain_fcut%_*}
                               # echo domain - $domain
								#echo DB: $db
								 #user_fcut=${db%_*}
								user1=${db%_*}
								user=${user1%_*}
								#echo user - $user
								#${user_fcut%_*}

								#обрезаем пользователя слева
								domain1=${db#${user}_}
								#echo domain1 - $domain1
								#обрезаем дополнительную базу справа
								domain=${domain1%_*}
								#echo domain - $domain
								#echo $db

                                #Проверка на существование параметров запуска скрипта
                        if [ -n "$5" ]
                        then
                        #Параметры запуска существуют

                            #Проверка существования каталога "$5"
                            if ! [ -d $5 ] ; then
                                #Каталог "$5" не существует
                                echo -e "${COLOR_RED} Каталог \"$5\" не найден для создания бэкапа всех баз данных mysql. Создать его? Функция ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}"
                                echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$5\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                                while read
                                do
                                echo -n ": "
                                    case "$REPLY" in
                                    y|Y)
                                        mkdir -p "$5";
                                        DESTINATION=$5
                                        #echo $DESTINATION
                                        break;;
                                    n|N)
                                         break;;
                                    esac
                                done
                                #Каталог "$6" не существует (конец)
                            else
                                #Каталог "$5" существует
                                DESTINATION=$5
                                #Файл "$5" существует (конец)
                            fi
                            #Конец проверки существования каталога "$5"

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

                                #echo $1
                               # echo $user
                                filename=mysql.$user-"$db"-$dt.sql
                                mysqldump --databases $db > $DESTINATION/$filename
                                #архивация выгруженной базы и удаление оригинального файла sql
                                #tarFile	$DESTINATION/$filename $DESTINATION/$filename.tar.gz
                                tarFile $DESTINATION/$filename $DESTINATION/$filename.tar.gz nostr_rem silent rewrite;
                                #проверка на существование выгруженных и заархививанных баз данных
                                chModAndOwnFile $DESTINATION/$filename.tar.gz $user www-data 644
                                if  [ -f "$DESTINATION/$filename.tar.gz" ] ; then
                                    echo -e "${COLOR_GREEN}Выгрузка базы данных MYSQL:${COLOR_NC} ${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_GREEN}успешно завершилась в файл${COLOR_NC}${COLOR_YELLOW} \"$DESTINATION/$filename.tar.gz\"${COLOR_NC}\n---"
                                    #return 0
                                else
                                    echo -e "${COLOR_RED}Выгрузка базы данных: ${COLOR_NC}${COLOR_YELLOW}$db${COLOR_NC} ${COLOR_RED}завершилась с ошибкой${COLOR_NC}\n---"
                                    return 4
                                fi
                            fi
                        done
						
						return 0

        		        #Группа "$2" существует (конец)
        		    else
        		        #Группа "$2" не существует
        		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}"
        				return 3
        				#Группа "$2" не существует (конец)
        		    fi
        		#Конец проверки существования системной группы пользователей $2




        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


############################site#########################
#отобразить реквизиты доступа к серверу FTP
#$1 - user; $2 - password
#return 0 - выполнено успешно, 1 - не переданы параметры
viewFtpAccess(){
	if [ -n "$1" ] && [ -n "$2" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты FTP-Доступа" ${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" $MYSERVER "${COLOR_NC}"
		echo -e "Порт ${COLOR_YELLOW}" $FTPPORT "${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Пароль: ${COLOR_YELLOW}" $2 "${COLOR_NC}"
		echo $LINE
		return 0
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewFtpAccess в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}

#отобразить реквизиты доступа к серверу SSH
#$1 - user
#return 0 - выполнено успешно, 1 - отсутствуеют параметры
viewSshAccess(){
	if [ -n "$1" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты SSH-Доступа" ${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" $MYSERVER "${COLOR_NC}"
		echo -e "Порт ${COLOR_YELLOW}" $SSHPORT "${COLOR_NC}"
		echo $LINE
		return 0
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewSshAccess в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}

#отобразить реквизиты доступа к серверу MYSQL
#$1 - user
#return 0 - выполнено успешно, 1 - не переданы параметры, 2 - файл my.cnf не найден
viewMysqlAccess(){
	if [ -n "$1" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты PHPMYADMIN" ${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" http://$MYSERVER:$APACHEHTTPPORT/$PHPMYADMINFOLDER "${COLOR_NC}"
		echo -e "\n${COLOR_YELLOW}Пользователь MySQL:${COLOR_NC}"
		if [ -f $HOMEPATHWEBUSERS/$1/.my.cnf ] ;  then
            cat $HOMEPATHWEBUSERS/$1/.my.cnf
            return 0
		else
		    echo -e "${COLOR_RED}Файл $HOMEPATHWEBUSERS/$1/.my.cnf не существует${COLOR_NC}"
		    return 2
        fi
		echo $LINE

	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewMysqlAccess в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}


#Вывод перечня сайтов указанного пользователя (конфиги веб-сервера)
# $1 - имя пользователя
#return 0 - выполнено успешно, 1 - не передан параметр, 2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
viewSiteConfigsByName(){
	if [ -n "$1" ]
	then
		if [ -d $HOMEPATHWEBUSERS/$1 ] ;  then
            echo -e "\nСписок сайтов в каталоге пользователя ${COLOR_YELLOW}\"$1\"${COLOR_NC}" $HOMEPATHWEBUSERS/$1:
			ls $HOMEPATHWEBUSERS/$1 | echo ""
		else
		    echo -e "${COLOR_RED}Каталог  ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1\"${COLOR_RED} не найден.Ошибка выполнения функции ${COLOR_GREEN}\"viewSiteConfigsByName\"${COLOR_RED}  ${COLOR_NC}"
		    return 2
        fi

		echo -n "Apache - sites-available (user:$1): "
		ls $APACHEAVAILABLE | grep -E "$1.*$1" | echo ""
		echo  -n "Apache - sites-enabled (user:$1): "
		ls $APACHEENABLED | grep -E "$1.*$1" | echo ""
		echo  -n "Nginx - sites-available (user:$1): "
		ls $NGINXAVAILABLE | grep -E "$1.*$1" | echo ""
		echo  -n "Nginx - sites-enabled (user:$1): "
		ls $NGINXENABLED | grep -E "$1.*$1" | echo ""
		echo $LINE
		return 0
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewSiteConfigsByName в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}

#Вывод перечня сайтов указанного пользователя
# $1 - имя пользователя
#return 0  - выполнено успешно, 1 - не передан параметр, 2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
viewSiteFoldersByName(){
	if [ -n "$1" ]
	then
		if [ -d $HOMEPATHWEBUSERS/$1 ] ;  then
            echo -e "\nСписок сайтов в каталоге пользователя ${COLOR_YELLOW}\"$1\"${COLOR_NC}" $HOMEPATHWEBUSERS/$1:
			ls $HOMEPATHWEBUSERS/$1/
			retun 0
		else
			echo -e "${COLOR_RED}Каталог $HOMEPATHWEBUSERS/$1/ не существует. Ошибка выполнения функции viewSiteFoldersByName ${COLOR_NC}"
			return 2
        fi
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewSiteFoldersByName в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}



############################users########################











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
                        #DATE_TYPE2=$DATETIMESQLFORMAT
						DATE_TYPE2=$DATETIMEFORMAT
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
                                 #tar_file_structure $4/.ssh/authorized_keys $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz
                                 tarFile $4/.ssh/authorized_keys $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz str silent rewrite $1 $2 644
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


############################ufw########################################
#Добавление порта с исключением в firewall ufw
#$1-port ; $2-protocol ; $3-комментарий ;
#return 0 - выполнено успешно, 1 - не переданы параметры, 2 - ошибка добавления правила
ufwAddPort() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		ufw allow $1/$2 comment $3 && return 0 || return 2
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"ufwAddPort\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



############################разное#####################################
#Вывод открытых портов ufw
ufwOpenPorts() {
    netstat -ntulp
}

#Перезапуск Веб-сервера
webserverRestart() {
    /etc/init.d/apache2 restart
    /etc/init.d/nginx restart
}

#вывод информации о версии PHP
viewPHPVersion(){
	echo ""
	echo "Версия PHP:"
	php -v
	echo ""
}




#проверка существования папки с выводом информации о ее существовании
#$1-path ; $2-type (create/exist)
#return 1 - не переданы параметры,2 - ошибка передачи параметров
#3 - каталог не создан, 4 -каталог создан, 5 - каталог не существует, 6 - каталог существует
folderExistWithInfo() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		case "$2" in
				"create")
					if ! [ -d $1 ] ; then
						echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не создан${COLOR_NC}"
						return 3
					else
						echo -e "${COLOR_GREEN}Каталог ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} создан успешно${COLOR_NC}"
						return 4
					fi
						;;
				"exist")
					if ! [ -d $1 ] ; then
						echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
						return 5
					else
						echo -e "${COLOR_GREEN}Каталог ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} существует${COLOR_NC}"
						return 6
					fi
					;;
				*)
					echo -e "${COLOR_GREEN}Ошибка параметров в функции ${COLOR_YELLOW}\"folderExistWithInfo\"${COLOR_NC}"
					return 2;;
				esac
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"folderExistWithInfo\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#проверка существования файла с выводом информации.
#$1-path, $2-type (create/exist)
#return 0 - выполнено успешно, 1 - не переданы параметры,2 - ошибка передачи параметров
#3 - файл не создан, 4 -файл создан, 5 - файл не существует, 6 - файл существует
fileExistWithInfo(){

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
	    case "$2" in
				"create")
					if ! [ -f $1 ] ; then
						echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не создан${COLOR_NC}"
						return 3
					else
						echo -e "${COLOR_GREEN}Файл ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} создан успешно${COLOR_NC}"
						return 4
					fi
						;;
				"exist")
					if ! [ -f $1 ] ; then
						echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
						return 5
					else
						echo -e "${COLOR_GREEN}Файл ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} существует${COLOR_NC}"
						return 6
					fi
					;;
				*)
					echo -e "${COLOR_GREEN}Ошибка параметров в функции ${COLOR_YELLOW}\"folderExistWithInfo\"${COLOR_NC}"
					return 2;;
	esac
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"fileExistWithInfo\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}






###############################Не разобрал####################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################




####################ПОЛНОСТЬЮ ГОТОВО##########################

#Вывод списка групп, в которых состоит пользователь
#$1-user ;
viewUserGroups() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		grep "^$1:" /etc/passwd >/dev/null
		#Проверка на успешность выполнения предыдущей команды
		if [ $? -eq 0 ]
			then
				#предыдущая команда завершилась успешно
				echo -e "${COLOR_YELLOW}Список групп, в которых состоит пользователь ${COLOR_GREEN}\""$1"\"${COLOR_NC}: "
		        grep "$1" /etc/group | highlight green "$1"

		        #Проверка наличия пользователя в группе users
		        userExistInGroup $1 users
		        #Проверка на успешность выполнения предыдущей команды
		        if [ $? -eq 0 ]
		        	then
		        		#предыдущая команда завершилась успешно
		        		echo -e "users:x:100:$1" | highlight green "$1"
		        		#предыдущая команда завершилась успешно (конец)
		        fi
		        #Конец проверки на успешность выполнения предыдущей команды

				#предыдущая команда завершилась успешно (конец)
			else
				#предыдущая команда завершилась с ошибкой
				echo -e "${COLOR_RED}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_RED} не найден. Ошибка выполнения функции viewUserGroups${COLOR_NC}"
				#предыдущая команда завершилась с ошибкой (конец)
		fi
		#Конец проверки на успешность выполнения предыдущей команды
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUserGroups\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Удаление пользователя $1 из группы $2
#$1-user ; $2-group ;
#return 0 - пользователь удален; 1 - отмена удаления пользователем
#2 - пользователя $1 нет в группе $2; 3 - группа $2 не существует
userDeleteFromGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует

		    existGroup $2
		    #Проверка на успешность выполнения предыдущей команды
		    if [ $? -eq 0 ]
		    	then
		    		#если группа $1 существует
		    		#проверка на наличие пользователя в группе $2
                    userExistInGroup $1 $2
                    #Проверка на успешность выполнения предыдущей команды (наличие пользователя в группе)
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            echo -e "${COLOR_YELLOW}Удалить пользователя ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} из группы ${COLOR_GREEN}\"$2\"${COLOR_YELLOW}? ${COLOR_NC}"
                            echo -n -e "${COLOR_YELLOW}Введите ${COLOR_GREEN}\"y\"${COLOR_YELLOW} для подтверждения или ${COLOR_GREEN}\"n\"${COLOR_YELLOW} - для отмены: ${COLOR_NC}: "
                            while read
                            do
                                case "$REPLY" in
                                    y|Y)
                                        gpasswd -d $1 $2
                                        echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно удален из группы ${COLOR_YELLOW}\"$2\" ${COLOR_NC}"
                                        return 0
                                        #break
                                        ;;
                                    n|N)
                                        return 1
                                        #break
                                        ;;
                                    *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                       ;;
                                esac
                            done

                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            echo -e "${COLOR_YELLOW}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} не присутствует в группе ${COLOR_GREEN}\"$2\" ${COLOR_NC}"
                            return 2
                                    #предыдущая команда завершилась с ошибкой (конец)
                        fi
                            #Конец проверки на успешность выполнения предыдущей команды
                    #проверка на наличие пользователя в группе sudo (конец)
                #если группа $1 существует (конец)
		    	else
		    		#если группа $1 не существует
		    		echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_YELLOW}\"userDeleteFromGroup\"${COLOR_NC}"
		    		return 3
		    		#если группа $1 не существует (конец)
		    fi
		    #Конец проверки на успешность выполнения предыдущей команды
		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_YELLOW}\"userDeleteFromGroup\"${COLOR_NC}"
            return 1
		#Пользователь $1 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userDeleteFromGroup\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}






#Вывод всех пользователей группы admin-access
viewGroupAdminAccessAll(){
	echo -e "\n${COLOR_YELLOW}Список пользователей группы \"admin-access:\":${COLOR_NC}"
	more /etc/group | grep admin-access: | highlight magenta "admin-access"
}

#Вывод всех пользователей группы admin-access с указанием части имени пользователя
# $1 - имя пользователя
viewGroupAdminAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"admin-access\", содержащих в имени \"$1\"${COLOR_NC}"
		more /etc/group | grep -E "admin.*$1" | highlight green "$1" | highlight magenta "admin-access"
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewGroupAdminAccessByName в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		exit 1
	fi
}

#Вывод всех пользователей группы sudo
viewGroupSudoAccessAll(){
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"sudo\":${COLOR_NC}"
		more /etc/group | grep sudo: | highlight magenta "sudo"
}

#Вывод пользователей группы sudo с указанием части имени пользователя
# $1 - имя пользователя
viewGroupSudoAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"sudo\", содержащих в названии ${COLOR_YELLOW}\"$1\"${COLOR_NC}:${COLOR_NC}"
		more /etc/group | grep sudo: | highlight green "$1" | highlight magenta "sudo"
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewGroupSudoAccessByName в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		exit 1
	fi
}


#Полностью проверно
#состоит ли пользователь $1 в группе $2
#функция возвращает значение 0-если пользователь состоит в группе "$2", 1- если не состоит в группе "$2"
#ничего не выводится
#$1-user ; $2-group; $3-может быть передан параметр 3, равеный 1, тогда выведется сообщение о присутствии или отсутствии пользвоателя в группе
#return 0 - нет ошибок, 1 - пользователь не существует, 2 - не переданы параметры
userExistInGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				id $1 | grep -w $2 >/dev/null
				#Проверка на успешность выполнения предыдущей команды
				if [ $? -eq 0 ]
					then
						#предыдущая команда завершилась успешно
						#Если передан параметр 3 и он равен 1
                        if [ "$3" == "1" ]
                        then
                            echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$1 \"${COLOR_GREEN}входит в группу ${COLOR_YELLOW}\"$2\"${COLOR_GREEN} ${COLOR_NC}"
                        fi
						return 0
						#предыдущая команда завершилась успешно (конец)
					else
						#предыдущая команда завершилась с ошибкой
						#Если передан параметр 3 и он равен 1
                        if [ "$3" == "1" ]
                        then
                            echo -e "${COLOR_RED}Пользователь ${COLOR_YELLOW}\"$1 \"${COLOR_RED}не входит в группу ${COLOR_YELLOW}\"$2\" ${COLOR_NC}"
                        fi
						return 1
						#предыдущая команда завершилась с ошибкой (конец)
				fi
				#Конец проверки на успешность выполнения предыдущей команды
				return 0
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_YELLOW}\"$1 \"${COLOR_RED}не существует${COLOR_NC}"
				return 1
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"UserExistInGroup\"${COLOR_RED} ${COLOR_NC}"
		return 2
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Существует ли группа $1
#функция возвращает значение 0-если группа $1 существует. 1- если группа не существует
#Если передан параметр $2, равный 1, то выведется текст сообщения о существовании группы
#$1-group
#return 0 - группа $1 существует, 1 - группа $1 не существует
existGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		cat /etc/group | grep -w $1 >/dev/null
		#Проверка на успешность выполнения предыдущей команды
		if [ $? -eq 0 ]
			then
				#предыдущая команда завершилась успешно
				#Проверка наличия параметра $2, равного 1
				if [ "$2" == "1" ]
				then
				     echo -e "${COLOR_GREEN}Группа ${COLOR_YELLOW}\"$1 \"${COLOR_GREEN}существует${COLOR_NC}"
				fi
				#Проверка наличия параметра $2, равного 1 (конец)
				return 0
				#предыдущая команда завершилась успешно (конец)
			else
				#предыдущая команда завершилась с ошибкой
				#Проверка наличия параметра $2, равного 1
				if [ "$2" == "1" ]
				then
				     echo -e "${COLOR_RED}Группа ${COLOR_YELLOW}\"$1 \"${COLOR_RED}не существует${COLOR_NC}"
				fi
				#Проверка наличия параметра $2, равного 1 (конец)
				return 1
				#предыдущая команда завершилась с ошибкой (конец)
		fi
		#Конец проверки на успешность выполнения предыдущей команды
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"ExistGroup\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Добавить пользователя в группу
#$1-user ; $2-группа; Если есть параметр 3, равный 1, то добавление происходит с запросом подтверждения, если без - в тихом режиме
#return 0 - успешно выполнено; 1 - отсутствуют параметры, 2 - не существует пользователь; 3 - отмена пользователем
#4 - пользователь уже присутствует в группе $1, 5 - ошибка в параметре функции, 6 - не существует группа
userAddToGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]  && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует
            #Проверка существования группы $2
		    existGroup $2
		    #Проверка на успешность выполнения предыдущей команды
		    if [ $? -eq 0 ]
		    	then
		    		#если группа $1 существует
		    		#проверка на наличие пользователя в группе $2
                    userExistInGroup $1 $2
                    #Проверка на успешность выполнения предыдущей команды (наличие пользователя в группе)
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже присутствует в группе ${COLOR_GREEN}\"$2\"${COLOR_NC}"
                            return 4
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой

                            #Проверка наличия параметра $3, равного 1
                            if [ "$3" == "1" ]
                            then
                                    #Присутстует параметр $3, равный 1
                                    echo -e "${COLOR_YELLOW}Добавить пользователя ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} в группу ${COLOR_GREEN}\"$2\"${COLOR_YELLOW}? ${COLOR_NC}"
                                    echo -n -e "${COLOR_YELLOW}Введите ${COLOR_GREEN}\"y\"${COLOR_YELLOW} для подтверждения или ${COLOR_GREEN}\"n\"${COLOR_YELLOW} - для отмены: ${COLOR_NC}: "
                                    while read
                                    do
                                        case "$REPLY" in
                                            y|Y)
                                                adduser $1 $2;
                                                echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно добавлен в группу ${COLOR_YELLOW}\"$2\"${COLOR_NC}"
                                                return 0
                                                #break
                                                ;;
                                            n|N)
                                                return 3
                                                #break
                                                ;;
                                            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                               ;;
                                        esac
                                    done
                                 #Присутствует параметр $3, равный 1 (конец)
                            else
                                if [ "$3" == "0" ]
                                then
                                    #Отсутствует параметр $3, равный 1
                                    adduser $1 $2
                                    echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно добавлен в группу ${COLOR_YELLOW}\"$2\"${COLOR_NC}"
                                    return 0
                                    #Отсутствует параметр $3, равный 1 (конец)
                                else
                                    echo -e "${COLOR_RED}Ошибка в параметре в функции ${COLOR_GREEN}\"userAddToGroup\"${COLOR_NC}"
                                    return 5
                                fi
                            fi
                            #Проверка наличия параметра $3, равного 1 (конец)

                            #предыдущая команда завершилась с ошибкой (конец)
                            fi
                            #Конец проверки на успешность выполнения предыдущей команды
                    #проверка на наличие пользователя в группе sudo (конец)
                #если группа $1 существует (конец)
		    	else
		    		#если группа $1 не существует
		    		echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_YELLOW}\"userAddToGroup\"${COLOR_NC}"
		    		return 6
		    		#если группа $1 не существует (конец)
		    fi
		    #Конец проверки на успешность выполнения предыдущей команды
		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_YELLOW}\"userAddToGroup\"${COLOR_NC}"
            return 2
		#Пользователь $1 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userAddToGroup\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод списка пользователей, входящих в группу $1
#$1-группа ;
#return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
viewUsersInGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системной группы пользователей "$1"
		if grep -q $1 /etc/group
		    then
		        #Группа "$1" существует
		         echo -e "\n${COLOR_YELLOW}Список пользователей группы ${COLOR_GREEN}\"$1\":${COLOR_NC}"
	             more /etc/group | grep "$1:" | highlight magenta "$1"
	             return 0
		        #Группа "$1" существует (конец)
		    else
		        #Группа "$1" не существует
		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
				return 2
				#Группа "$1" не существует (конец)
		    fi
		#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUsersInGroup\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод списка пользователей, входящих в группу $2 по части имени пользователя $1
#$1-часть имени ; $2 - название группы
#return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
viewUsersInGroupByPartName() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют

		#Проверка существования системной группы пользователей "$1"
		if grep -q $2: /etc/group
		    then
		        #Группа "$2" существует
		         echo -e "\n${COLOR_YELLOW}Список пользователей группы \"$2\", содержащих в имени \"$1\"${COLOR_NC}"
		         more /etc/group | grep -E "$2.*$1" | highlight green "$1" | highlight magenta "$2"
	             return 0
		        #Группа "$2" существует (конец)
		    else
		        #Группа "$2" не существует
		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует${COLOR_NC}"
				return 2
				#Группа "$2" не существует (конец)
		    fi
		#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUsersInGroupByPartName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Вывод списка пользователей, входящих в группу users по части имени пользователя $1
#$1-часть имени
#return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
viewUserInGroupUsersByPartName() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

		#Проверка существования системной группы пользователей "$1"
		if grep -q users: /etc/group
		    then
		        #Группа "$2" существует
		         echo -e "\n${COLOR_YELLOW}Список пользователей группы \"users\", содержащих в имени \"$1\"${COLOR_NC}"
		            more /etc/passwd | grep -E ":100::.*$1" | highlight green "$1"
	             return 0
		        #Группа "$2" существует (конец)
		    else
		        #Группа "$2" не существует
		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует${COLOR_NC}"
				return 2
				#Группа "$2" не существует (конец)
		    fi
		#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUserInGroupUsersByPartName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Вывод групп, в которых состоит указанный пользователь
# $1 - имя пользователя
#return 0 - выполнено успешно, 1 - не передан параметр
viewUserInGroupByName(){
	if [ -n "$1" ]
		then
			cat /etc/group | grep -P $1 | highlight green $1 | highlight magenta "ssh-access" | highlight magenta "ftp-access" | highlight magenta "sudo" | highlight magenta "admin-access"
			return 0
		else
			echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewUserInGroupByName в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
			return 1
		fi
}


#Добавление пользователя ftp
#$1-user ; $2-path ; $3
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь уже существует
#3 - каталог уже существует, 4 - произошла ошибка при создании пользователя
useraddFtp() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo -e "${COLOR_RED}Пользователь ftp ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"useraddFtp\"${COLOR_RED}  ${COLOR_NC}"
				return 2
			#Пользователь $1 существует (конец)
			else
			    #Проверка существования каталога "$2"
			    if [ -d $2 ] ; then
			        #Каталог "$2" существует
			        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"useraddFtp\"${COLOR_RED}  ${COLOR_NC}"
			        return 3
			        #Каталог "$2" существует (конец)
			    else
			        #Каталог "$2" не существует
			        useradd $1 -N -d $2 -m -s /bin/false -g ftp-access -G www-data
                    echo "$1:$3" | chpasswd
			        #Финальная проверка существования системного пользователя "$1"
			        	grep "^$1:" /etc/passwd >/dev/null
			        	if  [ $? -eq 0 ]
			        	then
			        	#Пользователь $1 существует
			        		echo -e "${COLOR_GREEN}Пользователь ftp ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно добавлен с домашим каталогом ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}"
			        		return 0
			        	#Пользователь $1 существует (конец)
			        	else
			        	#Пользователь $1 не существует

			        	    echo -e "${COLOR_RED}Произошла ошибка при создании пользователя ftp ${COLOR_GREEN}\"$1\"${COLOR_RED}. Ошибка выполнения функции ${COLOR_GREEN}\"useraddFtp\"${COLOR_NC}"
			        	    return 4
			        	#Пользователь $1 не существует (конец)
			        	fi
			        #Финальная проверка существования системного пользователя $1 (конец)
			        #Каталог "$2" не существует (конец)
			    fi
			    #Конец проверки существования каталога "$2"


			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"useraddFtp\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



###################################################################################################################
###################################################################################################################
###################################################################################################################
######SITE


#Создание сайта
# $1 - домен ($DOMAIN), $2 - имя пользователя, $3 - путь к папке с сайтом,  $4 - шаблон виртуального хоста apache, $5 - шаблон виртуального хоста nginx
createSite_Laravel() {
	#Проверка на существование параметров запуска скрипта
if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
then

        cd $HOMEPATHWEBUSERS/$2
        composer create-project --prefer-dist laravel/laravel $1

        #make user
        echo "Добавление веб пользователя $2_$1 с домашним каталогом: $3 для домена $1"
        sudo mkdir -p $3
        sudo useradd $2_$1 -N -d $3 -m -s /bin/false -g ftp-access -G www-data
        #sudo adduser $2_$1 www-data
        sudo passwd $2_$1
        sudo cp /etc/skel/* $3
        sudo rm -rf $3/public_html

		cd $3
		cp -a $3/.env.example $3/.env
		php artisan key:generate
		php artisan config:cache


       #nginx
       sudo cp -rf $TEMPLATES/nginx/$5 /etc/nginx/sites-available/$2_$1.conf
       sudo echo "Замена переменных в файле /etc/nginx/sites-available/$2_$1.conf"
       sudo grep '#__DOMAIN' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/#__DOMAIN/'$1'/g' /etc/nginx/sites-available/$2_$1.conf
	   sudo grep '#__USER' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/#__USER/'$2'/g' /etc/nginx/sites-available/$2_$1.conf
       sudo grep '#__PORT' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/#__PORT/'$HTTPNGINXPORT'/g' /etc/nginx/sites-available/$2_$1.conf
       sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/'#__HOMEPATHWEBUSERS'/\/home\/webusers/g' /etc/nginx/sites-available/$2_$1.conf

       sudo ln -s /etc/nginx/sites-available/$2_$1.conf /etc/nginx/sites-enabled/$2_$1.conf
       sudo systemctl reload nginx

        #apache2
       sudo cp -rf $TEMPLATES/apache2/$4 /etc/apache2/sites-available/$2_$1.conf
       sudo grep '#__DOMAIN' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__DOMAIN/'$1'/g' /etc/apache2/sites-available/$2_$1.conf
	   sudo grep '#__USER' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__USER/'$2'/g' /etc/apache2/sites-available/$2_$1.conf
       sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__HOMEPATHWEBUSERS/\/home\/webusers/g' /etc/apache2/sites-available/$2_$1.conf
       sudo grep '#__PORT' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__PORT/'$HTTPAPACHEPORT'/g' /etc/apache2/sites-available/$2_$1.conf

       sudo a2ensite $2_$1.conf
       sudo systemctl reload apache2

	   cp -rf $TEMPLATES/laravel/.gitignore $3/.gitignore

       echo -e "\033[32m" Применение прав к папкам и каталогам. Немного подождите "\033[0;39m"

        #chmod
       sudo find $3 -type d -exec chmod 755 {} \;
       sudo find $3/public -type d -exec chmod 755 {} \;
       sudo find $3 -type f -exec chmod 644 {} \;
       sudo find $3/public -type f -exec chmod 644 {} \;
       sudo find $3/logs -type f -exec chmod 644 {} \;
	   sudo find $3 -type d -exec chown $2:www-data {} \;
	   sudo find $3 -type f -exec chown $2:www-data {} \;

       sudo chown -R $2:www-data $3/logs
       sudo chown -R $2:www-data $3/public
       sudo chown -R $2:www-data $3/tmp


       sudo chmod 777 $3/bootstrap/cache -R
       sudo chmod 777 $3/storage -R

	   cd $3
		echo -e "\033[32m" Инициализация Git "\033[0;39m"
	    git init
		git add .
		git commit -m "initial commit"

else
    echo "Возможные варианты шаблонов apache:"
    ls $TEMPLATES/apache2/
    echo "Возможные варианты шаблонов nginx:"
    ls $TEMPLATES/nginx/
    echo "--------------------------------------"
    echo "Параметры запуска не найдены. Необходимы параметры: домен, имя пользователя,путь к папке с сайтом,название шаблона apache,название шаблона nginx."
    echo "Например $0 domain.ru user /home/webusers/domain.ru php.conf php.conf"
    echo -n -e "${COLOR_YELLOW}Для запуска главного введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода введите ${COLOR_BLUE}\"n\"${COLOR_NC}:"
fi

	#Конец проверки существования параметров запуска скрипта
}



#Смена владельна и прав доступа на файл
#$1-путь к файлу ; $2-user ; $3-group ; $4-права доступа на файл ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - отсутствует файл
#3 - отсутствует пользователь, #4 - отсутствует группа
chModAndOwnFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    #Проверка существования системного пользователя "$2"
		    	grep "^$2:" /etc/passwd >/dev/null
		    	if  [ $? -eq 0 ]
		    	then
		    	#Пользователь $2 существует
		    		#Проверка существования системной группы пользователей "$3"
		    		if grep -q $3 /etc/group
		    		    then
		    		        #Группа "$3" существует
		    		            chmod $4 $1
				                chown $2:$3 $1
		    		        #Группа "$3" существует (конец)
		    		    else
		    		        #Группа "$3" не существует
		    		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
                            return 4
		    				#Группа "$3" не существует (конец)
		    		    fi
		    		#Конец проверки существования системного пользователя $3
		    	#Пользователь $2 существует (конец)
		    	else
		    	#Пользователь $2 не существует
		    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
		    	    return 3
		    	#Пользователь $2 не существует (конец)
		    	fi
		    #Конец проверки существования системного пользователя $2
		    #Файл "$1" существует (конец)
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
		    return 2
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chModAndOwnFile\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}





#Смена разрешений на каталог и файлы, а также владельца
#$1-путь к каталогу; $2-права на каталог ; $3-Права на файлы ; $4-Владелец-user ; $5-Владелец-группа ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска,
#2 - не существует каталог, 3 - не существует пользователь, 4 - не существует группа
chModAndOwnFolderAndFiles() {
 #Проверка на существование параметров запуска скрипта
 if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
 then
 #Параметры запуска существуют
     #Проверка существования каталога "$1"
     if [ -d $1 ] ; then
         #Каталог "$1" существует
         #Проверка существования системного пользователя "$4"
         	grep "^$4:" /etc/passwd >/dev/null
         	if [ $? -eq 0 ]
         	then
         	#Пользователь $4 существует
         		existGroup $5 >/dev/null
         		#Проверка на успешность выполнения предыдущей команды
         		if [ $? -eq 0 ]
         			then
         				#предыдущая команда завершилась успешно
         				find $1 -type d -exec chmod $3 {} \;
                        find $1 -type f -exec chmod $3 {} \;
                        find $1 -type d -exec chown $4:$5 {} \;
                        find $1 -type f -exec chown $4:$5 {} \;
         				#предыдущая команда завершилась успешно (конец)
         			else
         				#предыдущая команда завершилась с ошибкой
         				echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
         				return 4
         				#предыдущая команда завершилась с ошибкой (конец)
         		fi
         		#Конец проверки на успешность выполнения предыдущей команды
         	#Пользователь $4 существует (конец)
         	else
         	#Пользователь $4 не существует
         	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует${COLOR_NC}"
                return 3
         	#Пользователь $4 не существует (конец)
         	fi
         #Конец проверки существования системного пользователя $4
         #Каталог "$1" существует (конец)
     else
         #Каталог "$1" не существует
         echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnFolderAndFiles\"${COLOR_NC}"
         return 2
         #Каталог "$1" не существует (конец)
     fi
     #Конец проверки существования каталога "$1"

 #Параметры запуска существуют (конец)
 else
 #Параметры запуска отсутствуют
     echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chModAndOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
     return 1
 #Параметры запуска отсутствуют (конец)
 fi
 #Конец проверки существования параметров запуска скрипта
}



#Смена владельца на файлы в папке и папку
#$1-path ; $2-user; $3-group
#return 0 - выполнено успешно, 1 - каталог не существует, 2 - пользователь не существует, 3 - группа не существует
chOwnFolderAndFiles() {
 #Проверка на существование параметров запуска скрипта
 if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
 then
 #Параметры запуска существуют
     #Проверка существования каталога "$1"
     if [ -d $1 ]  ; then
         #Каталог "$1" существует
         #Проверка существования системного пользователя "$2"
         	grep "^$2:" /etc/passwd >/dev/null
         	if [ $? -eq 0 ]
         	then
         	#Пользователь $2 существует
         		existGroup $3 >/dev/null
         		#Проверка на успешность выполнения предыдущей команды
         		if [ $? -eq 0 ]
         			then
         				#предыдущая команда завершилась успешно
                        find $1 -type d -exec chown $2:$3 {} \;
                        find $1 -type f -exec chown $2:$3 {} \;
                        return 0
         				#предыдущая команда завершилась успешно (конец)
         			else
         				#предыдущая команда завершилась с ошибкой
         				echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
         				return 3
         				#предыдущая команда завершилась с ошибкой (конец)
         		fi
         		#Конец проверки на успешность выполнения предыдущей команды
         	#Пользователь $2 существует (конец)
         	else
         	#Пользователь $2 не существует
         	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует${COLOR_NC}"
         		return 1
         	#Пользователь $2 не существует (конец)
         	fi
         #Конец проверки существования системного пользователя $2
         #Каталог "$1" существует (конец)
     else
         #Каталог "$1" не существует
         echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_NC}"
         return 1
         #Каталог "$1" не существует (конец)
     fi
     #Конец проверки существования каталога "$1"

 #Параметры запуска существуют (конец)
 else
 #Параметры запуска отсутствуют
     echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
 #Параметры запуска отсутствуют (конец)
 fi
 #Конец проверки существования параметров запуска скрипта
}





#создание файла и применение прав к нему и владельца
#$1-путь к файлу ; $2-user ; $3-group ; $4-права доступ ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - группа не существует, 4 - файл существовал, применены лишь права
touchFileWithModAndOwn() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then

    #Проверка существования системного пользователя "$2"
		    		grep "^$2:" /etc/passwd >/dev/null
		    		if  [ $? -eq 0 ]
		    		then
		    		#Пользователь $2 существует
		    			#Проверка существования системной группы пользователей "$3"
		    			if grep -q $3 /etc/group
		    			    then
		    			    #Проверка существования файла "$1"
                            if [ -f $1 ] ; then
                                #Файл "$1" уже существует. Применяются просто права доступа
                                sudo chmod $4 $1
		    			        sudo chown $2:$3 $1
		    			        return 4
                                #Файл "$1" существует. Применяются просто права доступа (конец)
                            else
                                #Файл "$1" не существует
                                    sudo touch $1
                                    sudo chmod $4 $1
		    			            sudo chown $2:$3 $1
		    			            return 0
                                #Файл "$1" не существует (конец)
                            fi
                            #Конец проверки существования файла "$1"

т
		    			    else
		    			        #Группа "$3" не существует
		    			        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_NC}"
		    					return 3
		    					#Группа "$3" не существует (конец)
		    			    fi
		    			#Конец проверки существования системного пользователя $3

		    		#Пользователь $2 существует (конец)
		    		else
		    		#Пользователь $2 не существует
		    		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_NC}"
		    			return 2
		    		#Пользователь $2 не существует (конец)
		    		fi
		    	#Конец проверки существования системного пользователя $2


	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




#Добавление сайта. Тип - php
#$1-username process ; $2- домен ($DOMAIN) ; $3-имя пользователя ; $4-путь к папке с сайтом ; $5- шаблон виртуального хоста apache; $6-шаблон виртуального хоста nginx
siteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]  && [ -n "$6" ]
	then
	#Параметры запуска существуют
		echo " "
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}





###################################################################################################################
###################################################################################################################
###################################################################################################################
######MYSQL










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
					sudo sed -i "s/.*password=.*/password=$2/" $HOMEPATHWEBUSERS/$1/.my.cnf
			#если файл для бэкапа не существует
			else
				sudo touch $HOMEPATHWEBUSERS/$1/.my.cnf
				sudo cat $HOMEPATHWEBUSERS/$1/.my.cnf | sudo grep $HOMEPATHWEBUSERS
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


###################################################################################################################
###################################################################################################################
###################################################################################################################
######INPUT






#запрос на добавление сайта laravel
#$1 - whoami
#return 0 - выполнено успешно, 1 - пользователя $username не существует
inputSite_Laravel() {
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ]
    then
    #Параметры запуска существуют
        username=$1
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        read -p "Введите имя пользователя, от чьего имени будет запущен скрипт: " username
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта

    #Проверка существования системного пользователя "$username"
    	grep "^$username:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $username существует
                echo -e "\n${COLOR_GREEN}Добавление сайта на фреймворке Laravel ${COLOR_NC}"
                echo -e "${COLOR_YELLOW}Список имеющихся доменов на сервере: ${COLOR_NC}"
                ls $HOMEPATHWEBUSERS/$username
                echo ""
                echo -n -e "${COLOR_BLUE}Введите домен${COLOR_NC}"
                read -p ": " domain
                echo ''
                site_path=$HOMEPATHWEBUSERS/$username/$domain
                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache: ${COLOR_NC}"
                ls $TEMPLATES/apache2/
                echo -n -e "${COLOR_BLUE}Введите название конфигурации apache: ${COLOR_NC}"
                read apache_config
                echo ''
                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx: ${COLOR_NC}"
                ls $TEMPLATES/nginx/
                echo -n -e "${COLOR_BLUE}Введите название конфигурации nginx: ${COLOR_NC}"
                read nginx_config
                echo ''
                echo -n -e "Для создания домена ${COLOR_YELLOW} $domain ${COLOR_NC}, пользователя ${COLOR_YELLOW} $username ${COLOR_NC} в каталоге ${COLOR_YELLOW} $site_path ${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW} \"$apache_config\" ${COLOR_NC} и конфирурацией nginx ${COLOR_YELLOW} \"$nginx_config\" ${COLOR_NC} введите ${COLOR_BLUE}\"y\"${COLOR_NC}, для выхода - любой символ: "
                read item
                case "$item" in
                    y|Y) echo
                        createSite_Laravel $domain $username $site_path $apache_config $nginx_config
                        exit 0
                        ;;
                    *) echo "Выход..."
                        exit 0
                        ;;
                esac
    	#Пользователь $username существует (конец)
    	else
    	#Пользователь $username не существует
    	    echo -e "\n${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Выполнение скрипта ${COLOR_GREEN}\"inputSite_Laravel\" остановлено${COLOR_NC}"
    	    viewGroupUsersAccessAll "Полный перечень пользователей системы:"
            return 1
    	#Пользователь $username не существует (конец)
    	fi
    #Конец проверки существования системного пользователя $username



}


###################################################################################################################
###################################################################################################################
###################################################################################################################
######BACKUPS





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
	        #tar_file_structure $3 $BACKUPFOLDER_IMPORTANT/$2/$1/$2_$1_$dt.tar.gz
	        tarFile $3 $BACKUPFOLDER_IMPORTANT/$2/$1/$2_$1_$dt.tar.gz str silent rewrite $1 users 644
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




###################################################################################################################
###################################################################################################################
###################################################################################################################
######ALLFUNCTIONS



########################################################### backup ###########################################################


########################################################### users ###########################################################


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

