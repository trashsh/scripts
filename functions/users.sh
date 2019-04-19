#!/bin/bash
declare -x -f FtpUserAdd
#Добавление ftp-пользователя
###input
#$1-user ;
#$2-domain ;
#$3-mode: password type - autogenerate/querry/manual;
#$4-mode:system_user/site_user
#$5-created by

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь ftp-уже существует
#3 - Ошибка передачи параметра mode - manual|querry|autogenerate
#4 - пользователь created by не существует
#5 - ошибка mode: system_user/site_user
FtpUserAdd() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		case "$4" in
		    system_user|site_user)
                true
		        ;;
			*)
			    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: system_user/site_user\"${COLOR_RED} в функцию ${COLOR_GREEN}\"FtpUserAdd\"${COLOR_NC}";
			    return 5
			    ;;
		esac

		#Проверка существования системного пользователя "$1_$2"
			grep "^$1_$2:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1_$2\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"FtpUserAdd\"${COLOR_NC}"
				return 2
			#Пользователь $1_$2 существует (конец)
			else
			#Пользователь $1_$2 не существует
			    #Проверка существования системного пользователя "$5"
			    	grep "^$5:" /etc/passwd >/dev/null
			    	if  [ $? -eq 0 ]
			    	then
			    	#Пользователь $5 существует
                        case "$3" in
                            "manual"|"querry"|"autogenerate")
                                #Проверка существования каталога ""$HOMEPATHWEBUSERS"/"$1"/"$2""
                                if ! [ -d "$HOMEPATHWEBUSERS"/"$1"/"$2" ] ; then
                                    #Каталог ""$HOMEPATHWEBUSERS"/"$1"/"$2"" не существует
                                    sudo mkdir -p "$HOMEPATHWEBUSERS"/"$1"/"$2"
                                    #Каталог ""$HOMEPATHWEBUSERS"/"$1"/"$2"" не существует (конец)
                                fi
                                #Конец проверки существования каталога ""$HOMEPATHWEBUSERS"/"$1"/"$2""

                            case "$4" in
                                system_user)
                                    infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt
                                    ;;
                                site_user)
                                    infoFile="$HOMEPATHWEBUSERS"/"$1"/"$2"/.myconfig/info.txt
                                    ;;
                            	*)
                            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
                            	    ;;
                            esac


                                sudo useradd -c "Ftp-user for user $1 domain $2" $1_$2 -N -d "$HOMEPATHWEBUSERS"/"$1"/"$2" -m -s /bin/false -g www-data -G www-data
                                sudo adduser $1_$2 ftp-access

                                fileAddLineToFile $infoFile "FTP-Пользователь:"

                                #смена пароля на пользователя
                                userChangePassword $1_$2 $3 $infoFile
                                fileAddLineToFile $infoFile "Server: $MYSERVER ($2)"
                                fileAddLineToFile $infoFile "Port: $FTPPORT"
                                fileAddLineToFile $infoFile "Тип подключения: с использованием TLS"
                                fileAddLineToFile $infoFile "------------------------"
                                return 0
                                ;;
                            *)
                                echo -e "${LOR_RED}Ошибка передачи параметра ${LOR_GREEN}\"mode - manual|querry|autogenerate\"${LOR_RED} в функцию ${OLOR_GREEN}\"FtpUserAdd\"${OLOR_NC}";
                                return 3
                                ;;
                        esac
                            #Пользователь $5 существует (конец)
                            else
                            #Пользователь $5 не существует
                                echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"FtpUserAdd\"${COLOR_NC}"
                                return  4
                            #Пользователь $5 не существует (конец)
                            fi
                        #Конец проверки существования системного пользователя $5

			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"FtpUserAdd\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f FtpUserDeleteAll #удаление всех ftp-пользователей, связанных с пользователем системы: ($1-username)
