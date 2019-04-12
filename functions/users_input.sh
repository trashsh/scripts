#!/bin/bash

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
                    viewAccessDetail $username full_info
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



declare -x -f input_userDelete_system
#Запрос имени пользователя на удаление системного пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###return
#0 - выполнено успешно
#2 - не существует пользователь
#3 - операция отменена пользователем
input_userDelete_system() {
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
    		echo -n -e "${COLOR_YELLOW}Для удаления системного пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода - ${COLOR_BLUE}\"n\"${COLOR_YELLOW}: ${COLOR_NC}"
            while read
                do
                    echo -n ": "
                    case "$REPLY" in
                    y|Y) userDelete_system $username;
                         #Проверка на существование пользователя mysql "$username"
                         if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
                         then
                         #Пользователь mysql "$username" существует
                             input_dbUserDeleteBase $username;
                             while true; do
                                read -p "Удалить пользователя mysql $username (y/n)?: " yn
                                case $yn in
                                    [Yy]* ) dbUserdel $username drop; break;;
                                    [Nn]* ) break;;
                                    * ) echo "Please answer yes or no.";;
                                esac
                            done
                         #Пользователь mysql "$username" существует (конец)
                         fi
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


declare -x -f input_viewUserFullInfo
###!Не готово. Обратить внимание
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
input_viewUserFullInfo() {
    echo -e -n "${COLOR_BLUE}"Введите имя пользователя: "${COLOR_NC}"
    read username
    #Проверка существования системного пользователя "$username"
    	grep "^$username:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $username существует
    		clear
    		echo -e "${COLOR_YELLOW}Сводная информация о пользователе ${COLOR_GREEN}\"$username\":${COLOR_NC}"
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
