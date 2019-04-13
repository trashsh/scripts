#!/bin/bash

declare -x -f viewGroupUsersAccessAll
#Вывод всех пользователей группы users
###!Полностью готово. Не трогать больше
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


declare -x -f userDelete_system
###input
#$1- username;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - удаление завершилось с ошибкой
userDelete_system() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				sudo userdel -r $1
				#Проверка на успешность выполнения предыдущей команды
				if [ $? -eq 0 ]
					then
						#предыдущая команда завершилась успешно
						return 0
						#предыдущая команда завершилась успешно (конец)
					else
						#предыдущая команда завершилась с ошибкой
						return 3
						#предыдущая команда завершилась с ошибкой (конец)
				fi
				#Конец проверки на успешность выполнения предыдущей команды
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userDelete_system\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userDelete_system\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f userAddSystem
#Выполенние операций по созданию системного пользователя
###input:
#$1-username ;
#$2-homedir ;
#$3-путь к интерпритатору команд ;
#$4 - основная группа пользователей;
#$5 - password,
#$6 системный пользователь, который выполняет команду
###return:
#0 - выполненоуспешно
#1 - отпутствуют параметры,
#2 -пользователь существует,
#3 - каталог пользователя уже существует
#4 - интерпритатор не существует,
#5 - группа не существует,
#6 - не существует системный пользователь, от которого запускается скрипт
userAddSystem()
{
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует
			echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Операция прервана. Функция ${COLOR_GREEN}\"userAddSystem\"${COLOR_RED}  ${COLOR_NC}"
			exit 2
		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    #Проверка существования каталога "$2"
		    if [ -d $2 ] ; then
		        #Каталог "$2" существует
		        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} уже существует. Операция прервана. Функция ${COLOR_GREEN}\"userAddSystem\"${COLOR_RED}  ${COLOR_NC}"
		        exit 3
		        #Каталог "$2" существует (конец)
		    else
		        #Каталог "$2" не существует
		        #Проверка существования интерпритатора "$3"
		        if [ -f $3 ] ; then
		            #интерпритатор "$3" существует
		            #Проверка существования системного пользователя "$6"
		            	grep "^$6:" /etc/passwd >/dev/null
		            	if  [ $? -eq 0 ]
		            	then
		            	#Пользователь $6 существует

                            #Проверка существования системной группы пользователей "$4"
                            if grep -q $4 /etc/group
                                then
                                    #Группа "$4" существует
                                         #sudo -s source /my/scripts/include/inc.sh
                                         mkdir $2
                                         useradd -N -g $4 -d $2 -s $3 $1
                                         echo "$1:$5" | chpasswd
                                         infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt
                                         fileAddLineToFile $infoFile " "
                                         fileAddLineToFile $infoFile "SSH-Пользователь:"
                                         fileAddLineToFile $infoFile "Username: $1"
                                         fileAddLineToFile $infoFile "Password: $5"
                                         fileAddLineToFile $infoFile "Server: $MYSERVER"
                                         fileAddLineToFile $infoFile "Port: $SSHPORT"
                                         sudo chown -R "$1":users $2
                                         sudo chmod 777 $2

                                        fileAddLineToFile $infoFile " "
                                        fileAddLineToFile $infoFile "FTP-User:"
                                        fileAddLineToFile $infoFile "Username: $1"
                                        fileAddLineToFile $infoFile "Password: $5"
                                        fileAddLineToFile $infoFile "Server: $MYSERVER"
                                        fileAddLineToFile $infoFile "Port: $FTPPORT"
                                        fileAddLineToFile $infoFile "Тип подключения: с использованием TLS"

                                        #dbSetMyCnfFile $HOMEPATHWEBUSERS/$1 $1 $6
                                        mkdirWithOwn $2/.backups $1 $4 777
                                        mkdirWithOwn $2/.backups/auto $1 $4 755
                                        mkdirWithOwn $2/.backups/manually $1 $4 755

                                        #dbRecordAdd_addUser $1 $2 $6 1


                                                    touchFileWithModAndOwn $2/.bashrc $1 $4 666
                                                    touchFileWithModAndOwn $2/.sudo_as_admin_successful $1 $4 644
                                                    echo "source /etc/profile" >> $2/.bashrc
                                                    sudo chmod 644 $2/.bashrc
                                                    #sed -i '$ a source $SCRIPTS/include/inc.sh'  $2/.bashrc
                                                   # sed -i '$ a $SCRIPTS/menu'  $2/.bashrc

                                    #Группа "$4" существует (конец)

                                else
                                    #Группа "$4" не существует
                                    echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem\"${COLOR_NC}"
                                    return 5
                                    #Группа "$4" не существует (конец)
                                fi
                            #Конец проверки существования системного пользователя $4

		            	#Пользователь $6 существует (конец)
		            	else
		            	#Пользователь $6 не существует
		            	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$6\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userAddSystem\"${COLOR_NC}"
		            		return 6
		            	#Пользователь $7 не существует (конец)
		            	fi
		            #Конец проверки существования системного пользователя $6
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