#удаление всех ftp-пользователей, связанных с пользователем системы
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
FtpUserDeleteAll() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
                echo ""
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"FtpUserDeleteAll\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"FtpUserDeleteAll\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f userChangePassword
#Смена пароля пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
###input
#$1-user ;
#$2-mode set password: manual/querry/autogenerate ;
#$3-путь к txt-файлу
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - пароль пустой
userChangePassword() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				case "$2" in
				    manual)
                        echo -n -e "${COLOR_BLUE}Установите пароль для пользователя ${COLOR_NC} ${COLOR_YELLOW}\"$1\":${COLOR_NC}";
                        read password;
                        if [[ -z "$password" ]]; then
                              #переменная имеет пустое значение
                              echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя ${COLOR_GREEN}\"$1\""${COLOR_NC}"
                              return 3
                         fi
				        ;;
				    querry)
				        echo -n -e "Пароль для пользователя ${COLOR_YELLOW}" $1 "${COLOR_NC} сгенерировать или установить вручную? \nВведите ${COLOR_BLUE}\"y\"${COLOR_NC} для автогенерации, для ручного ввода - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                while read
                                do
                                    case "$REPLY" in
                                    y|Y) password="$(openssl rand -base64 14)";
                                         break;;
                                    n|N) echo -n -e "${COLOR_BLUE}Установите пароль для пользователя ${COLOR_NC} ${COLOR_YELLOW}\"$1\":${COLOR_NC}";
                                         read password;
                                         if [[ -z "$password" ]]; then
                                            #переменная имеет пустое значение
                                            echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя ${COLOR_GREEN}\"$1\""${COLOR_NC}"
                                            return 3
                                         fi
                                         break;;
                                    esac
                                done
				        ;;
					autogenerate)
                        password="$(openssl rand -base64 14)"
						;;
					*)
					    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
					    ;;
				esac

				echo "$1:$password" | sudo chpasswd
				fileAddLineToFile $3 "Username: $1"
                fileAddLineToFile $3 "Password: $password"
				echo -e "${COLOR_YELLOW}Пользователю ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} установлен пароль ${COLOR_GREEN}\"$password\"${COLOR_YELLOW}  ${COLOR_NC}"
				return 0
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userChangePassword\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userChangePassword\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f userDelete_ftpAll
#удаление всех ftp-пользователей для домена
###input
#$1-username ;
#$2-domain ;
#$3-подтверждение "delete"
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
userDelete_ftpAll() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    array=($(members ftp-access))
	    #echo ${array[@]}

	    if [ "$3" = "delete" ]
		then

            for user in ${array[@]}; do
                 if [[ "$user" =~ ^$1_$2$ ]] || [[ "$user" =~ ^$1_$2-- ]]; then
                   sudo userdel -r $user
                fi

            done
		else
		    echo -e "${COLOR_RED}Ошибка передачи подтверждения в функции ${COLOR_GREEN}\"userDelete_ftpAll\"${COLOR_RED} ${COLOR_NC}"
		fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userDelete_ftpAll\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f existGroup
#Существует ли группа $1
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
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

declare -x -f viewGroupAdminAccessAll
#Вывод всех пользователей группы admin-access
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
viewGroupAdminAccessAll(){
	echo -e "\n${COLOR_YELLOW}Список пользователей группы \"admin-access:\":${COLOR_NC}"
	more /etc/group | grep admin-access: | highlight magenta "admin-access"
}

declare -x -f viewGroupSudoAccessAll
#Вывод всех пользователей группы sudo
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
viewGroupSudoAccessAll(){
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"sudo\":${COLOR_NC}"
		more /etc/group | grep sudo: | highlight magenta "sudo"
}

declare -x -f viewUserInGroupUsersByPartName
#Вывод списка пользователей, входящих в группу users по части имени пользователя $1
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
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

declare -x -f userAddToGroup
#Добавить пользователя в группу
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
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

declare -x -f userDeleteFromGroup
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
