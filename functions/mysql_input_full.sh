#!/bin/bash

declare -x -f input_dbUserDeleteBase
#Запрос подтверждения удаления всех баз данных конкретного пользователя
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - баз данных пользователя не существует
input_dbUserDeleteBase() {
	dbViewAllUsersByContainName $1
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

		#Проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then
		#Пользователь mysql "$1" существует
		    username=$1
		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql для его удаления: ${COLOR_NC}"
		read user
		#Проверка на существование пользователя mysql "$user"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$user'" 2>&1`" ]];
		then
		#Пользователь mysql "$user" существует
		    username=$user
		#Пользователь mysql "$user" существует (конец)
		else
		#Пользователь mysql "$user" не существует
		    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$user\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserDeleteBase\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$user" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$user"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	dbViewBasesByUsername $username success_only
	#Проверка на успешность выполнения предыдущей команды
	if [ $? -eq 0 ]
		then
			#предыдущая команда завершилась успешно

			        echo -n -e "${COLOR_YELLOW}Подтвердите удаление всех баз данных пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW}. Все базы данных предварительно будут заархиврованы. Введите для подтверждения ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                    while read
                    do
                        case "$REPLY" in
                            y|Y)
                                bash -c "source $SCRIPTS/include/inc.sh; dbBackupBasesOneUser $username full_info data DeleteBase;";
                                #dbBackupBasesOneUser $username full_info data DeleteBase;
                                break
                                ;;
                            n|N)
                                echo -e "${COLOR_YELLOW}"Пользовать отменил удаление имеющихся баз данных"${COLOR_NC}"
                                break
                                ;;
                            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                               ;;
                        esac
                    done

			#предыдущая команда завершилась успешно (конец)
		else
			#предыдущая команда завершилась с ошибкой
            return 3
			#предыдущая команда завершилась с ошибкой (конец)
	fi
	#Конец проверки на успешность выполнения предыдущей команды
}