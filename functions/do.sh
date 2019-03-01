#!/bin/bash


declare -x -f userAddSystem
#Выполенние операций по созданию системного пользователя
#$1-username ; $2-homedir ; $3-путь к интерпритатору команд ; $4 - основная группа пользователей; $5 - type (ssh/ftp), $6 - password, $7 системный пользователь, который выполняет команду
#return 1 - отпутствуют параметры, 2 -пользователь существует, 3 - каталог пользователя уже существует
#4 - интерпритатор не существует, 5 - группа не существует,6 - ошибка передачи параметра type
#7 - не существует системный пользователь, от которого запускается скрипт
userAddSystem() {
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


declare -x -f sshKeyGenerateToUser
#Генерация ssh-ключа для пользователя
#$1-user ; $2 - каталог пользователя
#return 0 - выполнено без ошибок, 1 - отсутствуют параметры запуска
#2 - нет указанного пользователя, 3 - отсутствует каталог пользователя
sshKeyGenerateToUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует
                #Проверка существования каталога "$2"
                if [ -d $2 ] ; then
                    #Каталог "$2" существует

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

                    #Каталог "$2" существует (конец)
                else
                    #Каталог "$2" не существует
                    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyGenerateToUser\"${COLOR_NC}"
                    return 3
                    #Каталог "$2" не существует (конец)
                fi
                #Конец проверки существования каталога "$2"

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


declare -x -f sshKeyAddToUser
#Добавление существующего ключа $2 пользователю $1
#$1-user ; $2-Если параметр равен 1, то запрос происходит в интерактивном режиме, если 0, то в тихом режиме ;
#3 - $3-путь к ключу ;
#return 1 - пользователь не существует, 2 - файл ключа не существует
#3- ошибка передачи параметра $3, 4 - не передан путь к файлу при тихом режиме
sshKeyAddToUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
    #Проверка существования системного пользователя "$1"
    	grep "^$1:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $1 существует
            #Проверка наличия параметра $2, равного 1
    		if [ "$2" == "1" ]
    		then
                 echo -e "\n${COLOR_YELLOW} Список возможных ключей для импорта: ${COLOR_NC}"
			     ls -l $SETTINGS/ssh/keys/
			     echo -n -e "${COLOR_BLUE} Укажите название открытого ключа, который необходимо применить к текущему пользователю: ${COLOR_NC}"
			     read  keyname
			     key=$SETTINGS/ssh/keys/$keyname
			     #Проверка существования файла "$key"
			     if ! [ -f $key ] ; then
			         #Файл "$key" не существует
			         echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$key\"${COLOR_RED} не существует. Выполнение операции прервано${COLOR_NC}"
			         return 2
			         break
			         #Файл "$key" не существует (конец)
			     fi
			     #Конец проверки существования файла "$key"
    		else
                if [ "$2" == "0" ]
                then
                    #Проверка на существование параметров запуска скрипта
                    if [ -n "$3" ]
                    then
                    #Параметры запуска существуют
                        #Проверка существования файла "$3"
                        if [ -f $3 ] ; then
                            #Файл "$3" существует
                            key=$3
                            #Файл "$3" существует (конец)
                        else
                            #Файл "$3" не существует
                            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                            return 2
                            break
                            #Файл "$3" не существует (конец)
                        fi
                        #Конец проверки существования файла "$3"
                    #Параметры запуска существуют (конец)
                    else
                    #Параметры запуска отсутствуют
                        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_RED} ${COLOR_NC}"
                        return 4
                        break
                    #Параметры запуска отсутствуют (конец)
                    fi
                    #Конец проверки существования параметров запуска скрипта
                else
                    echo -e "${COLOR_RED}"Ошибка передачи параметра $3"${COLOR_NC}"
                    return 3
                    break
                fi
    		fi

                 mkdirWithOwn $HOMEPATHWEBUSERS/$1/ $1 users 755
    		     mkdirWithOwn $HOMEPATHWEBUSERS/$1/.ssh $1 users 755
    		     DATE=`date '+%Y-%m-%d__%H-%M-%S'`
				 mkdirWithOwn $BACKUPFOLDER_IMPORTANT/ssh/$1 $1 users 755
				 cat $key >> $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys
				 echo "" >> $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys
				 tar_file_structure $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz
				 chModAndOwnFile $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz $1 users 644
				 chModAndOwnFile $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys $1 users 600
				 chown $1:users $HOMEPATHWEBUSERS/$1/.ssh
				 usermod -G ssh-access -a $1
				 echo -e "\n${COLOR_YELLOW} Импорт ключа ${COLOR_LIGHT_PURPLE}\"$key\"${COLOR_YELLOW} пользователю ${COLOR_LIGHT_PURPLE}\"$1\"${COLOR_YELLOW} выполнен${COLOR_NC}"
    		#Проверка наличия параметра $2, равного 1 (конец)

    	#Пользователь $1 существует (конец)
    	else
    	#Пользователь $1 не существует
    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
    		return 1
    	#Пользователь $1 не существует (конец)
    	fi
    #Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f sshkeyAdd_do #Добавление ключа ssh: ($1-username ; $2-mode(generate/insert/none) ; $3-mode(full_info/error_only/silent) ; $4- ; $5- ;)
#Добавление ключа ssh
#$1-username ; $2-mode(generate/insert/none) ; $3-mode(full_info/error_only/silent) ; $4- ; $5- ;
sshkeyAdd_do() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]  
	then
	#Параметры запуска существуют
		
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshkeyAdd_do\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}