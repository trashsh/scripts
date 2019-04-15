#!/bin/bash

declare -x -f input_dbUseradd
#Запрос имени пользователя для добавления пользователя mysql (основного пользователя)
###input
#$1 - системный пользователь, запускающий функцию
#$2 - mode (main/dop/dop_querry) - основной или дополнительный пользователь или дополнительный пользователь с запросом основного
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь уже существует
#3 - операция отменена пользователем
#4 - ошибка передачи параметра mode (main/dop/dop_querry)
#5 - основной пользователь mainUser не существует
input_dbUseradd() {
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ]
    then
    #Параметры запуска существуют

        clear
        echo -e "${COLOR_GREEN}"Добавление пользователя mysql"${COLOR_NC}"
        dbViewAllUsers

        case "$2" in
            main)
                echo -n -e "${COLOR_BLUE}\nВведите имя пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для добавления его в пользователи mysql: ${COLOR_NC}"
                read user
                username=$user
                ;;
            dop)
                echo -n -e "${COLOR_BLUE}\nВведите имя пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для добавления его в пользователи mysql \"${COLOR_YELLOW}$1--${COLOR_GREEN}User\"${COLOR_BLUE}: ${COLOR_NC}"
                read user
               mainUser=$1
               username=$mainUser--$user
                ;;
            dop_querry)
                  echo -n -e "${COLOR_BLUE}\nВведите имя основного пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для которого будет создан допонительный пользователь: ${COLOR_NC}"
                  read mainUser
                  #Проверка существования системного пользователя "$mainUser"
                  	grep "^$mainUser:" /etc/passwd >/dev/null
                  	if  [ $? -eq 0 ]
                  	then
                  	#Пользователь $mainUser существует
                  	    echo -n -e "${COLOR_BLUE}\nВведите имя пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для добавления его в пользователи mysql \"${COLOR_YELLOW}$mainUser--${COLOR_GREEN}User\"${COLOR_BLUE}: ${COLOR_NC}"
                  	    read user
                  		username=$mainUser--$user
                  	#Пользователь $mainUser существует (конец)
                  	else
                  	#Пользователь $mainUser не существует
                  	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$mainUser\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_NC}"
                  		return 5
                  	#Пользователь $mainUser не существует (конец)
                  	fi
                  #Конец проверки существования системного пользователя $mainUser
                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_NC}";
        	    return 4
        	    ;;
        esac


        #Проверка на существование пользователя mysql "$username"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
        then
        #Пользователь mysql "$username" существует
            clear
            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} уже существует.${COLOR_NC}"
            return 2
        #Пользователь mysql "$username" существует (конец)
        else
        #Пользователь mysql "$username" не существует
            echo -n -e "${COLOR_YELLOW}Для добавления пользователя mysql ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены добавления  - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                while read
                do
                    case "$REPLY" in
                        y|Y)

                            echo -n -e "Пароль для пользователя MYSQL ${COLOR_YELLOW}" $username "${COLOR_NC} сгенерировать или установить вручную? \nВведите ${COLOR_BLUE}\"y\"${COLOR_NC} для автогенерации, для ручного ввода - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                while read
                                do
                                    case "$REPLY" in
                                    y|Y) password="$(openssl rand -base64 14)";
                                        # echo -e "${COLOR_GREEN}Пароль для пользователя mysql ${COLOR_YELLOW}$usernameFull: ${COLOR_YELLOW}$password${COLOR_GREEN}  ${COLOR_NC}"
                                         break;;
                                    n|N) echo -n -e "${COLOR_BLUE} Введите пароль для пользователя MYSQL ${COLOR_NC} ${COLOR_YELLOW}\"$username\":${COLOR_NC}";
                                         read password;
                                         if [[ -z "$password" ]]; then
                                            #переменная имеет пустое значение
                                            echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя ${COLOR_GREEN}\"$username\""${COLOR_NC}"
                                            return 5
                                         fi
                                         break;;
                                    esac
                                done

                                host=localhost;
