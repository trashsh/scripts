#!/bin/bash
####################################users##########F##############
declare -x -f userAddSystem_input
declare -x -f userAddSystem
declare -x -f userAddToGroupSudo
declare -x -f viewGroupUsersAccessAll

declare -x -f viewUserFullInfo

declare -x -f viewUserGroups


declare -x -f userExistInGroup

declare -x -f existGroup

declare -x -f viewGroupAdminAccessAll
declare -x -f viewGroupAdminAccessByName
declare -x -f viewGroupSudoAccessAll
declare -x -f viewGroupSudoAccessByName
declare -x -f viewUserInGroupUsersByPartName
declare -x -f viewUserInGroupByName
declare -x -f viewUsersInGroup
declare -x -f userAddToGroup
declare -x -f userDeleteFromGroup
declare -x -f useraddFtp


####################################mysql########################
declare -x -f dbSetMyCnfFile
declare -x -f dbUseradd
declare -x -f dbUseradd_input
declare -x -f dbDropUser
declare -x -f dbCreateBase
declare -x -f dbDropBase
declare -x -f dbSetFullAccessToBase
declare -x -f dbViewUserGrant
declare -x -f dbShowTables
declare -x -f dbViewAllUsers
declare -x -f dbViewAllBases
declare -x -f dbViewBasesByTextContain
declare -x -f dbViewAllUsersByContainName
declare -x -f dbViewUserInfo
declare -x -f dbViewBasesByUsername
declare -x -f dbAddRecordToDb
declare -x -f dbDeleteRecordFromDb
declare -x -f dbExistTable
declare -x -f dbChangeUserPassword

####################################Архивация########################
declare -x -f tarFile
declare -x -f tarFolder



####################################Files################################
declare -x -f chModAndOwnFile
declare -x -f chOwnFolderAndFiles
declare -x -f chModAndOwnFolderAndFiles
declare -x -f touchFileWithModAndOwn
declare -x -f folderExistWithInfo
declare -x -f fileExistWithInfo
declare -x -f mkdirWithOwn

####################################webserver################################
declare -x -f webserverRestart
declare -x -f viewPHPVersion
declare -x -f viewSiteConfigsByName
declare -x -f viewSiteFoldersByName
####################################site#####################################
declare -x -f viewFtpAccess
declare -x -f viewSshAccess
declare -x -f siteAdd_php_input
declare -x -f siteAdd_php
declare -x -f siteRemove_input
declare -x -f siteRemove


############################ufw#############################
declare -x -f ufwAddPort
declare -x -f ufwOpenPorts

############################backups##########################################
declare -x -f backupImportantFile
declare -x -f dbBackupBase
declare -x -f dbBackupAllBases
declare -x -f dbBackupBasesOneUser
declare -x -f dbCheckExportedBase
declare -x -f backupSiteFiles
declare -x -f backupUserSitesFiles
###########################SSH-server########################################
declare -x -f sshKeyGenerateToUser
declare -x -f sshKeyAddToUser



#######################################USERS##########################################
#Добавление системного пользователя - ввод данных
###input:
#1 - имя добавляемого пользователя,
#2 - имя добавляющего пользователя
###return:
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - добавляющий пользователь $1 не существует
#3 - добавляемый пользователь $2 уже существует
#4 - пользователь отменил создание пользователя $1
#5 - пользователь не создан. Ошибка выполнения функции
userAddSystem_input() {

    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ]
    then
    #Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка на существование параметров запуска скрипта
        		if [ -n "$2" ]
        		then
        		#Параметры запуска существуют
                    #Проверка существования системного пользователя "$2"
                    	grep "^$2:" /etc/passwd >/dev/null
                    	if  [ $? -eq 0 ]
                    	then
                    	#Пользователь $2 существует
                    		echo -e "${COLOR_YELLOW}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_input\"${COLOR_YELLOW}  ${COLOR_NC}"
                    		return 3
                    	#Пользователь $2 существует (конец)
                    	else
                    	#Пользователь $2 не существует
                    	    username=$2
                    	#Пользователь $2 не существует (конец)
                    	fi
                    #Конец проверки существования системного пользователя $2
        		#Параметры запуска существуют (конец)
        		else
        		#Параметры запуска отсутствуют
        		    #Если запуск функции происходит без передачи параметров
                    echo -e "${COLOR_YELLOW}Список имеющихся системных пользователей:${COLOR_NC}"
                    viewGroupUsersAccessAll
                    echo -e -n "${COLOR_BLUE}"Введите имя пользователя: "${COLOR_NC}"
                    read username
                    #Проверка существования системного пользователя "$username"
                    	grep "^$username:" /etc/passwd >/dev/null
                    	if  [ $? -eq 0 ]
                    	then
                    	#Пользователь $username существует
                    		echo -e "${COLOR_YELLOW}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_input\"${COLOR_YELLOW}  ${COLOR_NC}"
                    		return 3
                    	#Пользователь $username существует (конец)
                    	fi
                    #Конец проверки существования системного пользователя $username
        		#Параметры запуска отсутствуют (конец)
        		fi
        		#Конец проверки существования параметров запуска скрипта

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
                                userAddSystem $username $HOMEPATHWEBUSERS/$username "/bin/bash" users ssh $password  $1
                            fi
                            #Проверка на пустое значение переменной (конец)

                            break
                            ;;
                        n|N)
                            echo -e "${COLOR_RED}Отмена создания пользователя ${COLOR_GREEN}\"$username\"${COLOR_NC}"
                            return 4
                            break
                            ;;
                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                           ;;
                    esac
                done

                #Проверка существования системного пользователя "$username"
                	grep "^$username:" /etc/passwd >/dev/null
                	if  [ $? -eq 0 ]
                	then
                	#Пользователь $username существует
                		echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$username\"${COLOR_GREEN} создан успешно.${COLOR_NC}"
                		return 0
                	#Пользователь $username существует (конец)
                	else
                	#Пользователь $username не существует
                	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не создан. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_input\"${COLOR_NC}"
                		return 5
                	#Пользователь $username не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $username


        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem_input\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}

