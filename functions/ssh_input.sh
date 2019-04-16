#!/bin/bash
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

                                #fileAddLineToFile $infoFile "Ключевой файл - $HOMEPATHWEBUSERS/$username/.ssh/ssh_$username.ppk"

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