#!/bin/bash
declare -x -f menuMain

declare -x -f menuSite
declare -x -f menuUser
declare -x -f menuUserMysql
declare -x -f menuMysql
declare -x -f menuBackups
declare -x -f menuGit
declare -x -f menuServer


#Вывод главного меню
#$1-username ;
#return
#0 - выполнено успешно,
#2 - нет пользователя
menuMain() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				USERNAME=$1
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"menuMain\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		USERNAME=$(whoami)
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

 	            echo ''
                echo -e "${COLOR_GREEN} ====Главное меню==== ${COLOR_NC}"

#                echo '1: Управление сайтами'
                echo '2: Управление пользователями ОС'
#                echo '3: Управление пользователями MySQL'
#                echo '4: Управление базами данных'
#                echo '5: Управление бэкапами'
                echo '6: Git'
#                echo '7: Testing'
#                echo '8: Сервер'
                echo 'q: Выход'
                echo ''
                echo -n 'Выберите пункт меню:'

                while read
                do
                    case "$REPLY" in
#                    "1") source /my/scripts/include/inc.sh && menuSite $USERNAME;  break;;
                    "2") source /my/scripts/include/inc.sh && menuUser $USERNAME;  break;;
#                    "3") source /my/scripts/include/inc.sh && menuUserMysql $USERNAME;  break;;
#                    "4") source /my/scripts/include/inc.sh && menuMysql $USERNAME;  break;;
#                    "5") source /my/scripts/include/inc.sh && menuBackups $USERNAME;  break;;
                    "6") source /my/scripts/include/inc.sh && menuGit $USERNAME;  break;;
                    "8") source /my/scripts/include/inc.sh &&  menuServer $USERNAME;  break;;
                    "q"|"Q")  exit 0;;
                     *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                    esac
                done
                return 0
}

#Меню управления сайтами
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#menuSite() {
#	#Проверка на существование параметров запуска скрипта
#	if [ -n "$1" ]
#	then
#	#Параметры запуска существуют
#        echo ''
#        echo -e "${COLOR_GREEN} ===Управление сайтами===${COLOR_NC}"
#
#        echo '1: Добавить сайт на сервер'
#        echo '2: Удаление сайта с сервера'
#        echo '3: Список виртуальных хостов на сервере'
#        echo '4: Сертификаты'
#
#        echo '0: Назад'
#        echo 'q: Выход'
#        echo ''
#        echo -n 'Выберите пункт меню:'
#
#        while read
#            do
#                case "$REPLY" in
#                "1")  menuSiteAdd $1; break;;
#                "2")  input_siteRemove $1;  break;;
#                "3")  $SCRIPTS/info/site_info/show_sites.sh $1; break;;
#                "4")  $MENU/submenu/site_cert.sh $1; break;;
#                "0")  $MYFOLDER/scripts/menu $1;  break;;
#                "q"|"Q")  exit 0;;
#                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
#                esac
#            done
#        exit 0
#	#Параметры запуска существуют (конец)
#	else
#	#Параметры запуска отсутствуют
#		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuSite\"${COLOR_RED} ${COLOR_NC}"
#		return 1
#	#Параметры запуска отсутствуют (конец)
#	fi
#	#Конец проверки существования параметров запуска скрипта
#}

#Меню пользователей
menuUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				USERNAME=$1
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"menuMain\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		USERNAME=$(whoami)
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

 	            echo ''
                echo -e "${COLOR_GREEN} ===Управление пользователями===${COLOR_NC}"

                echo '1: Добавить пользователя'
                echo '2: Удаление пользователя'
                echo '3: Информация о пользователях'

                echo '0: Назад'
                echo 'q: Выход'
                echo ''
                echo -n 'Выберите пункт меню:'

                while read
                    do
                        case "$REPLY" in
                        "1")  sudo bash -c "source $SCRIPTS/include/inc.sh; input_userAddSystem $1"; menuUser $1; break;;
                        "2")  input_userDelete_system; break;;
                        "3")  menuUsers_info $1; break;;
                        "0")  menuMain $1;  break;;
                        "q"|"Q")  exit 0;;
                         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                        esac
                    done
}

#Меню управление пользователями mysql
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#menuUserMysql() {
#	#Проверка на существование параметров запуска скрипта
#	if [ -n "$1" ]
#	then
#	#Параметры запуска существуют
#        echo ''
#        echo -e "${COLOR_GREEN} ===Управление пользователями mysql===${COLOR_NC}"
#
#        echo '1: Добавить пользователя'
#        echo '2: Добавить дополнительного пользователя'
#        echo '3: Добавить дополнительного пользователя к указанному'
#        echo '4: Удалить пользователя'
#        echo '5: Сменить тип доступа к серверу для пользователя'
#        echo '6: Просмотр списка пользователей'
#        echo '7: Смена проля для пользователя'
#
#        echo '0: Назад'
#        echo 'q: Выход'
#        echo ''
#        echo -n 'Выберите пункт меню:'
#
#        while read
#            do
#                case "$REPLY" in
#                "1") input_dbUseradd $1 main; menuUserMysql $1; break;;
#                "2") input_dbUseradd $1 dop; menuUserMysql $1; break;;
#                "3") input_dbUseradd $1 dop_querry; menuUserMysql $1; break;;
#                "4") input_dbUserDelete_querry $1; break;;
#                "5") input_dbUserChangeAccess; menuUserMysql $1; break;;
#                "6") dbViewAllUsers $1; menuUserMysql $1; break;;
#                "7") input_dbChangeUserPassword $1; menuUserMysql $1; break;;
#
#                "0")  $MYFOLDER/scripts/menu $1;  break;;
#                "q"|"Q")  exit 0;;
#                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
#                esac
#            done
#        exit 0
#	#Параметры запуска существуют (конец)
#	else
#	#Параметры запуска отсутствуют
#		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuUserMysql\"${COLOR_RED} ${COLOR_NC}"
#		return 1
#	#Параметры запуска отсутствуют (конец)
#	fi
#	#Конец проверки существования параметров запуска скрипта
#}