#Выполенние операций по созданию системного пользователя
###input:
#$1-username ;
#$2-homedir ;
#$3-путь к интерпритатору команд ;
#$4 - основная группа пользователей;
#$5 - type (ssh/ftp),
#$6 - password,
#$7 системный пользователь, который выполняет команду
###return:
#0 - выполненоуспешно
#1 - отпутствуют параметры,
#2 -пользователь существует,
#3 - каталог пользователя уже существует
#4 - интерпритатор не существует,
#5 - группа не существует,
#6 - ошибка передачи параметра type
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
			echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Операция прервана. Функция ${COLOR_GREEN}\"userAddSystem\"${COLOR_RED}  ${COLOR_NC}"
			return 2
		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    #Проверка существования каталога "$2"
		    if [ -d $2 ] ; then
		        #Каталог "$2" существует
		        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует. Операция прервана. Функция ${COLOR_GREEN}\"userAddSystem\"${COLOR_RED}  ${COLOR_NC}"
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
                                         #sudo -s source /my/scripts/include/include.sh
                                         mkdir $2
                                         useradd -N -g $4 -d $2 -s $3 $1
                                         chown $1:$4 $2
                                         chmod 777 $2


                                        echo "$1:$6" | chpasswd

                                        #dbSetMyCnfFile $1 $1 $6
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
                                                    touchFileWithModAndOwn $2/.bashrc $1 $4 666
                                                    touchFileWithModAndOwn $2/.sudo_as_admin_successful $1 $4 644
                                                    echo "source /etc/profile" >> $2/.bashrc
                                                    sudo chmod 644 $2/.bashrc
                                                    #sed -i '$ a source $SCRIPTS/include/include.sh'  $2/.bashrc
                                                   # sed -i '$ a $SCRIPTS/menu'  $2/.bashrc
                                                    ;;
                                                ftp)
                                                    echo "ftp"
                                                    ;;
                                            esac
                                             ;;
                                        *)
                                            echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"type\"${COLOR_RED} в функцию ${COLOR_GREEN}\"userAddSystemo\"${COLOR_NC}";
                                            return 6
                                            ;;
                                     esac
                                    #Группа "$4" существует (конец)

                                    viewUserFullInfo $1
                                else
                                    #Группа "$4" не существует
                                    echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem\"${COLOR_NC}"
                                    return 5
                                    #Группа "$4" не существует (конец)
                                fi
                            #Конец проверки существования системного пользователя $4

		            	#Пользователь $7 существует (конец)
		            	else
		            	#Пользователь $7 не существует
		            	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$7\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem\"${COLOR_NC}"
		            		return 7
		            	#Пользователь $7 не существует (конец)
		            	fi
		            #Конец проверки существования системного пользователя $7
		            #интерпритатор "$3" существует (конец)
		        else
		            #интерпритатор "$3" не существует
		            echo -e "${COLOR_RED}Интерпритатор ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem\"${COLOR_NC}"
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


        return 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userAddSystem\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод всех пользователей группы users
###Полностью готово. Не трогать. 06.03.2019 г.
###input:
#$1 - может быть выведен дополнительно текст, предшествующий выводу списка пользователей
###return:
#0 - успешно,
#1 - неуспешно, параметр $1 передан,
#2 - неуспешно, параметр $1 не передан
viewGroupUsersAccessAll(){
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ]
    then
    #Параметры запуска существуют
        echo -e "${COLOR_YELLOW}$1${COLOR_NC}"
        cat /etc/passwd | grep ":100::" | highlight magenta ":100::"
        #Проверка на успешность выполнения предыдущей команды
        if [ $? -eq 0 ]
        	then
        		#предыдущая команда завершилась успешно
        		return  0
        		#предыдущая команда завершилась успешно (конец)
        	else
        		#предыдущая команда завершилась с ошибкой
        		return 1
        		#предыдущая команда завершилась с ошибкой (конец)
        fi
        #Конец проверки на успешность выполнения предыдущей команды
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        cat /etc/passwd | grep ":100::" | highlight magenta ":100::"
        #Проверка на успешность выполнения предыдущей команды
        if [ $? -eq 0 ]
        	then
        		#предыдущая команда завершилась успешно
        		return 0
        		#предыдущая команда завершилась успешно (конец)
        	else
        		#предыдущая команда завершилась с ошибкой
        		return 2
        		#предыдущая команда завершилась с ошибкой (конец)
        fi
        #Конец проверки на успешность выполнения предыдущей команды
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}

#Отображение полной информации о пользователе
###input:
#$1-user ;
###return:
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска функции
#2 - пользователь $1 не существует
viewUserFullInfo() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
			    viewUserGroups $1
				echo "Описать функцию viewUserFullInfo. Пользователь $1 существует"
				return 0
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"viewUserFullInfo\"${COLOR_NC}"
                return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUserFullInfo\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Вывод списка групп, в которых состоит пользователь $1
###Полностью готово. Не трогать. 06.03.2019 г.
###input:
#$1-user ;
###return:
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь $1 не найден
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
				#echo -e "${COLOR_YELLOW}Список групп, в которых состоит пользователь ${COLOR_GREEN}\""$1"\"${COLOR_NC}: "
		        grep "$1" /etc/group | highlight green "$1"

		        #Проверка наличия пользователя в группе users
		        userExistInGroup $1 users
		        #Проверка на успешность выполнения предыдущей команды
		        if [ $? -eq 0 ]
		        	then
		        		#предыдущая команда завершилась успешно
		        		echo -e "users:x:100:$1" | highlight green "$1"
		        		return 0
		        		#предыдущая команда завершилась успешно (конец)
		        fi
		        #Конец проверки на успешность выполнения предыдущей команды

				#предыдущая команда завершилась успешно (конец)
			else
				#предыдущая команда завершилась с ошибкой
				echo -e "${COLOR_RED}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_RED} не найден. Ошибка выполнения функции ${COLOR_YELLOW}\"viewUserGroups\"${COLOR_NC}"
				return 2
				#предыдущая команда завершилась с ошибкой (конец)
		fi
		#Конец проверки на успешность выполнения предыдущей команды
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUserGroups\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Функция проверяет состоит ли пользователь $1 в группе $2
###Полностью готово. Не трогать. 06.03.2019 г.
###input:
#$1-user
#$2-group
#$3{не обязательно} - если добавить параметр=1, тогда выведется сообщение о присутствии или отсутствии пользвоателя в группе
###return:
#0-если пользователь $1 состоит в группе "$2",
#1- не переданы параметры в функцию
#2 - пользователь $1 не существует
#3 - группа $2 не существует
#4 - пользователь $1 не входит в группу $2
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
				#Проверка существования системной группы пользователей "$2"
				if grep -q $2 /etc/group
				    then
				        #Группа "$2" существует
                        id $1 | grep -w $2 >/dev/null
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                            then
                                #предыдущая команда завершилась успешно
                                #Если передан параметр 3 и он равен 1
                                if [ "$3" == "1" ]
                                then
                                    echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$1 \"${COLOR_GREEN}входит в группу ${COLOR_YELLOW}\"$2\"${COLOR_GREEN} ${COLOR_NC}"
                                    return 0
                                fi

                                #предыдущая команда завершилась успешно (конец)
                            else
                                #предыдущая команда завершилась с ошибкой
                                #Если передан параметр 3 и он равен 1
                                if [ "$3" == "1" ]
                                then
                                    echo -e "${COLOR_RED}Пользователь ${COLOR_YELLOW}\"$1\"${COLOR_RED} не входит в группу ${COLOR_YELLOW}\"$2\" ${COLOR_NC}"
                                fi
                                return 4
                                #предыдущая команда завершилась с ошибкой (конец)
                        fi
				        #Группа "$2" существует (конец)
				    else
				        #Группа "$2" не существует
				        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userExistInGroup\"${COLOR_NC}"
				        return 3

						#Группа "$2" не существует (конец)
				    fi
				#Конец проверки существования системной группы пользователей $2

			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_YELLOW}\"$1 \"${COLOR_RED}не существует${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"UserExistInGroup\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Существует ли группа $1
