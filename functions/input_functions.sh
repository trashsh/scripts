#!/bin/bash
source $SCRIPTS/include/include.sh
source $SCRIPTS/menu

declare -x -f userAddSystem_input


userAddSystem_input() {
    #Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    username=$1

	else
	    echo -e "${COLOR_YELLOW}Список имеющихся системных пользователей:${COLOR_NC}"
	    viewGroupUsersAccessAll
	    echo -e -n "${COLOR_BLUE}"Введите имя пользователя: "${COLOR_NC}"
		read username
	fi
	    grep "^$username:" /etc/passwd >/dev/null

	    #Проверка на успешность выполнения предыдущей команды
	    if [ $? -eq 0 ]
	    	then
	    		#Пользователь уже существует
	    		echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} уже существует${COLOR_NC}"
	    		menuMain $(whoami)
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
                                useradd -N -g users -G ftp-access -d $HOMEPATHWEBUSERS/$username -s /bin/bash $username
                                mkdirWithOwner $HOMEPATHWEBUSERS/$username $username users 755
                                mkdirWithOwner $HOMEPATHWEBUSERS/$username $username users 755
                                #mkdir -p $HOMEFPATHWEBUSERS/$username/.backups
                                mkdirWithOwner $HOMEPATHWEBUSERS/$username/.backups $username users 755
                                echo "source /etc/profile" >> $HOMEPATHWEBUSERS/$username/.bashrc
                                sed -i '$ a source $SCRIPTS/include/include.sh'  $HOMEPATHWEBUSERS/$username/.bashrc
                                #Проверка на успешность выполнения предыдущей команды
                                echo "$username:$password" | chpasswd
                                chModAndOwnFolderAndFiles $HOMEPATHWEBUSERS/$username 755 644 $username users
                                touchFileWithOwner $HOMEPATHWEBUSERS/$username/.bashrc $username users 644
                                #touch $HOMEPATHWEBUSERS/$username/.bashrc
                                #touch $HOMEPATHWEBUSERS/$username/.sudo_as_admin_successful
                                touchFileWithOwner $HOMEPATHWEBUSERS/$username/.sudo_as_admin_successful $username users 644
                                dbSetMyCnfFile $username $password


                                sshKeyAddToUser $username 0 $SETTINGS/ssh/keys/lamer
                                echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$username\"${COLOR_GREEN} успешно добавлен${COLOR_YELLOW}\"\"${COLOR_GREEN} ${COLOR_NC}"

                                #добавление в группу sudo
                                #userAddToGroup $username sudo 1

                                showUserFullInfo $username
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
