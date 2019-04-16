#!/bin/bash

declare -x -f menuMain
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

                echo '1: Управление сайтами'
                echo '2: Управление пользователями ОС'
                echo '3: Управление пользователями MySQL'
                echo '4: Управление базами данных'
                echo '5: Управление бэкапами'
                echo '6: Git'
                echo '7: Testing'
                echo '8: Сервер'
                echo 'q: Выход'
                echo ''
                echo -n 'Выберите пункт меню:'

                while read
                do
                    case "$REPLY" in
                    "1") source /my/scripts/include/inc.sh && menuSite $USERNAME;  break;;
                    "2") source /my/scripts/include/inc.sh && menuUser $USERNAME;  break;;
                    "3") source /my/scripts/include/inc.sh && menuUserMysql $USERNAME;  break;;
                    "4") source /my/scripts/include/inc.sh && menuMysql $USERNAME;  break;;
                    "5") source /my/scripts/include/inc.sh && menuBackups $USERNAME;  break;;
                    "6") source /my/scripts/include/inc.sh && menuGit $USERNAME;  break;;
                    "8") source /my/scripts/include/inc.sh &&  menuServer $USERNAME;  break;;
                    "q"|"Q")  exit 0;;
                     *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                    esac
                done
                return 0
}


declare -x -f menuUser
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

                echo '0: Назад'
                echo 'q: Выход'
                echo ''
                echo -n 'Выберите пункт меню:'

                while read
                    do
                        case "$REPLY" in
                        "1")  sudo bash -c "source $SCRIPTS/include/inc.sh; input_userAddSystem $1"; menuUser $1; break;;
                        "2")  input_userDelete_system; menuUser $1; break;;
                        "0")  menuMain $1;  break;;
                        "q"|"Q")  exit 0;;
                         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                        esac
                    done
}


declare -x -f menuSite
#Меню управления сайтами
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuSite() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление сайтами===${COLOR_NC}"

        echo '1: Добавить сайт на сервер'
        echo '2: Удаление сайта с сервера'
        echo '3: Удаление конфигов с сайта'
        echo '4: Управление сертификатами'
        echo '5: Список виртуальных хостов на сервере'


        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")  menuSiteAdd $1; break;;
                "2")  input_siteRemove $1; menuSite $1;  break;;
                "3")  input_siteConfigRemove $1; menuSite $1; break;;
                "4")  menuSite_cert $1; break;;
                "5")  $SCRIPTS/info/site_info/show_sites.sh $1; break;;
                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuSite\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f menuGit
#Вывод меню git
###!ПОЛНОСТЬЮ ГОТОВО. 03.04.2019
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


declare -x -f menuSiteAdd
#Меню добавление сайтов
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuSiteAdd() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Добавление сайтов===${COLOR_NC}"

        echo '1: PHP/HTML (с вводом доп.параметров)'
        echo '2: PHP/HTML (Nginx-Frontend, Apache2-Backend)'
        echo '3: PHP/HTML (Nginx-Port 80, Apache2-Port 8080)'
        echo '4: Laravel (с вводом доп.параметров)'
        echo '5: Laravel (Nginx-Frontend, Apache2-Backend)'
        echo '6: Laravel (Nginx-Port 80, Apache2-Port 8080)'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1") sudo bash -c "source $SCRIPTS/include/inc.sh; input_SiteAdd $1 php querry;";  menuSiteAdd $1; break;;
                "2") sudo bash -c "source $SCRIPTS/include/inc.sh; input_SiteAdd $1 php reverseProxy;"; menuSiteAdd $1; break;;
                "3") sudo bash -c "source $SCRIPTS/include/inc.sh; input_SiteAdd $1 php lite;"; menuSiteAdd $1; break;;
                "4") sudo bash -c "source $SCRIPTS/include/inc.sh; input_SiteAdd $1 laravel querry;";  menuSiteAdd $1; break;;
                "5") sudo bash -c "source $SCRIPTS/include/inc.sh; input_SiteAdd $1 laravel reverseProxy;"; menuSiteAdd $1; break;;
                "6") sudo bash -c "source $SCRIPTS/include/inc.sh; input_SiteAdd $1 laravel lite;"; menuSiteAdd $1; break;;

                "0")  menuSite $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuSiteAdd\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f menuUserMysql
#Меню управление пользователями mysql
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuUserMysql() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление пользователями mysql===${COLOR_NC}"

        echo '1: Добавить пользователя'
        echo '2: Добавить дополнительного пользователя'
        echo '3: Добавить дополнительного пользователя к указанному'
        echo '4: Удалить пользователя'
        echo '5: Сменить тип доступа к серверу для пользователя'
        echo '6: Просмотр списка пользователей'
        echo '7: Смена проля для пользователя'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1") input_dbUseradd $1 main; menuUserMysql $1; break;;
                "2") input_dbUseradd $1 dop; menuUserMysql $1; break;;
                "3") input_dbUseradd $1 dop_querry; menuUserMysql $1; break;;
                "4") input_dbUserDelete_querry $1; break;;
                "5") input_dbUserChangeAccess; menuUserMysql $1; break;;
                "6") dbViewAllUsers $1; menuUserMysql $1; break;;
                "7") input_dbChangeUserPassword $1; menuUserMysql $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuUserMysql\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f menuMysql
#Меню управление базами данных mysql
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuMysql() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление базами данных mysql===${COLOR_NC}"

        echo '1: Добавить базу данных'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1") input_dbCreate $1; menuMysql $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuMysql\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f menuBackups