#Полностью готово. 12.03.2019
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
				     echo -e "${COLOR_GREEN}Группа ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} существует${COLOR_NC}"
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


#Вывод всех пользователей группы admin-access
viewGroupAdminAccessAll(){
	echo -e "\n${COLOR_YELLOW}Список пользователей группы \"admin-access:\":${COLOR_NC}"
	more /etc/group | grep admin-access: | highlight magenta "admin-access"
}


#Вывод всех пользователей группы admin-access с указанием части имени пользователя
#Полностью готово. 13.03.2019
###input
#$1 - имя пользователя
###return
#1 - не переданы параметры
viewGroupAdminAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"admin-access\", содержащих в имени ${COLOR_GREEN}\"$1\"${COLOR_NC}"
		more /etc/group | grep -E "admin.*$1" | highlight green "$1" | highlight magenta "admin-access"
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewGroupAdminAccessByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

#Вывод всех пользователей группы sudo
#Полностью готово. 13.03.2019 г.
viewGroupSudoAccessAll(){
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"sudo\":${COLOR_NC}"
		more /etc/group | grep sudo: | highlight magenta "sudo"
}


#Вывод пользователей группы sudo с указанием части имени пользователя
#Полностью готово. 13.03.2019 г.
###input
#$1 - имя пользователя
###return
#1 - не переданы параметры в функцию
viewGroupSudoAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы ${COLOR_GREEN}\"sudo\"${COLOR_YELLOW}, содержащих в названии ${COLOR_GREEN}\"$1\"${COLOR_NC}:${COLOR_NC}"
		more /etc/group | grep sudo: | highlight green "$1" | highlight magenta "sudo"
	else
		echo -e "${COLOR_RED}Не передан параметр в функцию ${COLOR_GREEN}\"viewGroupSudoAccessByName\"${COLOR_RED} в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}


#Вывод списка пользователей, входящих в группу users по части имени пользователя $1
#Полностью готово. 13.03.2019
###input
#$1-часть имени
###return
#0 - выполнено успешно,
#1- отсутствуют параметры,
#2 - группа не существует
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
		else
			echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию viewUserInGroupByName в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
			return 1
		fi
}

#Вывод списка пользователей, входящих в группу $1
#Проверено полностью. 13.03.2019 г.
###input:
#$1-группа ;
#return
#0 - выполнено успешно,
#1- отсутствуют параметры,
#2 - группа не существует
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

#Добавить пользователя в группу
#Проверно полностью. 13.03.2019
###input:
#$1-user ;
#$2-группа;
#$3 - Если есть параметр 3, равный 1, то добавление происходит с запросом подтверждения, 0 - в тихом режиме
###return
#0 - успешно выполнено;
#1 - отсутствуют параметры,
#2 - не существует пользователь;
#3 - отмена пользователем
#4 - пользователь уже присутствует в группе $1,
#5 - ошибка в параметре функции,
#6 - не существует группа
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

#Добавление пользователя $1 в группу sudo
#Протестировано 15.03.2019
###РАБОТАЕТ
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
userAddToGroupSudo() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				usermod -a -G sudo $1
				return 0
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userAddToGroupSudo\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Удаление пользователя $1 из группы $2
#Полностью проверено. 13.03.2019
###input
#$1-user ;
#$2-group ;
#$3-mode: querry/silent
###return
#0 - пользователь удален;
#1 - не переданы параметры в функцию
#2 - пользователя $1 нет в группе $2;
#3 - группа $2 не существует;
#4 - отмена удаления пользователем
userDeleteFromGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
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

                        case "$3" in
                            silent)
                                gpasswd -d $1 $2;
                                return 0
                                ;;
                            querry)
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
                                            return 4
                                            #break
                                            ;;
                                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                           ;;
                                    esac
                                done
                                ;;
                        	*)
                        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"userDeleteFromGroup\"${COLOR_NC}";
                        	    ;;
                        esac


                        else
                            #предыдущая команда завершилась с ошибкой
                            echo -e "${COLOR_YELLOW}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} не присутствует в группе ${COLOR_GREEN}\"$2\"${COLOR_YELLOW}. Ошибка выполнения функции ${COLOR_GREEN}\"userDeleteFromGroup\" ${COLOR_NC}"
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
            return 4
		#Пользователь $1 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userDeleteFromGroup\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Добавление пользователя ftp