#                                echo -n -e "${COLOR_YELLOW}Выберите вид доступа пользователя к базам данных mysql ${COLOR_GREEN}\"localhost/%\"${COLOR_NC}: "
#                                    while read
#                                    do
#                                        case "$REPLY" in
#                                            localhost)
#                                                host=localhost;
#                                                break;;
#                                            %)
#                                                host="%";
#                                                break;;
#                                            *)
#                                                 echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_YELLOW}\nПовторите ввод вида доступа пользователя ${COLOR_GREEN}\"localhost/%\":${COLOR_RED}  ${COLOR_NC}";;
#                                        esac
#                                done

                                dbUseradd $username $password $host pass user $1

                                dbSetMyCnfFile $HOMEPATHWEBUSERS/$username $username $password $username



                                case "$2" in
                                    main)
                                        param1=0
                                        ;;
                                    dop|dop_querry)
                                        param1=1
                                        ;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка доп.проверки параметра ${COLOR_GREEN}\"mode (main/dop/dop_querry)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_NC}";
                                	    ;;
                                esac


                                clear
                                echo -e "${COLOR_GREEN}Пользователь mysql ${COLOR_YELLOW}\"$username\"${COLOR_GREEN} успешно добавлен${COLOR_YELLOW}\"\"${COLOR_GREEN}  ${COLOR_NC}"
                                dbViewAllUsers
                                #dbCreateBase $username utf8 utf8_general_ci full_info

                            break
                            ;;
                        n|N)
                            echo -e "${COLOR_YELLOW}Отмена создания пользователя mysql ${COLOR_GREEN}\"$username\"${COLOR_YELLOW}${COLOR_NC}"
                            return 3;
                            break
                            ;;
                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                           ;;
                    esac
                done
        #Пользователь mysql "$$username" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$$username"


    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта

}

declare -x -f input_dbUserChangeAccess
#запрос имени пользователя для того, чтобы сделать из пользователя администратора
###input
#$1-type (user/admin/adminGrant) ;
#$2 - host
#$3-username - не обязательно
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#4 - пользователь $3 не существует
#3 - ошибка type (user/admin/adminGrant)
input_dbUserChangeAccess() {
	dbViewAllUsers

	#Проверка на существование параметров запуска скрипта
	if [ -n "$3" ]
	then
	#Параметры запуска существуют
	    #Проверка на существование пользователя mysql "$3"
	    if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$3'" 2>&1`" ]];
	    then
	    #Пользователь mysql "$3" существует
	        username=$3
	    #Пользователь mysql "$3" существует (конец)
	    else
	    #Пользователь mysql "$3" не существует
	        echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserChangeAccess\" ${COLOR_NC}"
	        return 4
	    #Пользователь mysql "$3" не существует (конец)
	    fi
	    #Конец проверки на существование пользователя mysql "$3"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql для смены типа доступа: ${COLOR_NC}"
	        read username

	        #Проверка на существование пользователя mysql "$username"
	        if [[ -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
	        then
	        #Пользователь mysql "$username" не существует
	            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserChangeAccess\" ${COLOR_NC}"
	            return 4
	        #Пользователь mysql "$username" не существует (конец)
	        fi
	        #Конец проверки на существование пользователя mysql "$username"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта



	#Проверка на существование параметров запуска скрипта
	if [ -n "$2" ]
	then
	#Параметры запуска существуют
	    host=$2
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
        echo -n -e "${COLOR_YELLOW}Выберите вид доступа пользователя к базам данных mysql ${COLOR_GREEN}\"localhost/%\"${COLOR_NC}: "
                                    while read
                                    do
                                        case "$REPLY" in
                                            localhost)
                                                host=localhost;
                                                break;;
                                            %)
                                                host="%";
                                                break;;
                                            *)
                                                 echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"input_dbUserChangeAccess\"${COLOR_YELLOW}\nПовторите ввод вида доступа пользователя ${COLOR_GREEN}\"localhost/%\":${COLOR_RED}  ${COLOR_NC}";;
                                        esac
                                done
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        typeAccess=$1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -n -e "${COLOR_YELLOW}Введите тип доступа для пользователя.${COLOR_GREEN}1${COLOR_YELLOW}-admin grant, ${COLOR_GREEN}2${COLOR_YELLOW}-admin, ${COLOR_GREEN}3${COLOR_YELLOW}-user${COLOR_NC}: "
	    read typeAccess
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	dbUserChangeAccess $typeAccess $host $username
	dbViewAllUsers
}

declare -x -f input_dbUserDelete_querry
#Запрос имени пользователя mysql на удаление
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###input
#$1 - username - необязательно
###return
#0 - выполнено успешно
#2 - пользователь mysql не существует
#3 - операция отменена пользователем
input_dbUserDelete_querry() {
    clear
    echo -e "${COLOR_GREEN}Удаление пользователя mysql ${COLOR_NC}"
    dbViewAllUsers
    d=`date +%Y.%m.%d`

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    username=$1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql для его удаления: ${COLOR_NC}"
	    read username
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	#Проверка на существование пользователя mysql "$username"
	if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
	then
	#Пользователь mysql "$username" существует
        echo -n -e "${COLOR_YELLOW}Подтвердите удаление mysql-пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите для удаления ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
            while read
            do
                case "$REPLY" in
                    y|Y)
                        sudo bash -c "source $SCRIPTS/include/inc.sh; mkdirWithOwn $path $USERLAMER users 755"
                        dbBackupBasesOneUser $username full_info data NoDeleteBase
                        clear;
                        dbUserdel $username drop; dbViewAllUsers; menuUserMysql $1;
                        return 0;
                        break
                        ;;
                    n|N)
                        echo -e "${COLOR_YELLOW}Операция отменена пользователем${COLOR_NC}";
                        menuUserMysql $1;
                        return 3;
                        break
                        ;;
                    *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                       ;;
                esac
            done
	#Пользователь mysql "$username" существует (конец)
	else
	#Пользователь mysql "$username" не существует
	    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserDelete_querry\" ${COLOR_NC}"
	    input_dbUserDelete_querry $username
	    return 2
	#Пользователь mysql "$username" не существует (конец)
	fi
	#Конец проверки на существование пользователя mysql "$username"
}