#Меню управления бэкапами
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuBackups() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление бэкапами===${COLOR_NC}"

        echo '1: Создать файловый бэкап сайта'
        echo '2: Восстановить файловый бэкап сайта'
        echo '3: Управление бэкапами баз данных mysql'

        echo '5: Просмотр бэкапов'
        echo '+++6: Создание бэкапа каталога в /etc'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")   $1; break;;
                "2")   $1; break;;
                "3")  menuBackups_mysql $1; break;;
                "4")   $1; break;;
                "5")  menuBackups_show $1; break;;
                "6")  input_backupEtcFolder $1; menuBackups $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuBackups\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f menuServer
#Меню управления сервером
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuServer() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление сервером===${COLOR_NC}"

        echo '1: Firewall ufw'
        echo '2: Quota'

        echo '9: Перезапустить Apache2 и Nginx'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")   $1; break;;
                "2") menuServer_quota $1; break;;

                "9")   $1; break;;
                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuServer\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




declare -x -f menuSite_cert
#Меню управления сертификатами сайтов
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuSite_cert() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление сертификатами сайтов===${COLOR_NC}"

        echo '1: Добавить сайту SSL-сертификат (NGINX-manual)'
        echo '2: Добавить сайту SSL-сертификат (NGINX-auto)'
        echo '3: Добавить сайту SSL-сертификат (APACHE)'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1") sudo bash -c "source $SCRIPTS/include/inc.sh; input_siteAddSSL $1 manual; menuSite_cert $1"; break;;
                "2") sudo bash -c "source $SCRIPTS/include/inc.sh; input_siteAddSSL $1 auto; menuSite_cert $1"; break;;
                "3") sudo certbot --apache; menuSite_cert $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuSite_cert\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f menuUsers_info
#Меню просмотра информации о пользователях
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuUsers_info() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Информация о пользователях===${COLOR_NC}"

        echo "1: Члены группы \"Users\""
        echo "2: Члены группы \"Users\", содаржащих определенные символы"
        echo "3: Список пользователей группы \"sudo\""
        echo "4: Список пользователей группы \"sudo\", содаржащих определенные символы"
        echo "5: Список пользователей группы \"admin-access\""
        echo "6: Список пользователей группы \"admin-access\", содаржащих определенные символы"
        echo "7: Список пользователей группы \"ssh-access\""
        echo "8: Список пользователей группы \"ftp-access\""
        echo "9: Список пользователей произвольной группы"
        echo "10: Список групп конкретного пользователя"
        echo "11: Сводная информация о пользователе"

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1") clear; viewGroupUsersAccessAll "Список пользователей группы \"Users\":"  $1; menuUsers_info $1; break;;
                "2") input_viewUserInGroupUsersByPartName; menuUsers_info $1; break;;
                "3") clear; viewGroupSudoAccessAll; menuUsers_info $1; break;;
                "4") input_viewGroupSudoAccessByName; menuUsers_info $1; break;;
                "5") clear; viewGroupAdminAccessAll; menuUsers_info $1; $1; break;;
                "6") input_viewGroupAdminAccessByName; menuUsers_info $1; break;;
                "7") clear; viewUsersInGroup "ssh-access"; menuUsers_info $1; break;;
                "8") clear; viewUsersInGroup "ftp-access"; menuUsers_info $1; break;;
                "9") input_viewGroup; menuUsers_info $1; break;;
                "10") input_viewUsersInGroup; menuUsers_info $1; break;;
                "11") input_viewUserFullInfo; menuUsers_info $1; break;;


                "0")  menuUsers_info $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuUsers_info\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f menuBackups_mysql
#Меню создания бэкапов баз данных mysql
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuBackups_mysql() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление бэкапами баз данных mysql===${COLOR_NC}"

        echo '1: Создать копию всех баз всего сервера'
        echo '2: Создать копию всех баз конкретного пользователя'
        echo '3: Создать копию одной базы'
        echo '4: Восстановить из бэкапа сервер баз данных'
        echo '5: Восстановить из бэкапа все базы пользователя'
        echo '6: Восстановить из бэкапа одну базу'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")   $1; break;;
                "2")   $1; break;;
                "3")   $1; break;;
                "4")   $1; break;;
                "5")   $1; break;;
                "6")   $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuBackups_mysql\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f menuBackups_show
#Меню просмотра бэкапов
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuBackups_show() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Просмотр бэкапов===${COLOR_NC}"

        echo '1: Бэкапы за сегодняшний день'
        echo '2: Бэкапы за вчерашний день'
        echo '3: Бэкапы за последнюю неделю'
        echo '4: Указать дату'
        echo '5: Указать диапазон дат'


        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")   $1; break;;
                "2")   $1; break;;
                "3")   $1; break;;
                "4")   $1; break;;
                "5")   $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuBackups_show\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



declare -x -f menuServer_firewall
#Меню управление firewall
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuServer_firewall() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление Firewall===${COLOR_NC}"

        echo '1: Добавить открытый порт'
        echo '2: Просмотр открытых портов'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")   $1; break;;
                "2")   $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuServer_firewall\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f menuServer_quota
#Меню управления квотами
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
menuServer_quota() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление квотами===${COLOR_NC}"

        echo '1: Отчет'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")  sudo repquota -a; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
                "q"|"Q")  exit 0;;
                 *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                esac
            done
        exit 0
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuServer_quota\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