declare -x -f userAddToGroupSudo
#Добавление пользователя $1 в группу sudo
###!Полностью готово. Не трогать больше
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



declare -x -f viewAccessDetail
#Отобразить реквизиты доступа
###input
#$1-user ;
#$2-mode (full_info);
#$3 - каталог размещения домашних папок пользователей
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - ошибка передачи mode
viewAccessDetail() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		file=$3/.myconfig/info.txt
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				case "$2" in
				    full_info)
				        clear;
				        echo -e "\n${COLOR_PURPLE}Реквизиты доступа для пользователя ${COLOR_YELLOW}\"$1\"${COLOR_GREEN}:${COLOR_NC}";
				        cat $file | highlight green Password | highlight green Username | highlight green Server | highlight green Host| highlight green Port| highlight yellow SSH-Пользователь| highlight yellow Mysql-User| highlight yellow FTP-User | highlight green "Ключевой файл" | highlight green "Тип подключения:" | highlight green "Phpmyadmin" | highlight green "Использован открытый ключ"
				        ;;
					*)
					    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"viewAccessDetail\"${COLOR_NC}";
					    return 3
					    ;;
				esac
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"viewAccessDetail\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewAccessDetail\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f viewUserInGroupByName
#Вывод групп, в которых состоит указанный пользователь
###!Полностью готово. Не трогать больше
###input
#$1 - имя пользователя
#return
#0 - выполнено успешно,
#1 - не передан параметр
viewUserInGroupByName(){
	if [ -n "$1" ]
		then
			cat /etc/group | grep -P $1 | highlight green $1 | highlight magenta "ssh-access" | highlight magenta "ftp-access" | highlight magenta "sudo" | highlight magenta "admin-access"
			userExistInGroup $1 users
		        #Проверка на успешность выполнения предыдущей команды
		        if [ $? -eq 0 ]
		        	then
		        		#предыдущая команда завершилась успешно
		        		echo -e "users:x:100:$1" | highlight green "$1" | highlight magenta "users"
		        		return 0
		        		#предыдущая команда завершилась успешно (конец)
		        fi
		        #Конец проверки на успешность выполнения предыдущей команды
			return 0
		else
			echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUserInGroupByName\"${COLOR_RED} ${COLOR_NC}"
			return 1
		fi
}


declare -x -f viewUsersInGroup
#Вывод списка пользователей, входящих в группу $1
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
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
	             if [ "$1" == "users" ]
	                then viewGroupUsersAccessAll
	             fi
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


declare -x -f viewGroupAdminAccessByName
#Вывод всех пользователей группы admin-access с указанием части имени пользователя
###!Полностью готово. Не трогать больше
###input
#$1 - имя пользователя
###return
#1 - не переданы параметры
viewGroupAdminAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы ${COLOR_GREEN}\"admin-access\"${COLOR_YELLOW}, содержащих в имени ${COLOR_GREEN}\"$1\":${COLOR_NC}"
		more /etc/group | grep -E "admin.*$1" | highlight green "$1" | highlight magenta "admin-access"
		#Проверка на успешность выполнения предыдущей команды
		#Конец проверки на успешность выполнения предыдущей команды
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewGroupAdminAccessByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}


declare -x -f viewGroupSudoAccessByName
#Вывод пользователей группы sudo с указанием части имени пользователя
###!Полностью готово. Не трогать больше
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