declare -x -f input_dbChangeUserPassword
#запрос данных для смены пароля пользователя mysql
###input
#$1-имя системного пользователя;
###return
#0 - выполнено успешно
#1 - пользователь mysql не существует
#2 - пароль пустой. отмена выполнения
#3 - произошла ошибка при смене пароля
input_dbChangeUserPassword() {
    dbViewAllUsers
    echo -e "${COLOR_GREEN}Смена пароля на пользователя mysql: ${COLOR_NC}"
	echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql: ${COLOR_NC}"
	read username
	#Проверка на существование пользователя mysql "$username"
	if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
	then
	#Пользователь mysql "$username" существует
        echo -n -e "${COLOR_BLUE}Введите новый пароль для пользователя ${COLOR_YELLOW}\"$username\"${COLOR_BLUE}: ${COLOR_NC}"
	    read password
	    if [[ -z "$password" ]]; then
             #переменная имеет пустое значение
              echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена смены пароля пользователя ${COLOR_GREEN}\"$username\""${COLOR_NC}"
              return 2
        else
            echo -n -e "${COLOR_BLUE}Введите хост  ${COLOR_YELLOW}\"(localhost/%)\"${COLOR_BLUE}: ${COLOR_NC}"
	        read host

           dbChangeUserPassword $username $host $password mysql_native_password $1
           #Проверка на успешность выполнения предыдущей команды
           if [ $? -eq 0 ]
           	then
           		#предыдущая команда завершилась успешно
           		#Проверка существования системного пользователя "$username"
           			grep "^$username:" /etc/passwd >/dev/null
           			if  [ $? -eq 0 ]
           			then
           			#Пользователь $username существует
           				dbSetMyCnfFile $HOMEPATHWEBUSERS/$username $username $password $username
           			#Пользователь $username существует (конец)
           			fi
           		#Конец проверки существования системного пользователя $username
           		#предыдущая команда завершилась успешно (конец)
           	else
           		#предыдущая команда завершилась с ошибкой
           		echo -e "${COLOR_RED}Произошла ошибка при смене пароля для mysql-пользователя ${COLOR_GREEN}\"$username\"${COLOR_RED}  ${COLOR_GREEN}\"\"${COLOR_RED}  ${COLOR_NC}"
           		return 3
           		#предыдущая команда завершилась с ошибкой (конец)
           fi
           #Конец проверки на успешность выполнения предыдущей команды

        fi
	#Пользователь mysql "$username" существует (конец)
	else
	#Пользователь mysql "$username" не существует
	    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbChangeUserPassword\" ${COLOR_NC}"
	    return 1
	#Пользователь mysql "$username" не существует (конец)
	fi
	#Конец проверки на существование пользователя mysql "$username"
}

declare -x -f input_dbCreate #Запрос названия базы данных для добавления: ($1-username ; $2-dbname без username)
#Запрос названия базы данных для добавления
###input
#$1-username ;
#$2-dbname без username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь mysql
#3 - база данных уже существует
input_dbCreate() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then

		dbViewBasesByUsername $1 full_info

		#Пользователь mysql "$1" существует
		    echo -n -e "${COLOR_BLUE}Введите название добавлемой базы данных без префикса ${COLOR_YELLOW}\"$1_\"${COLOR_BLUE}: ${COLOR_NC}"
		    read dbame
		    fullDbName=$1\_$dbame

		    #Проверка существования базы данных "$fullDbName"
		    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$fullDbName'" 2>&1`" ]];
		    	then
		    	#база $fullDbName - существует
		    		echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$fullDbName\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbCreate\" ${COLOR_NC}"
                    dbViewBasesByTextContain $fullDbName
                    return 3
		    	#база $fullDbName - существует (конец)
		    	else
		    	#база $fullDbName - не существует
                    dbCreateBase $fullDbName utf8 utf8_general_ci full_info
                #    mysql -e "GRANT ALL PRIVILEGES ON \`$1\_$dbame\`.* TO '$1'@'%' WITH GRANT OPTION;";
                    dbSetFullAccessToBase $fullDbName $1 localhost
		    	#база $fullDbName - не существует (конец)
		    fi
		    #конец проверки существования базы данных $fullDbName



		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_dbCreate\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
