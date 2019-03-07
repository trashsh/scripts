#!/bin/bash
####################################users########################
declare -x -f userAddSystem_input
declare -x -f userAddSystem
declare -x -f viewGroupUsersAccessAll
#Вывод всех пользователей группы users
###Полностью готово. Не трогать. 06.03.2019 г.
###input:
#$1 - может быть выведен дополнительно текст, предшествующий выводу списка пользователей
###return:
#0 - успешно,
#1 - неуспешно, параметр $1 передан,
#2 - неуспешно, параметр $1 не передан
#

declare -x -f viewUserFullInfo

declare -x -f viewUserGroups
#Вывод списка групп, в которых состоит пользователь $1
###Полностью готово. Не трогать. 06.03.2019 г.
###input:
#$1-user ;
###return:
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь $1 не найден

declare -x -f userExistInGroup
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

####################################mysql########################
declare -x -f dbSetMyCnfFile
declare -x -f dbUseradd
declare -x -f dbUseradd_input

####################################Архивация########################
declare -x -f tarFile

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
                                         useradd -N -g $4 -d $2/$1 -s $3 $1
                                         chown $1:$4 $2
                                         chmod 777 $2


                                        echo "$1:$6" | chpasswd

                                        dbSetMyCnfFile $1 $1 $6
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
				echo -e "${COLOR_YELLOW}Список групп, в которых состоит пользователь ${COLOR_GREEN}\""$1"\"${COLOR_NC}: "
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

##########################################BACKUPS################################################
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