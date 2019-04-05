#!/bin/bash


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


declare -x -f input_sshSettings
#Ввод параметров ssh
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
#3 - отменено пользователем
input_sshSettings() {
	#Проверка на существование параметров запуска скрипта
	#TODO Сделать запуск функции без параметров.
	if [ -n "$1" ]
	then

	username=$1
	infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt

	#Параметры запуска существуют
		#Проверка существования системного пользователя "$username"
			grep "^$username:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $username существует
                echo -n -e "${COLOR_YELLOW}Введите ${COLOR_BLUE}\"g\"${COLOR_YELLOW} для генерации ключа ssh, ${COLOR_BLUE}\"i\"${COLOR_YELLOW} - для импорта ключа ssh, ${COLOR_BLUE}\"n\"${COLOR_YELLOW} - если ключ доступа не генерировать: ${COLOR_NC} "
                	while read
                	do

                    	case "$REPLY" in
                	    	g|G)
                                sshKeyGenerateToUser $username $HOMEPATHWEBUSERS/$username;
                                #viewSshAccess $username $MYSERVER $SSHPORT 1 $HOMEPATHWEBUSERS/$username/.ssh/ssh_$username.ppk

                                fileAddLineToFile $infoFile "Ключевой файл - $HOMEPATHWEBUSERS/$username/.ssh/ssh_$username.ppk"

                		    	break;;
                		    i|I)
                                sshKeyImport $username;

                			    break;;
                		    n|N)
                                echo -e "${COLOR_YELLOW}"Добавление ssh-доступа отменено пользователем"${COLOR_NC}"
                			    return 3;;
                			*)
                                echo -n -e "${COLOR_RED}Ошибка ввода режима генерации ключа ssh в функцию ${COLOR_GREEN}\"input_sshSettings\".${COLOR_YELLOW} Повторите ввод: ${COLOR_NC}";
                            ;;
                	    esac
                	done


			#Пользователь $username существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_sshSettings\"${COLOR_NC}"
				return 2
			#Пользователь $username не существует (конец)
			fi
		#Конец проверки существования системного пользователя $username
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_sshSettings\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