#Проверено полностью
###input
#$1-user ;
#$2-path ;
#$3-пароль
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - пользователь уже существует
#3 - каталог уже существует,
#4 - произошла ошибка при создании пользователя
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
#############################################MYSQL###############################################
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
                        dbAddRecordToDb lamer_webserver db_users username $1 insert
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
#Добавление пользователя mysql - форма ввода
###Полностью готово. Не трогать. 07.03.2019 г.
#$1 - какому системному пользователю принадлежит данная учетка mysql
#$2 - кто запускает выполнение данной функции
###return:
#0 - выполнено успешно
#1 - отсутствуют необходимые параметры
#2 - нет пользователя $1 в системе
#3 - нет пользователя $2 в системе
#4 - пользователь mysql уже существует
#5 - пустой пароль пользователя mysql

dbUseradd_input() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка существования системного пользователя "$2"
        			grep "^$2:" /etc/passwd >/dev/null
        			if  [ $? -eq 0 ]
        			then
        			#Пользователь $2 существует
                        read -p "Введите имя нового пользователя mysql: " username
                        #Проверка на существование пользователя mysql "$1\_$username"
                        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1_$username'" 2>&1`" ]];
                        then
                        #Пользователь mysql "$1\_$username" существует
                            echo -e "${COLOR_YELLOW}Пользователь mysql ${COLOR_GREEN}\"$1_$username\"${COLOR_YELLOW} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUseradd_input\"${COLOR_YELLOW}  ${COLOR_NC}"
                            return 4
                        #Пользователь mysql "$1\_$username" существует (конец)
                        else
                        #Пользователь mysql "$1\_$username" не существует
                            #TODO сделать проверку пароля в цикле while
                            #mysql user/passwd
                            echo -n -e "Пароль для пользователя MYSQL ${COLOR_YELLOW}" $1_$username "${COLOR_NC} сгенерировать или установить вручную? \nВведите ${COLOR_BLUE}\"y\"${COLOR_NC} для автогенерации, для ручного ввода - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                            while read
                            do
                                case "$REPLY" in
                                y|Y) password="$(openssl rand -base64 14)";
                                    # echo -e "${COLOR_GREEN}Пароль для пользователя mysql ${COLOR_YELLOW}$1_$username: ${COLOR_YELLOW}$password${COLOR_GREEN}  ${COLOR_NC}"
                                     break;;
                                n|N) echo -n -e "${COLOR_BLUE} Введите пароль для пользователя MYSQL ${COLOR_NC} ${COLOR_YELLOW}\"$1_$username\":${COLOR_NC}";
                                     read password;
                                     if [[ -z "$password" ]]; then
                                        #переменная имеет пустое значение
                                        echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя ${COLOR_GREEN}\"$1\_$username\""${COLOR_NC}"
                                        return 5
                                     fi
                                     break;;
                                esac
                            done

                            echo -n -e "${COLOR_YELLOW}Выберите вид доступа пользователя к базам данных mysql ${COLOR_GREEN}\"localhost/%\"${COLOR_NC}: "
                            	while read
                            	do
                                	echo -n ": "
                                	case "$REPLY" in
                            	    	localhost)
                                            host=localhost;
                            		    	break;;
                            		    %)
                                            host="%";
                            			    break;;
                            			*)
                            			     echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"dbUseradd_input\"${COLOR_YELLOW}Повторите ввод вида доступа пользователя ${COLOR_GREEN}\"localhost/%\":${COLOR_RED}  ${COLOR_NC}";;
                            	    esac
                            	done

                            	dbUseradd $1\_$username $password $host pass user $2


                        #Пользователь mysql "$1\_$username" не существует (конец) 
                        fi
                        #Конец проверки на существование пользователя mysql "$1\_$username"
        			#Пользователь $2 существует (конец)
        			else
        			#Пользователь $2 не существует
        			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED}, от чьего имени запускается функция ${COLOR_GREEN}\"dbUseradd_input\" не существует${COLOR_NC}"
                		return 3
        			#Пользователь $2 не существует (конец)
        			fi
        		#Конец проверки существования системного пользователя $2
        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUseradd_input\"${COLOR_NC}"
			    return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUseradd_input\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Удаление пользователя mysql
###Полностью готово. Не трогать. 07.03.2019 г.
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
                    echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}$1${COLOR_GREEN} удален ${COLOR_NC}"
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



#Создание базы данных $1
#Полностью готово. 14.03.2019
###input
#$1-dbname ;
#$2-CHARACTER SET (например utf8) ;
#$3-COLLATE (например utf8_general_ci) ;
#$4 - режим (normal/silent)

###return
#0 - выполнено успешно.
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


#Удаление базы данных mysql
###Полностью готово. Не трогать. 07.03.2019 г.
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
				mysql -e "GRANT ALL PRIVILEGES ON $1.* TO $2@$3 REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; FLUSH PRIVILEGES;"
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


#Вывод списка всех пользователей mysql
#Полностью готово 11.03.2019 г.
dbViewAllUsers() {
    echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL ${COLOR_NC}"
	mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user;"
}