#Меню управление базами данных mysql
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#menuMysql() {
#	#Проверка на существование параметров запуска скрипта
#	if [ -n "$1" ]
#	then
#	#Параметры запуска существуют
#        echo ''
#        echo -e "${COLOR_GREEN} ===Управление базами данных mysql===${COLOR_NC}"
#
#        echo '1: Добавить базу данных'
#
#        echo '0: Назад'
#        echo 'q: Выход'
#        echo ''
#        echo -n 'Выберите пункт меню:'
#
#        while read
#            do
#                case "$REPLY" in
#                "1")   $1; break;;
#
#                "0")  $MYFOLDER/scripts/menu $1;  break;;
#                "q"|"Q")  exit 0;;
#                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
#                esac
#            done
#        exit 0
#	#Параметры запуска существуют (конец)
#	else
#	#Параметры запуска отсутствуют
#		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuMysql\"${COLOR_RED} ${COLOR_NC}"
#		return 1
#	#Параметры запуска отсутствуют (конец)
#	fi
#	#Конец проверки существования параметров запуска скрипта
#}

#Меню управления бэкапами
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#menuBackups() {
#	#Проверка на существование параметров запуска скрипта
#	if [ -n "$1" ]
#	then
#	#Параметры запуска существуют
#        echo ''
#        echo -e "${COLOR_GREEN} ===Управление бэкапами===${COLOR_NC}"
#
#        echo '1: Создать файловый бэкап сайта'
#        echo '2: Восстановить файловый бэкап сайта'
#        echo '3: Управление бэкапами баз данных mysql'
#        echo '5: Просмотр бэкапов'
#
#        echo '0: Назад'
#        echo 'q: Выход'
#        echo ''
#        echo -n 'Выберите пункт меню:'
#
#        while read
#            do
#                case "$REPLY" in
#                "1")   $1; break;;
#                "2")   $1; break;;
#                "3")  menuBackups_mysql $1; break;;
#                "4")   $1; break;;
#                "5")  menuBackups_show $1; break;;
#
#                "0")  $MYFOLDER/scripts/menu $1;  break;;
#                "q"|"Q")  exit 0;;
#                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
#                esac
#            done
#        exit 0
#	#Параметры запуска существуют (конец)
#	else
#	#Параметры запуска отсутствуют
#		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuBackups\"${COLOR_RED} ${COLOR_NC}"
#		return 1
#	#Параметры запуска отсутствуют (конец)
#	fi
#	#Конец проверки существования параметров запуска скрипта
#}

#Вывод меню git
#$1-username ;
#return 0 - выполнено успешно, 2 - нет пользователя
menuGit() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				USERNAME=$1
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"menuMain\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		USERNAME=$(whoami)
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

 	            echo ''
                echo -e "${COLOR_GREEN} ===Управление Git===${COLOR_NC}"

                echo '1: Git commit'
                echo '2: Push remote'
                echo '3: Git remote view'


                echo '0: Назад'
                echo 'q: Выход'
                echo ''
                echo -n 'Выберите пункт меню:'

                while read
                    do
                        case "$REPLY" in
                        "1")  Git_commit $1; break;;
                        "2")  Git_remotePush $1; break;;
                        "3")  Git_remoteView $1; break;;
                        "0")  menuMain $1;  break;;
                        "q"|"Q")  exit 0;;
                         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                        esac
                    done
                    return 0
}

#Меню управления сервером
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#menuServer() {
#	#Проверка на существование параметров запуска скрипта
#	if [ -n "$1" ]
#	then
#	#Параметры запуска существуют
#        echo ''
#        echo -e "${COLOR_GREEN} ===Управление сервером===${COLOR_NC}"
#
#        echo '1: Firewall ufw'
#        echo '2: Quota'
#
#        echo '9: Перезапустить Apache2 и Nginx'
#
#        echo '0: Назад'
#        echo 'q: Выход'
#        echo ''
#        echo -n 'Выберите пункт меню:'
#
#        while read
#            do
#                case "$REPLY" in
#                "1")   $1; break;;
#                "2") menuServer_quota $1; break;;
#
#                "9")   $1; break;;
#                "0")  $MYFOLDER/scripts/menu $1;  break;;
#                "q"|"Q")  exit 0;;
#                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
#                esac
#            done
#        exit 0
#	#Параметры запуска существуют (конец)
#	else
#	#Параметры запуска отсутствуют
#		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuServer\"${COLOR_RED} ${COLOR_NC}"
#		return 1
#	#Параметры запуска отсутствуют (конец)
#	fi
#	#Конец проверки существования параметров запуска скрипта
#}
