#!/bin/bash

declare -x -f input_certGenerate
#Ввод параметров ssh
###input
#$1-username ;
#$2-domain
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
#3 - отменено пользователем
input_certGenerate() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then

	username=$1

	#Параметры запуска существуют
		#Проверка существования системного пользователя "$username"
			grep "^$username:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $username существует
                echo -n -e "${COLOR_YELLOW}Сгенерировать SSL-сертификат для домена${COLOR_GREEN}\"$2\"${COLOR_YELLOW}? Введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW} для генерации, для отмены  - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                    while read
                    do
                        case "$REPLY" in
                            y|Y)
                                echo -n -e "${COLOR_YELLOW}Просто сгенерировать сертификат или прописать его еще и в vhosts?? Введите ${COLOR_BLUE}\"1\"${COLOR_YELLOW} для автоматического исправления vhosts, для простой генерации сертификата введите ${COLOR_BLUE}\"2\"${COLOR_NC}: "
                                while read
                                do
                                    case "$REPLY" in
                                        1)
                                            site_AddSSL $username $2 auto;
                                            break
                                            ;;
                                        2)
                                            site_AddSSL $username $2 manual;
                                            break
                                            ;;
                                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                           ;;
                                    esac
                                done


                                break
                                ;;
                            n|N)

                                break
                                ;;
                            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                               ;;
                        esac
                    done

			#Пользователь $username существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_certGenerate\"${COLOR_NC}"
				return 2
			#Пользователь $username не существует (конец)
			fi
		#Конец проверки существования системного пользователя $username
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_certGenerate\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}