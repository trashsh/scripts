#!/bin/bash

declare -x -f userAddSystem_old #Добавление системного пользователя: ($1-user ;)
#Готово. Можно добавить доп.функционал
#Добавление системного пользователя
#$1-user ;
#return 0 - выполнено успешно, 1 - пользователь уже существует
#2 - пользователь отменил создание пользователя
userAddSystem_old() {
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
                               # sed -i '$ a $SCRIPTS/menu'  $HOMEPATHWEBUSERS/$username/.bashrc
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
                                dbUpdateRecordToDb $WEBSERVER_DB db_users username $username comment "$username" update


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