#Вывод списка всех баз данных
#Полностью готово 11.03.2019 г.
dbViewAllBases() {
    echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL ${COLOR_NC}"
	mysql -e "show databases;"
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
					echo -e "${COLOR_LIGHT_RED}Базы данных, в имени которых содержится значение ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} отсутствуют${COLOR_NC}"
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

#Отобразить список всех пользователей mysql,содержащих в названии переменную $1
###input:
#$1-переменная для поиска пользователя ;
###return
#0 - выполнено успешно
#1 - отсутствуют параметры вызова функции
#2 - пользователи с заданным именем не существуют
dbViewAllUsersByContainName() {
	#Проверка на существование параметров запуска скрипта
		#Проверка на существование параметров запуска скрипта
		if [ -n "$1" ]
		then
		#Параметры запуска существуют
		    #проверка на пустой результат
		    		if [[ $(mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '%%$1%%' ORDER BY User ASC") ]]; then
		    			#непустой результат
		    			echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL, содержащих в названии ${COLOR_GREEN}\"$1\" $COLOR_NC"
		                mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '%%$1%%' ORDER BY User ASC"
		                return 0
		    			#непустой результат (конец)
		    		else
		    		    #пустой результат
		    			echo -e "${COLOR_LIGHT_RED}Пользователи, в имени которых содержится значение ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} отсутствуют. Ошибка вызова функциии ${COLOR_YELLOW}\"dbViewAllUsersByContainName\"${COLOR_NC}"
		    			return 2
		    			#пустой результат (конец)
		    		fi
		    #Конец проверки на пустой результат
		#Параметры запуска существуют (конец)
		else
		#Параметры запуска отсутствуют
		    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"dbViewAllUsersByContainName\"${COLOR_RED} ${COLOR_NC}"
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


#Отобразить список всех баз данных, владельцем которой является пользователь mysql $1_% (по имени)
#Полностью готово. 13.03.2019
###input
#$1-user;
#return
#0 - базы данных найдены,
#1 - не переданы параметры,
#2 - базы данных не найдены
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


#добавление записи в таблицу
#Полностью проверено. 13.03.2019
###input:
#$1-dbname ;
#$2-table;
#$3 - столбец для вставки;
#$4 - текст вставки;
#$5-подтверждение "insert"

###return
#0 - выполнено успешно
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


#обновление записи в таблице
#Полностью проверено. 13.03.2019
#ПРОТЕСТИРОВАНО
###input:
#$1-dbname ;
#$2-table;
#$3 - столбец для поиска;
#$4 - текст для поиска;
#$5 - обновляемый столбец,
#$6 - вставляемый текст,
#$7-подтверждение "update"
###return
#0 - выполнено успешно
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

#удаление записи из таблицы
#Полностью проверено. 13.03.2019
###input:
#$1-dbname ;
#$2-table;
#$3 - столбец;
#$4 - текст для поиска;
#$5-подтверждение "delete"
###return
#0 - выполнено успешно
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


##########################################BACKUPS################################################
#Создание бэкапа файлов сайта
#Полностью готово. Не трогать. Работает. 15.03.2019. Каталог по умолчанию в режиме querryCreateDestFolder при отсутствии папки все равно создается
###input
#$1-user ;
#$2-domain ;
#$3-mode:createDestFolder/querryCreateDestFolder
#$4-path destination;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#3 - каталог не существует,
#4 - пользователь отменил создание каталога
#5 - ошибка передачи параметра mode:createDestFolder/querryCreateDestFolder
#6 - ошибка при проверке заархивированного файла
backupSiteFiles() {
    d=$DATEFORMAT;
	dt=$DATETIMEFORMAT;
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
                                                mkdirWithOwn $4 $1 www-data 755;
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
                DESTINATION=$BACKUPFOLDER/vds/removed/$1/$2/$d
            #Параметры запуска отсутствуют (конец)
            fi
            #Конец проверки существования параметров запуска скрипта
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует (конец)


	        if ! [ -d $DESTINATION ] ; then
                        #Каталог "$DESTINATION" не существует
                        mkdirWithOwn $DESTINATION $1 www-data 755
                        #Каталог "$DESTINATION" не существует (конец)
            fi

            FILENAME=site.$1_$2_$dt.tar.gz
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
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Создание бэкапов файлов всех сайтов указанного пользователя
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

#Создание бэкапа в папку BACKUPFOLDER_IMPORTANT
###Полностью готово. Не трогать. 06.03.2019 г.
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
	dt=$DATETIMEFORMAT
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
                    #Проверка существования каталога "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1"
                    if ! [ -d "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1" ] ; then
                        sudo mkdir -p $BACKUPFOLDER_IMPORTANT/$2/$1
                    fi
                    #Проверка существования каталога "$BACKUPFOLDER_IMPORTANT"/"$2"/"$1" (конец)
                        tarFile $3 $BACKUPFOLDER_IMPORTANT/$2/$1/$2_$1_$dt.tar.gz str silent rewrite $1 users 644 && return 0 || return 4
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


#Создание бэкапа указанной базы данных
#Полностью готово. 14.03.2019
###input
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
                        FILENAME=$DESTINATIONFOLDER/mysql.$1-"$2"-$datetime

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
#Полностью проверено. 14.03.2019 г.
###input
#$1-user owner ;
#$2-owner group ;
#$3-разрешения на файл ;
#$4-mode:createfolder/nocreatefolder/querrycreatefolder ;
#$5-Каталог выгрузки ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - пользователь не существует,
#3 - группа не существует
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
#$1-user ;
#$2-owner group ;
#$3-разрешения на файл ;
#$4-mode:createfolder/nocreatefolder/querrycreatefolder ;
#$5-Каталог выгрузки ;
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - пользователь не существует,
#3 - группа не существует
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




#Создание бэкапа отдельной таблицы
#Полностью проверено.14.03.2019
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
		d=$DATEFORMAT;
	    dt=$DATETIMEFORMAT;
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
	    		    DESTINATION=$BACKUPFOLDER_DAYS/$user/$domain/$d
			        mkdir -p $DESTINATION
	    		#Параметры запуска отсутствуют (конец)
	    		fi
	    		#Конец проверки существования параметров запуска скрипта

	    		#пусть к файлу с бэкапом без расширения
        		FILENAME=$DESTINATION/mysqlTable-"$2"."$1"-$dt
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


#Проверка успешности выгрузки базы данных mysql $1 в архив $3
#Полностью проверно
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

#Смена пароля пользователю mysql
#Полностью проверено. 14.03.2019
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
                    #корректирование файла ~/.my.cnf
                    #Проверка на существование параметров запуска скрипта
                    if [ -n "$5" ]
                    then
                        #Проверка существования системного пользователя "$5"
                        	grep "^$5:" /etc/passwd >/dev/null
                        	if  [ $? -eq 0 ]
                        	then
                        	#Пользователь $5 существует
                        		dbSetMyCnfFile $5 $1 $3
                        	#Пользователь $5 существует (конец)
                        	else
                        	#Пользователь $5 не существует
                        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbChangeUserPassword\"${COLOR_NC}"
                        		return 3
                        	#Пользователь $5 не существует (конец)
                        	fi
                        #Конец проверки существования системного пользователя $5

                    #Параметры запуска существуют (конец)
                    fi
                    #Конец проверки существования параметров запуска скрипта
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

#######################################Архивация######################################

#архивация файла
###Полностью готово. Не трогать. 06.03.2019 г.
###input:
#$1-путь к исходному файлу ;
#$2-Путь к конечному архиву ;
#$3 - mode(str, str_rem, nostr, nostr_rem);
#$4 - mode (full_info-папка не создается, но показывается и успешный результат,
#           querry-запрашивается создание каталога,
#           error_only-выводятся только ошибки,
#           silent - создается папка);
#$5 - mode(rewrite/norewrite);
#$6-Необязательно:имя владельца ;
#$7-Необязательно:группа владельца ;
#$8-Необязательно:права доступа ;)
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - отсутствует исходный файл,
#3 - отсутствует каталог назначения,
#4 -неправильно указаны параметры (str, str_rem, nostr, nostr_rem),
#5 - неправильно указаны параметры  mode (full_info,querry,silent,error_only), ошибка значения переменной $showSuccessResult
#6 - не существует пользователь системы,
#7 - не существует группа,
#8 - финальная проверка существования файла завершилась с ошибкой
#9 - ошибка передачи параметра Mode (rewrite/norewrite),
#10 - файл $2 уже существует, а из-за параметра 9(norewrite) не будет перезаписан
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
		            sudo mkdir -p $folder
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
		                                sudo mkdir -p $folder;
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
                    sudo tar -czpf $2 -P $1
		            ;;
		        str_rem)
                    sudo tar -czpf $2 -P $1 --remove-files
		            ;;
		    	nostr)
                    cd `dirname $1` && sudo tar -czpf $2 `basename $1`
		    		;;
		    	nostr_rem)
                    cd `dirname $1` && sudo tar -czpf $2 `basename $1` --remove-files
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
                                sudo chmod $8 $2
                                sudo chown $6:$7 $2
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
###input:
#$1-путь к исходному каталогу ;
#$2-Путь к конечному архиву ;
#$3 - mode(str, str_rem, nostr, nostr_rem);
#$4 - mode (full_info-папка не создается, но показывается и успешный результат,querry-запрашивается создание каталога и выводится результат,error_only-выводятся только ошибки,silent - создается папка);
#$5 - mode(rewrite/norewrite);
#$6-Необязательно:имя владельца ;
#$7-Необязательно:группа владельца ;
#$8-Необязательно:права доступа ;)
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - отсутствует исходный каталог,
#3 - отсутствует каталог назначения,
#4 -неправильно указаны параметры (str, str_rem, nostr, nostr_rem),
#5-неправильно указаны параметры  mode (full_info,querry,silent,error_only), ошибка значения переменной $showSuccessResult
#6 - не существует пользователь системы,
#7 - не существует группа,
#8 - финальная проверка существования файла завершилась с ошибкой
#9 - ошибка передачи параметра Mode (rewrite/norewrite),
#10 - файл $2 уже существует, а из-за параметра 9(norewrite) не будет перезаписан
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


########################################FILES###############################################
#Смена владельна и прав доступа на файл
###input
#$1-путь к файлу ;
#$2-user ;
#$3-group ;
#$4-права доступа на файл ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - отсутствует файл
#3 - отсутствует пользователь,
#4 - отсутствует группа
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
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}${COLOR_NC}"
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

#Создание папки и применение ей владельца и прав доступа
###input
#$1-путь к папке ;
#$2-user ;
#$3-group ;
#$4-разрешения ;
###return
#0 - выполнено успешно,
#1 - не переданы параметры,
#2 - пользователь не существует,
#3 - группа не существует
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
		    		            mkdir -p $1
		    		            chmod $4 $1
				                chown $2:$3 $1
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
###input
#$1-path ;
#$2-user;
#$3-group
###return
#0 - выполнено успешно,
#1 - каталог не существует,
#2 - пользователь не существует,
#3 - группа не существует
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
         	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_NC}"
         		return 2
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
###input
#$1-путь к файлу ;
#$2-user ;
#$3-group ;
#$4-права доступ ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - пользователь не существует,
#3 - группа не существует,
#4 - файл существовал, применены лишь права
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


#проверка существования папки с выводом информации о ее существовании
###Полностью готово. 13.03.2019
###input
#$1-path ;
#$2-type (create/exist)
###return
#1 - не переданы параметры,
#2 - ошибка передачи параметров
#3 - каталог не создан,
#4 -каталог создан,
#5 - каталог не существует,
#6 - каталог существует
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
###Полностью готово. 13.03.2019
#$1-path,
#$2-type (create/exist)
#return
#1 - не переданы параметры,
#2 - ошибка передачи параметров
#3 - файл не создан,
#4 -файл создан,
#5 - файл не существует,
#6 - файл существует
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

##########################################site##########################################################
#отобразить реквизиты доступа к серверу FTP
#Полностью готово. 13.03.2019 г.
###input
#$1 - user;
#$2 - password,
#$3 - port,
#$4 - сервер
###return
#0 - выполнено успешно,
#1 - не переданы параметры
viewFtpAccess(){
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты FTP-Доступа" ${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" $4 "${COLOR_NC}"
		echo -e "Порт ${COLOR_YELLOW}" $3 "${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Пароль: ${COLOR_YELLOW}" $2 "${COLOR_NC}"
		echo $LINE
		return 0
	else
		echo -e "${COLOR_RED}Не переданы параметры в функцию ${COLOR_GREEN}\"viewFtpAccess\"${COLOR_RED}. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}

#отобразить реквизиты доступа к серверу SSH
###input
#$1 - user
#$2 - сервер
#$3 - порт
###return
#0 - выполнено успешно,
#1 - отсутствуеют параметры
viewSshAccess(){
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты SSH-Доступа" ${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" $2 "${COLOR_NC}"
		echo -e "Порт ${COLOR_YELLOW}" $3 "${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo $LINE
		return 0
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию ${COLOR_GREEN}\"viewSshAccess\"${COLOR_NC}"
		return 1
	fi
}


##########################################ssh-server######################################################
#Генерация ssh-ключа для пользователя
#Полностью проверено. 14.03.2019
###input
#$1-user ;
#$2 - домашний каталог пользователя
###return
#0 - выполнено без ошибок,
#1 - отсутствуют параметры запуска
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
                           # tar_folder_structure
                            tarFolder $2/.ssh/ $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_backuped_$DATE.tar.gz str error_only rewrite $1 users 644
                            #Каталог "$2/.ssh" существует (конец)
                        fi
                    #Конец проверки существования каталога "$2/.ssh"
                        #mkdir -p $2/.ssh
                        mkdirWithOwn $2/.ssh $1 users 766
                        cd $2/.ssh
                        echo -e "\n${COLOR_YELLOW} Генерация ключа. Сейчас необходимо будет установить пароль на ключевой файл.Минимум - 5 символов${COLOR_NC}"
                        ssh-keygen -t rsa -f ssh_$1 -C "ssh_$1 ($DATE_TYPE2)"
                        #echo -e "\n${COLOR_YELLOW} Конвертация ключа в формат программы Putty. Необходимо ввести пароль на ключевой файл, установленный на предыдушем шаге ${COLOR_NC}"
                        puttygen $2/.ssh/ssh_$1 -C "ssh_$1 ($DATE_TYPE2)" -o $2/.ssh/ssh_$1.ppk
                        mkdirWithOwn $BACKUPFOLDER_IMPORTANT/ssh/$1 $1 users 766
                        cat $2/.ssh/ssh_$1.pub >> $2/.ssh/authorized_keys
                        tarFolder $2/.ssh/ $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_generated_$DATE.tar.gz str error_only rewrite $1 users 644
                        chModAndOwnFile $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_generated_$DATE.tar.gz $1 users 644
                        chown $1:users $2/.ssh/*
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
#ПРОТЕСТИРОВАНО
#Полностью готово. 14.03.2019
#$1-user ;
#2 - group;
#$3 - путь к ключу ;
#$4 - домашний каталог пользователя
#return
#0 - выполнено успешно
#1 - отсутствуют параметры,
#2 - пользователь не существует,
#3 - группа не существует
#4 - ключ не найден,
#5 - каталог не найден,
#6 - не выполнена финальная провека существования файла $4/.ssh/authorized_keys
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



#Форма ввода для добавления сайта php
###input
#$1-username
###return
#0 - выполнено успешно
#1 - не переданы параметры
#2 - не существует пользователь
siteAdd_php_input() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
                	echo "--------------------------------------"
                    echo "Добавление виртуального хоста."
                    if ! [ -d $HOMEPATHWEBUSERS/$1/ ]; then
                        sudo mkdir -p $HOMEPATHWEBUSERS/$1
                    fi

                    echo -e "${COLOR_YELLOW}Список имеющихся доменов:${COLOR_NC}"

                    ls $HOMEPATHWEBUSERS/$1
                    echo -n -e "${COLOR_BLUE} Введите домен для добавления ${COLOR_NC}: "
                    read domain
                    site_path=$HOMEPATHWEBUSERS/$1/$domain
                    echo ''
                    echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

                    ls $TEMPLATES/apache2/
                    echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
                    echo -n ": "
                    read apache_config
                    echo ''
                    echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
                    ls $TEMPLATES/nginx/
                    echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
                    echo -n ": "
                    read nginx_config
                    echo ''
                    echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
                    echo -n ": "
                    read item
                    case "$item" in
                        y|Y) echo
                            #
                            bash -c "source $SCRIPTS/include/inc.sh; siteAdd_php $1 $domain $site_path $apache_config $nginx_config" ; echo $?;
                            exit 0
                            ;;
                        *) echo "Выход..."
                            exit 0
                            ;;
                    esac
        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php_input\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAdd_php_input\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}

#Добавление php-сайта
###input
#$1-username ;
#$2-domain ;
#$3-site_path ;
#$4-apache_config ;
#$5-nginx_config ;
###return
#0 - выполнено успешно
#1 - отсутствуют параметры
#2 - пользователь $1 не  существует
#3 - конфигурация apache не существует
#4 - конфигурация nginx не существует
#5 - каталог сайта уже существует
siteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка существования файла "$TEMPLATES/apache2/$4"
        		if [ -f $TEMPLATES/apache2/$4 ] ; then
        		    #Файл "$TEMPLATES/apache2/$4" существует
        		    #Проверка существования файла "$TEMPLATES/nginx/$5"
        		    if [ -f $TEMPLATES/nginx/$5 ] ; then
        		        #Файл "$TEMPLATES/nginx/$5" существует
                        #Проверка существования каталога "$3"
                        if [ -d $3 ] ; then
                            #Каталог сайта "$3" уже существует
                            echo -e "${COLOR_RED}Каталог сайта ${COLOR_GREEN}\"$3\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
                            #Каталог сайта "$3" уже существует (конец)
                        else
                            #Каталог сайта "$3" не существует

                            echo "Добавление веб пользователя $1_$2 с домашним каталогом: $3 для домена $2"
                            sudo mkdir -p $3
                            sudo useradd $1_$2 -N -d $3 -m -s /bin/false
                            sudo adduser $1_$2 www-data
                            echo -e "${COLOR_YELLOW}Установка пароля для ftp-пользователя \"$1_$2\"${COLOR_NC}"
                            sudo passwd $1_$2
                            sudo cp -R /etc/skel/* $3

                           #copy index.php
                           sudo cp $TEMPLATES/index_php/index.php $3/$WWWFOLDER/index.php
                           sudo cp $TEMPLATES/index_php/underconstruction.jpg $3/$WWWFOLDER/underconstruction.jpg
                           sudo grep '#__DOMAIN' -P -R -I -l  $3/$WWWFOLDER/index.php | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' $3/$WWWFOLDER/index.php
                     #       sed -i 's/#__DOMAIN/$2' $3/$WWWFOLDER/index.php


                           #nginx
                           sudo cp -rf $TEMPLATES/nginx/$5 /etc/nginx/sites-available/"$1"_"$2".conf
                           sudo chmod 644 /etc/nginx/sites-available/"$1"_"$2".conf
                           sudo echo "Замена переменных в файле /etc/nginx/sites-available/"$1"_"$2".conf"
                           sudo grep '#__DOMAIN' -P -R -I -l  /etc/nginx/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' /etc/nginx/sites-available/"$1"_"$2".conf
                           sudo grep '#__USER' -P -R -I -l  /etc/nginx/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__USER/'$1'/g' /etc/nginx/sites-available/"$1"_"$2".conf
                           sudo grep '#__PORT' -P -R -I -l  /etc/nginx/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__PORT/'$HTTPNGINXPORT'/g' /etc/nginx/sites-available/"$1"_"$2".conf
                           sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/nginx/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/'#__HOMEPATHWEBUSERS'/\/home\/webusers/g' /etc/nginx/sites-available/"$1"_"$2".conf

                           sudo  ln -s /etc/nginx/sites-available/"$1"_"$2".conf /etc/nginx/sites-enabled/"$1"_"$2".conf
                           sudo  systemctl reload nginx

                            #apache2
                            sudo cp -rf $TEMPLATES/apache2/$4 /etc/apache2/sites-available/"$1"_"$2".conf
                            chmod 644 /etc/apache2/sites-available/"$1"_"$2".conf
                            sudo echo "Замена переменных в файле /etc/apache2/sites-available/"$1"_"$2".conf"
                            sudo grep '#__DOMAIN' -P -R -I -l  /etc/apache2/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' /etc/apache2/sites-available/"$1"_"$2".conf
                            sudo grep '#__USER' -P -R -I -l  /etc/apache2/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__USER/'$1'/g' /etc/apache2/sites-available/"$1"_"$2".conf
                            sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/apache2/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__HOMEPATHWEBUSERS/\/home\/webusers/g' /etc/apache2/sites-available/"$1"_"$2".conf
                            sudo grep '#__PORT' -P -R -I -l  /etc/apache2/sites-available/"$1"_"$2".conf | sudo xargs sed -i 's/#__PORT/'$HTTPAPACHEPORT'/g' /etc/apache2/sites-available/"$1"_"$2".conf

                            sudo a2ensite "$1"_"$2".conf
                            sudo service apache2 reload

                            #chmod
                            sudo find $3 -type d -exec chmod 755 {} \;
                            sudo find $3/$WWWFOLDER -type d -exec chmod 755 {} \;
                            sudo find $3 -type f -exec chmod 644 {} \;
                            sudo find $3/$WWWFOLDER -type f -exec chmod 644 {} \;
                            sudo find $3/logs -type f -exec chmod 644 {} \;

                            sudo chown -R $1:www-data $3/logs
                            sudo chown -R $1:www-data $3/$WWWFOLDER
                            sudo chown -R $1:www-data $3/tmp

                            cd $3/$WWWFOLDER
                            echo -e "\033[32m" Инициализация Git "\033[0;39m"
                            git init
                            git add .
                            git commit -m "initial commit"

                            echo -e "==========================================="
                            echo -e "Сайт доступен по адресу: ${COLOR_YELLOW} Параметры подключения к сайту ${COLOR_NC} (nginx)"
                            echo -e "Сайт доступен по адресу: ${COLOR_YELLOW} http://"$2" ${COLOR_NC} (nginx)"
                            echo -e "Сайт доступен по адресу: ${COLOR_YELLOW} http://"$2":8080 ${COLOR_NC} (apache)"
                            echo -e "Сервер FTP: ${COLOR_YELLOW} "$2":10081 ${COLOR_NC}"
                            echo -e "FTP User: ${COLOR_YELLOW} $1_$2 ${COLOR_NC}"
                            echo -e "PhpMyAdmin: ${COLOR_YELLOW} https://conf.mmgx.ru/dbase ${COLOR_NC}"
                            echo -e "Adminer: ${COLOR_YELLOW} https://conf.mmgx.ru/a ${COLOR_NC}"
                            echo -e "MYSQL User: ${COLOR_YELLOW} $1_$2 ${COLOR_NC}"
                            echo -e "MYSQL DB: ${COLOR_YELLOW} $1_$2 ${COLOR_NC}"

                            #Каталог сайта "$3" не существует (конец)
                        fi
                        #Конец проверки существования каталога "$3"

        		        #Файл "$TEMPLATES/nginx/$5" существует (конец)
        		    else
        		        #Файл "$TEMPLATES/nginx/$5" не существует
        		        echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		        return 4
        		        #Файл "$TEMPLATES/nginx/$5" не существует (конец)
        		    fi
        		    #Конец проверки существования файла "$TEMPLATES/nginx/$5"

        		    #Файл "$TEMPLATES/apache2/$4" существует (конец)
        		else
        		    #Файл "$TEMPLATES/apache2/$4" не существует
        		    echo -e "${COLOR_RED}Конфигурация apache2 ${COLOR_GREEN}\"$TEMPLATES/apache2/$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		    return 3
        		    #Файл "$TEMPLATES/apache2/$4" не существует (конец)
        		fi
        		#Конец проверки существования файла "$TEMPLATES/apache2/$4"

        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#удаление сайта
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
siteRemove_input() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo "--------------------------------------"
                echo "Удаление виртуального хоста:"
                echo "Список имеющихся доменов для пользователя $1:"
                ls $HOMEPATHWEBUSERS/$1
                echo ''
                echo -n "Введите домен для удаления: "
                read domain
                path=$HOMEPATHWEBUSERS/$1/$domain
                echo ''

                bash -c "source $SCRIPTS/include/inc.sh; siteRemove_input $domain $path $1";
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteRemove_input\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemove_input\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}


#Удаление сайта
###input
#$1-domain ;
#$2-path ;
#$3-user ;
#$4-mode:createbackup/nocreatebackup ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не найден каталог сайта $2
#3 - ошибка передачи параметра mode:createbackup/nocreatebackup
siteRemove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
        #Проверка существования каталога "$2"
        if [ -d $2 ] ; then
            #Каталог "$2" существует
            case "$4" in
                createbackup)

                    break
                    ;;
                nocreatebackup)
                    break
                    ;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: createbackup/nocreatebackup\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteRemove\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            #Каталог "$2" существует (конец)
        else
            #Каталог "$2" не существует
            echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteRemove\"${COLOR_NC}"
            return 2
            #Каталог "$2" не существует (конец)
        fi
        #Конец проверки существования каталога "$2"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



##########################################webserver#######################################################
#Перезапуск Веб-сервера
#Полностью готово. 13.03.2019
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

#Вывод перечня сайтов указанного пользователя (конфиги веб-сервера)
###input
#$1 - имя пользователя
###return
#0 - выполнено успешно,
#1 - не передан параметр,
#2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
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
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"viewSiteConfigsByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

#Вывод перечня сайтов указанного пользователя
###input
# $1 - имя пользователя
###return
#0  - выполнено успешно,
#1 - не передан параметр,
#2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
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
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"viewSiteFoldersByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

############################ufw########################################
#Добавление порта с исключением в firewall ufw
###input
#$1-port ;
#$2-protocol ;
#$3-комментарий ;
###return
#0 - выполнено успешно,
#1 - не переданы параметры,
#2 - ошибка добавления правила
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


#Вывод открытых портов ufw
ufwOpenPorts() {
    netstat -ntulp
}














