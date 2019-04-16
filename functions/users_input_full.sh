#!/bin/bash

declare -x -f input_userDelete_system
#Запрос имени пользователя на удаление системного пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###return
#0 - выполнено успешно
#2 - не существует пользователь
#3 - операция отменена пользователем
input_userDelete_system() {
	date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`
	echo -e "${COLOR_GREEN}"Удаление системного пользователя"${COLOR_NC}"
	echo -e "${COLOR_YELLOW}"Список существующих пользователей"${COLOR_NC}"
	viewGroupUsersAccessAll
    echo -n -e "${COLOR_BLUE}\nВведите имя пользователя для его удаления (или нажмите ctrl+c для отмены): ${COLOR_NC}"
    read -p ":" username

    #Проверка существования системного пользователя "$username"
    	grep "^$username:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $username существует

            echo -n -e "${COLOR_YELLOW} Удаление пользователя повлечет удаление сайтов пользователя, баз данных, пользователей mysql\n${COLOR_NC}"
    		echo -n -e "${COLOR_YELLOW}Для удаления системного пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода - ${COLOR_BLUE}\"n\"${COLOR_YELLOW}: ${COLOR_NC}"
            while read
                do
                    echo -n ": "
                    case "$REPLY" in
                    y|Y) #backupAllSitesByUsername $username $BACKUPFOLDER/vds/removed/$2;
                         dbBackupBasesOneUser $username full_info data DeleteBase;
                         #Проверка на существование пользователя mysql "$username"
                         if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
                         then
                         #Пользователь mysql "$username" существует
                             input_dbUserDeleteBase $username;
                             while true; do
                                read -p "Удалить пользователя mysql $username (y/n)?: " yn
                                case $yn in
                                    [Yy]* ) dbUserdel $username drop;
                                            break;;
                                    [Nn]* ) exit;;
                                    * ) echo "Please answer yes or no.";;
                                esac
                            done
                          else
                            echo "error"
                         #Пользователь mysql "$username" существует (конец)
                         fi

                         userDelete_system $username;
                         #Конец проверки на существование пользователя mysql "$username"
                        return 0
                    ;;
                    n|N)  echo -e "${COLOR_YELLOW}Операция удаления пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} отменена ${COLOR_NC}";
                              return 3;
                            break
                    ;;
                    esac
                done
    	#Пользователь $username существует (конец)
    	else
    	#Пользователь $username не существует
    	    clear
    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_userDelete_system\"${COLOR_NC}\n"
    	    input_userDelete_system
    		return 2
    	#Пользователь $username не существует (конец)
    	fi
    #Конец проверки существования системного пользователя $username

}


declare -x -f dbViewBasesByUsername
#Отобразить список всех баз данных, владельцем которой является пользователь mysql $1_% (по имени)
###input
#$1-user;
#$2-mode(full_info/error_only/success_only)
#return
#0 - базы данных найдены,
#1 - не переданы параметры,
#2 - базы данных не найдены
#3 - ошибка параметра mode(full_info/error_only/success_only)
dbViewBasesByUsername() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SHOW DATABASES LIKE '$1\_%';") ]]; then
					#непустой результат
					case "$2" in
					        full_info)
					            echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL пользователя ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
                                mysql -e "SHOW DATABASES LIKE '$1\_%';"
                                return 0
					            ;;
					        error_only)
					            return 0
					            ;;
					    	success_only)
					    		echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL пользователя ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
                                mysql -e "SHOW DATABASES LIKE '$1\_%';"
                                return 0
                                ;;
					    	*)
					    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
					    	    return 3
					    	    ;;
					    esac

					#непустой результат (конец)
				else
				    #пустой результат
					    case "$2" in
					        full_info)
					            echo -e "${COLOR_YELLOW}\nБазы данных пользователя ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствуют${COLOR_NC}"
					            return 2
					            ;;
					        error_only)
					            echo -e "${COLOR_YELLOW}\nБазы данных пользователя ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствуют${COLOR_NC}"
					            return 2
					            ;;
					    	success_only)
					    		return 2
					    		;;
					    	*)
					    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
					    	    return 3
					    	    ;;
					    esac

					#пустой результат (конец)
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


#Добавление системного пользователя - ввод данных
###input:
#1 - имя добавляющего пользователя,
#2 - имя добавляемого пользователя
###return:
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - добавляющий пользователь $1 не существует
#3 - добавляемый пользователь $2 уже существует
#4 - пользователь отменил создание пользователя $1
#5 - пользователь не создан. Ошибка выполнения функции
declare -x -f input_userAddSystem
input_userAddSystem() {

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
                    		echo -e "${COLOR_YELLOW}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_userAddSystem\"${COLOR_YELLOW}  ${COLOR_NC}"
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
                    		echo -e "${COLOR_YELLOW}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_userAddSystem\"${COLOR_YELLOW}  ${COLOR_NC}"
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
                                userAddSystem $username $HOMEPATHWEBUSERS/$username "/bin/bash" users $password  $1
                                #input_userAddToGroupSudo $1 $username
                                userAddToGroupSudo $username
                                input_sshSettings $username
                                sshKeyAddToUser $username users $SETTINGS/ssh/keys/lamer $HOMEPATHWEBUSERS/$username

                                echo -n -e "Пароль для пользователя MYSQL ${COLOR_YELLOW}" $username "${COLOR_NC} сгенерировать или установить вручную? \nВведите ${COLOR_BLUE}\"y\"${COLOR_NC} для автогенерации, для ручного ввода - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                while read
                                do
                                    case "$REPLY" in
                                    y|Y) passwordSql="$(openssl rand -base64 14)";
                                         break;;
                                    n|N) echo -n -e "${COLOR_BLUE} Введите пароль для пользователя MYSQL ${COLOR_NC} ${COLOR_YELLOW}\"$username\":${COLOR_NC}";
                                         read passwordSql;
                                         if [[ -z "$passwordSql" ]]; then
                                            #переменная имеет пустое значение
                                            echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя ${COLOR_GREEN}\"$username\""${COLOR_NC}"
                                            return 5
                                         fi
                                         break;;
                                    esac
                                done


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
                                host=localhost
                                permittion=adminGrant

                                dbUseradd $username $passwordSql $host pass $permittion

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

                #Проверка существования файла ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt"
                if [ -f "$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt ] ; then
                    #Файл ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt" существует
                    viewAccessDetail $HOMEPATHWEBUSERS/$username full_info
                    #Файл ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt" существует (конец)
                fi
                #Конец проверки существования файла ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt"



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
                	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не создан. Ошибка выполнения функции ${COLOR_GREEN}\"input_userAddSystem\"${COLOR_NC}"
                		return 5
                	#Пользователь $username не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $username


        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_userAddSystem\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_userAddSystem\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}



declare -x -f input_viewUsersInGroup
#Запрос имени пользователя для вывода списка групп, в которых он состоит
###!Полностью готово. Не трогать больше
input_viewUsersInGroup() {
    echo -e -n "${COLOR_BLUE}"Введите имя пользователя: "${COLOR_NC}"
    read username
    #Проверка существования системного пользователя "$username"
    	grep "^$username:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $username существует
    		clear
    		echo -e "${COLOR_YELLOW}Список групп, в которые входит пользователь ${COLOR_GREEN}\"$username\":${COLOR_NC}"
    		viewUserInGroupByName $username
    		return 0
    	#Пользователь $username существует (конец)
    	else
    	#Пользователь $username не существует
    	    clear
    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_viewUsersInGroup\"${COLOR_NC}"
    		return 1
    	#Пользователь $username не существует (конец)
    	fi
    #Конец проверки существования системного пользователя $username
}


declare -x -f input_userAddToGroupSudoinput_viewUserInGroupUsersByPartName
#Запрос части имени пользователя для вывода пользователей группы users
###!Полностью готово. Не трогать больше
input_viewUserInGroupUsersByPartName() {
    echo -e -n "${COLOR_YELLOW}Введите имя или часть имени для поиска пользователей группы ${COLOR_GREEN}\"users\"${COLOR_YELLOW}: ${COLOR_NC}"
    read username
    clear
    viewUserInGroupUsersByPartName $username
}


declare -x -f input_viewGroup
#Запрос названия группы для вывода списка ее членов
###!Полностью готово. Не трогать больше
#return
#0 - выполнено успешно
#1 - группа не существует
input_viewGroup() {
    echo -e -n "${COLOR_BLUE}"Введите название группы: "${COLOR_NC}"
    read groupname
    #Проверка существования системной группы пользователей "$groupname"
    clear
    if grep -q $groupname /etc/group
        then
            #Группа "$groupname" существует
             viewUsersInGroup $groupname
             return 0
            #Группа "$groupname" существует (конец)
        else
            #Группа "$groupname" не существует
            echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$groupname\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_viewGroup\"${COLOR_NC}"
    		return 1
    		#Группа "$groupname" не существует (конец)
        fi
    #Конец проверки существования системной группы пользователей $groupname
}


declare -x -f input_viewGroupAdminAccessByName
#Запрос части имени пользователя для вывода пользователей группы admin-access
###!Полностью готово. Не трогать больше
input_viewGroupAdminAccessByName() {
    echo -e -n "${COLOR_YELLOW}Введите имя или часть имени для поиска пользователей группы ${COLOR_GREEN}\"admin-access\"${COLOR_YELLOW}: ${COLOR_NC}"
    read username
    clear
    viewGroupAdminAccessByName $username
}


declare -x -f input_viewGroupSudoAccessByName
#Запрос части имени пользователя для вывода пользователей группы sudo
###!Полностью готово. Не трогать больше
input_viewGroupSudoAccessByName() {
    echo -e -n "${COLOR_YELLOW}Введите имя или часть имени для поиска пользователей группы ${COLOR_GREEN}\"sudo\"${COLOR_YELLOW}: ${COLOR_NC}"
    read username
    clear
    viewGroupSudoAccessByName $username
}


declare -x -f input_userAddToGroupSudo
#запрос добавления пользователя в группу sudo
###!Полностью готово. Не трогать больше
###input
#$1-запускающий процесс пользователь ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - запускающий пользователь $1 не существует
#3 - добавляемый в группу пользователь не существует
#4 - пользователь отменил добавление
input_userAddToGroupSudo() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
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
                        echo -n -e "${COLOR_YELLOW}Хотите добавить пользователя ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} в группу sudo? Введите для подтверждения ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены  - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                            while read
                            do
                                case "$REPLY" in
                                    y|Y)
                                        userAddToGroupSudo $2;
                                        break
                                        ;;
                                    n|N)
                                        return 4;
                                        break
                                        ;;
                                    *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                       ;;
                                esac
                            done
					#Пользователь $2 существует (конец)
					else
					#Пользователь $2 не существует
					    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_userAddToGroupSudo\"${COLOR_NC}"
						return 3
					#Пользователь $2 не существует (конец)
					fi
				#Конец проверки существования системного пользователя $2
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_userAddToGroupSudo\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_userAddToGroupSudo\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
