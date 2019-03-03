#!/bin/bash

############################users########################
declare -x -f userAddSystem
############################ssh########################
declare -x -f sshKeyGenerateToUser
declare -x -f sshKeyAddToUser

############################archive########################

declare -x -f tarFile ##архивация файла ($1-путь к исходному файлу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)
declare -x -f tarFolder ##архивация каталога ($1-путь к исходному каталогу ; $2-Путь к конечному архиву ; $3 - mode(str, str_rem, nostr, nostr_rem);  $4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога,error_only-выводятся только ошибки,silent - создается папка); $5 - mode(rewrite/norewrite); $6-Необязательно:имя владельца ; $7-Необязательно:группа владельца ; $8-Необязательно:права доступа ;)

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