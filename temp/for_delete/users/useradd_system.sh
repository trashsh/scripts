#!/bin/bash
source $SCRIPTS/include/include.sh




viewGroupUsersAccessAll "Текущие пользователи системы:"
echo -e "${COLOR_YELLOW}"Создание системного пользователя"${COLOR_NC}"
read -p "Введите имя пользователя: " username

#Проверка существования системного пользователя "$username"
	grep "^$username:" /etc/passwd >/dev/null
	if [ $? -eq 0 ]
	then
	#Пользователь $username существует
		echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} уже существует${COLOR_GREEN}${COLOR_NC}"
		return 1
	#Пользователь $username существует (конец)
	else
	#Пользователь $username не существует

    echo -n -e "${COLOR_YELLOW}Для добавления системного пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
    while read
    do
        case "$REPLY" in
            y|Y)
                #добавление системного пользователя
                UseraddSystem $username

                echo -n -e "${COLOR_YELLOW}Добавить пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW},  - введите ${COLOR_BLUE}\"y\"${COLOR_NC}: "
                    while read
                    do
                        case "$REPLY" in
                            y|Y)

                            break
                                ;;
                            n|N)

                            break
                                ;;
                            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                               ;;
                        esac
                    done
                #добавление в группу sudo
                #ssh-key
                #mysql-user
                #viewSshAccess
                #viewFtpAccess
                #viewMysqlAccess

                viewGroupUsersAccessAll
            break
                ;;
            n|N)

            break
                ;;
            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
               ;;
        esac
    done

	#Пользователь $username не существует (конец)
	fi
#Конец проверки существования системного пользователя $username