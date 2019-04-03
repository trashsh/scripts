#!/bin/bash
####################################users#######################

declare -x -f userDelete_system
declare -x -f userExistInGroup
declare -x -f existGroup
declare -x -f viewGroupAdminAccessAll
declare -x -f viewGroupAdminAccessByName
declare -x -f viewGroupSudoAccessAll
declare -x -f viewGroupSudoAccessByName
declare -x -f viewUserInGroupUsersByPartName
declare -x -f viewUserInGroupByName
declare -x -f viewUsersInGroup
declare -x -f userAddToGroup
declare -x -f userDeleteFromGroup
declare -x -f userChangePassword

#TODO сделать проверку на отсутствие - при вводе имени или

####################################mysql########################
declare -x -f dbSetMyCnfFile
declare -x -f dbUseradd
declare -x -f dbDropUser
declare -x -f dbSetFullAccessToBase
declare -x -f dbViewUserGrant
declare -x -f dbShowTables
declare -x -f dbViewAllUsers
declare -x -f dbViewAllBases
declare -x -f dbViewBasesByTextContain
declare -x -f dbViewAllUsersByContainName
declare -x -f dbViewUserInfo
declare -x -f dbDeleteRecordFromDb
declare -x -f dbExistTable
declare -x -f dbChangeUserPassword
declare -x -f dbUserChangeAccess
declare -x -f dbBackupBasesOneDomain
declare -x -f dbSetUpdateInfoAccessToBase
declare -x -f dbRecordAdd_addBase
declare -x -f dbRecordAdd_addDbUser
declare -x -f dbUserSetAccessToBase
declare -x -f input_dbChangeUserPassword
declare -x -f input_dbUserDeleteBase



####################################Files################################

####################################webserver################################
declare -x -f webserverRestart
declare -x -f webserverReload
declare -x -f viewPHPVersion
declare -x -f viewSiteConfigsByName
declare -x -f viewSiteFoldersByName
####################################site#####################################
declare -x -f viewFtpAccess
declare -x -f viewSshAccess
declare -x -f siteAdd_php
declare -x -f input_siteRemove
declare -x -f siteRemove
declare -x -f siteAddTestIndexFile
declare -x -f siteRemoveWebserverConfig
declare -x -f siteRemoveLogs
declare -x -f siteAddFtpUser
declare -x -f input_siteAddFtpUser
declare -x -f siteStatus
declare -x -f accessDetails
declare -x -f input_siteExist
declare -x -f siteExist
declare -x -f siteChangeWebserverConfigs
############################ufw#############################
declare -x -f ufwAddPort
declare -x -f ufwOpenPorts

############################backups##########################################


declare -x -f dbBackupBasesOneUser

declare -x -f backupSiteFiles
declare -x -f backupUserSitesFiles
declare -x -f backupSiteWebserverConfig
###########################SSH-server########################################
declare -x -f sshKeyGenerateToUser
declare -x -f sshKeyAddToUser
declare -x -f sshKeyImport

#############################menuSite##################################################
declare -x -f menuMain
declare -x -f menuSite
declare -x -f menuSiteAdd
declare -x -f menuSite_cert
declare -x -f menuUser
declare -x -f menuUsers_info
declare -x -f menuUserMysql
declare -x -f menuGit
declare -x -f menuGit_commit
declare -x -f menuGit_remotePush
declare -x -f menuGit_remoteView
declare -x -f menuBackups
declare -x -f menuBackups_show
declare -x -f menuBackups_mysql
declare -x -f menuServer
declare -x -f menuServer_firewall
declare -x -f menuServer_quota
declare -x -f menuMysql




######################################input##########################################
declare -x -f input_SiteAdd_php
declare -x -f input_viewUsersInGroup
declare -x -f input_viewUserFullInfo
declare -x -f input_viewGroupAdminAccessByName
declare -x -f input_viewGroupSudoAccessByName
declare -x -f input_viewUserInGroupUsersByPartName
declare -x -f input_viewGroup


declare -x -f input_dbUseradd
declare -x -f input_dbUserDelete_querry
declare -x -f input_dbUserChangeAccess



####################################search##########################################
declare -x -f searchSiteFolder
declare -x -f searchSiteConfig
declare -x -f searchSiteConfigAllFolder

####################################testing##########################################



#######################################USERS##########################################










###input
#$1- username;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - удаление завершилось с ошибкой
userDelete_system() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				sudo userdel -r $1
				dbDeleteRecordFromDb lamer_webserver users username $1 delete
				#Проверка на успешность выполнения предыдущей команды
				if [ $? -eq 0 ]
					then
						#предыдущая команда завершилась успешно
						return 0
						#предыдущая команда завершилась успешно (конец)
					else
						#предыдущая команда завершилась с ошибкой
						return 3
						#предыдущая команда завершилась с ошибкой (конец)
				fi
				#Конец проверки на успешность выполнения предыдущей команды
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"userDelete_system\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"userDelete_system\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Смена пароля пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1-user ;
#$2-mode set password: manual/querry/autogenerate ;

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - пароль пустой
userChangePassword() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
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
				infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt
				fileAddLineToFile $infoFile "Username: $1"
                fileAddLineToFile $infoFile "Password: $password"
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

#Существует ли группа $1
#Полностью готово. 12.03.2019
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


#Вывод всех пользователей группы admin-access
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
viewGroupAdminAccessAll(){
	echo -e "\n${COLOR_YELLOW}Список пользователей группы \"admin-access:\":${COLOR_NC}"
	more /etc/group | grep admin-access: | highlight magenta "admin-access"
}


#Вывод всех пользователей группы admin-access с указанием части имени пользователя
#Полностью готово. 13.03.2019
###input
#$1 - имя пользователя
###return
#1 - не переданы параметры
viewGroupAdminAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы ${COLOR_GREEN}\"admin-access\"${COLOR_YELLOW}, содержащих в имени ${COLOR_GREEN}\"$1\":${COLOR_NC}"
		more /etc/group | grep -E "admin.*$1" | highlight green "$1" | highlight magenta "admin-access"
		#Проверка на успешность выполнения предыдущей команды
		#Конец проверки на успешность выполнения предыдущей команды
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewGroupAdminAccessByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

#Вывод всех пользователей группы sudo
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
viewGroupSudoAccessAll(){
		echo -e "\n${COLOR_YELLOW}Список пользователей группы \"sudo\":${COLOR_NC}"
		more /etc/group | grep sudo: | highlight magenta "sudo"
}


#Вывод пользователей группы sudo с указанием части имени пользователя
#Полностью готово. 13.03.2019 г.
###input
#$1 - имя пользователя
###return
#1 - не переданы параметры в функцию
viewGroupSudoAccessByName(){
	if [ -n "$1" ]
	then
		echo -e "\n${COLOR_YELLOW}Список пользователей группы ${COLOR_GREEN}\"sudo\"${COLOR_YELLOW}, содержащих в названии ${COLOR_GREEN}\"$1\"${COLOR_NC}:${COLOR_NC}"
		more /etc/group | grep sudo: | highlight green "$1" | highlight magenta "sudo"
	else
		echo -e "${COLOR_RED}Не передан параметр в функцию ${COLOR_GREEN}\"viewGroupSudoAccessByName\"${COLOR_RED} в файле $0. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}


#Вывод списка пользователей, входящих в группу users по части имени пользователя $1
#Полностью готово. 13.03.2019
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


#Вывод групп, в которых состоит указанный пользователь
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###input
#$1 - имя пользователя
#return
#0 - выполнено успешно,
#1 - не передан параметр
viewUserInGroupByName(){
	if [ -n "$1" ]
		then
			cat /etc/group | grep -P $1 | highlight green $1 | highlight magenta "ssh-access" | highlight magenta "ftp-access" | highlight magenta "sudo" | highlight magenta "admin-access"
			userExistInGroup $1 users
		        #Проверка на успешность выполнения предыдущей команды
		        if [ $? -eq 0 ]
		        	then
		        		#предыдущая команда завершилась успешно
		        		echo -e "users:x:100:$1" | highlight green "$1" | highlight magenta "users"
		        		return 0
		        		#предыдущая команда завершилась успешно (конец)
		        fi
		        #Конец проверки на успешность выполнения предыдущей команды
			return 0
		else
			echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUserInGroupByName\"${COLOR_RED} ${COLOR_NC}"
			return 1
		fi
}

#Вывод списка пользователей, входящих в группу $1
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###input:
#$1-группа ;
#return
#0 - выполнено успешно,
#1- отсутствуют параметры,
#2 - группа не существует
viewUsersInGroup() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системной группы пользователей "$1"
		if grep -q $1 /etc/group
		    then
		        #Группа "$1" существует
		         echo -e "\n${COLOR_YELLOW}Список пользователей группы ${COLOR_GREEN}\"$1\":${COLOR_NC}"
	             more /etc/group | grep "$1:" | highlight magenta "$1"
	             if [ "$1" == "users" ]
	                then viewGroupUsersAccessAll
	             fi
	             return 0
		        #Группа "$1" существует (конец)
		    else
		        #Группа "$1" не существует
		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
				return 2
				#Группа "$1" не существует (конец)
		    fi
		#Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUsersInGroup\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Добавить пользователя в группу
#Проверно полностью. 13.03.2019
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



#############################################MYSQL###############################################
#Добавление пользователя mysql
#$1-user ;
#$2-password ;
#$3-host ;
#$4-autentification_type {pass,sha,socket}  ;
#$5-usertype ; {user, admin, adminGrant}
#return 0 - выполнено успешно,
# 1 - отсутствуют параметры запуска
# 2 - неверный параметр usertype,
# 3 - пользователь уже существует,
# 4 - ошибка после выполнения команды на создание пользователя,
# 5 - неверный параметр autentification_type
dbUseradd() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
    #Проверка существования пользователя mysql $1

        #Проверка на существование пользователя mysql "$1"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
        then
        #Пользователь mysql "$1" существует
            echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUseradd\"${COLOR_NC}"
            return 3
        #Пользователь mysql "$1" существует (конец)
        else
        #Пользователь mysql "$1" не существует
            #Проверка правильности параметра $4-autentification_type
            case "$4" in
                        "pass")
                            auth="mysql_native_password";;
                        "sha")
                            auth="sha256_password";;
                        "socket")
                            auth="auth_socket";;
                        *)
                            echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_GREEN}\"dbUseradd-dbViewUserInfo-autentification_type\"${COLOR_NC}";
                            return 5;;
                    esac

                #Проверка правильности параметра $4-autentification_type (конец)
                    #Проверка правильности параметра $5 - тип пользователя
                    case "$5" in
                        "user")  #обычный пользователь
                            mysql -e "CREATE USER '$1'@'$3' IDENTIFIED BY '$2'; GRANT USAGE ON *.* TO '$1'@'$3' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
                            mysql -e "FLUSH PRIVILEGES;"
                            ;;
                        "admin")  mysql -e "GRANT ALL PRIVILEGES ON *.* To '$1'@'$3' IDENTIFIED BY '$2';";
                            mysql -e "FLUSH PRIVILEGES;";
                            ;;
                        "adminGrant")  mysql -e "GRANT ALL PRIVILEGES ON *.* To '$1'@'$3' IDENTIFIED BY '$2' WITH GRANT OPTION;";
                            mysql -e "FLUSH PRIVILEGES;";
                            ;;
                        *)
                            echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_GREEN}\"dbUseradd-dbViewUserInfo-usertype\"${COLOR_NC}";
                            return 2;;
                    esac
                    #Проверка правильности параметра $5 - тип пользователя(конец)

                    #Проверка на существование пользователя mysql "$1" после выполнения всех действий
                    if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
                    then
                    #Пользователь mysql "$1" существует
                        echo -e "${COLOR_GREEN}\nПользователь mysql ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно создан ${COLOR_NC}"
                        dbAddRecordToDb lamer_webserver db_users username $1 insert
                        infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt

                        fileAddLineToFile $infoFile "---
                        "
                        fileAddLineToFile $infoFile "Mysql-User:"
                        fileAddLineToFile $infoFile "Phpmyadmin: http://$MYSERVER:$APACHEHTTPPORT/$PHPMYADMINFOLDER"
                        fileAddLineToFile $infoFile "Server: $MYSERVER"
                        fileAddLineToFile $infoFile "Port: 3306"
                        fileAddLineToFile $infoFile "Username: $1"
                        fileAddLineToFile $infoFile "Password: $2"
                        fileAddLineToFile $infoFile "Host: $3"
                        fileAddLineToFile $infoFile "------------------------"

                        #Проверка существования системного пользователя "$1"
                        	grep "^$1:" /etc/passwd >/dev/null
                        	if  [ $? -eq 0 ]
                        	then
                        	#Пользователь $1 существует
                        	    dbSetMyCnfFile $1 $1 $2

                        	    dbSetUpdateInfoAccessToBase $WEBSERVER_DB $1 $3
                        	#Пользователь $1 существует (конец)
                        	fi
                        #Конец проверки существования системного пользователя $1

                        return 0
                    #Пользователь mysql "$1" существует (конец)
                    else
                    #Пользователь mysql "$1" не существует
                        echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не был создан. Произошла ошибка. ${COLOR_NC}"
                        return 4
                    #Пользователь mysql "$1" не существует (конец)
                    fi
                    #Конец проверки на существование пользователя mysql "$1"
                #Пользователь mysql - $1 не существует (конец)
        #Пользователь mysql "$1" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$1"


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUseradd\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}






#Добавление записи в базу о добавлении пользователя mysql
###input
#$1-user ;
#$2-homedir ;
#$3-created_by ;
#$4-userType (1-system, 2-ftp)
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
dbRecordAdd_addDbUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]  && [ -n "$4" ]
	then
	#Параметры запуска существуют

		#mysql-добавление информации о пользователе
    datetime=`date +%Y-%m-%d\ %H:%M:%S`
    dbAddRecordToDb $WEBSERVER_DB db_users username $1 insert
    dbUpdateRecordToDb $WEBSERVER_DB db_users username $1 created_by $3 update

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbRecordAdd_addDbUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Добавление записи в базу о добавлении пользователя
###input
#$1-dbname ;
#$2-characterSetId_db ;
#$3-collateId_db ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
dbRecordAdd_addBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют

    datetime=`date +%Y-%m-%d\ %H:%M:%S`
    dbAddRecordToDb $WEBSERVER_DB db name_db $1 insert
    dbUpdateRecordToDb $WEBSERVER_DB db name_db $1 characterSetId_db $2 update
    dbUpdateRecordToDb $WEBSERVER_DB db name_db $1 collateId_db $3 update
    dbUpdateRecordToDb $WEBSERVER_DB db name_db $1 collateId_db $3 update
    dbUpdateRecordToDb $WEBSERVER_DB db name_db $1 created_db "$datetime" update

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbRecordAdd_addBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Запрос имени пользователя для добавления пользователя mysql (основного пользователя)
###input
#$1 - системный пользователь, запускающий функцию
#$2 - mode (main/dop/dop_querry) - основной или дополнительный пользователь или дополнительный пользователь с запросом основного
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь уже существует
#3 - операция отменена пользователем
#4 - ошибка передачи параметра mode (main/dop/dop_querry)
#5 - основной пользователь mainUser не существует
input_dbUseradd() {
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ]
    then
    #Параметры запуска существуют

        clear
        echo -e "${COLOR_GREEN}"Добавление пользователя mysql"${COLOR_NC}"
        dbViewAllUsers

        case "$2" in
            main)
                echo -n -e "${COLOR_BLUE}\nВведите имя пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для добавления его в пользователи mysql: ${COLOR_NC}"
                read user
                username=$user
                ;;
            dop)
                echo -n -e "${COLOR_BLUE}\nВведите имя пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для добавления его в пользователи mysql \"${COLOR_YELLOW}$1--${COLOR_GREEN}User\"${COLOR_BLUE}: ${COLOR_NC}"
                read user
               mainUser=$1
               username=$mainUser--$user
                ;;
            dop_querry)
                  echo -n -e "${COLOR_BLUE}\nВведите имя основного пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для которого будет создан допонительный пользователь: ${COLOR_NC}"
                  read mainUser
                  #Проверка существования системного пользователя "$mainUser"
                  	grep "^$mainUser:" /etc/passwd >/dev/null
                  	if  [ $? -eq 0 ]
                  	then
                  	#Пользователь $mainUser существует
                  	    echo -n -e "${COLOR_BLUE}\nВведите имя пользователя (\"${COLOR_GREEN}User${COLOR_BLUE}\") для добавления его в пользователи mysql \"${COLOR_YELLOW}$mainUser--${COLOR_GREEN}User\"${COLOR_BLUE}: ${COLOR_NC}"
                  	    read user
                  		username=$mainUser--$user
                  	#Пользователь $mainUser существует (конец)
                  	else
                  	#Пользователь $mainUser не существует
                  	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$mainUser\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_NC}"
                  		return 5
                  	#Пользователь $mainUser не существует (конец)
                  	fi
                  #Конец проверки существования системного пользователя $mainUser
                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_NC}";
        	    return 4
        	    ;;
        esac


        #Проверка на существование пользователя mysql "$username"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
        then
        #Пользователь mysql "$username" существует
            clear
            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} уже существует.${COLOR_NC}"
            return 2
        #Пользователь mysql "$username" существует (конец)
        else
        #Пользователь mysql "$username" не существует
            echo -n -e "${COLOR_YELLOW}Для добавления пользователя mysql ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены добавления  - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                while read
                do
                    case "$REPLY" in
                        y|Y)

                            echo -n -e "Пароль для пользователя MYSQL ${COLOR_YELLOW}" $username "${COLOR_NC} сгенерировать или установить вручную? \nВведите ${COLOR_BLUE}\"y\"${COLOR_NC} для автогенерации, для ручного ввода - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                while read
                                do
                                    case "$REPLY" in
                                    y|Y) password="$(openssl rand -base64 14)";
                                        # echo -e "${COLOR_GREEN}Пароль для пользователя mysql ${COLOR_YELLOW}$usernameFull: ${COLOR_YELLOW}$password${COLOR_GREEN}  ${COLOR_NC}"
                                         break;;
                                    n|N) echo -n -e "${COLOR_BLUE} Введите пароль для пользователя MYSQL ${COLOR_NC} ${COLOR_YELLOW}\"$username\":${COLOR_NC}";
                                         read password;
                                         if [[ -z "$password" ]]; then
                                            #переменная имеет пустое значение
                                            echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена создания пользователя ${COLOR_GREEN}\"$username\""${COLOR_NC}"
                                            return 5
                                         fi
                                         break;;
                                    esac
                                done


                                echo -n -e "${COLOR_YELLOW}Выберите вид доступа пользователя к базам данных mysql ${COLOR_GREEN}\"localhost/%\"${COLOR_NC}: "
                                    while read
                                    do
                                        case "$REPLY" in
                                            localhost)
                                                host=localhost;
                                                break;;
                                            %)
                                                host="%";
                                                break;;
                                            *)
                                                 echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_YELLOW}\nПовторите ввод вида доступа пользователя ${COLOR_GREEN}\"localhost/%\":${COLOR_RED}  ${COLOR_NC}";;
                                        esac
                                done

                                dbUseradd $username $password $host pass user $1

                                dbSetMyCnfFile $username $username $password



                                case "$2" in
                                    main)
                                        param1=0
                                        ;;
                                    dop|dop_querry)
                                        param1=1
                                        ;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка доп.проверки параметра ${COLOR_GREEN}\"mode (main/dop/dop_querry)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_NC}";
                                	    ;;
                                esac


                                clear
                                echo -e "${COLOR_GREEN}Пользователь mysql ${COLOR_YELLOW}\"$username\"${COLOR_GREEN} успешно добавлен${COLOR_YELLOW}\"\"${COLOR_GREEN}  ${COLOR_NC}"
                                dbViewAllUsers
                                #dbCreateBase $username utf8 utf8_general_ci full_info

                            break
                            ;;
                        n|N)
                            echo -e "${COLOR_YELLOW}Отмена создания пользователя mysql ${COLOR_GREEN}\"$username\"${COLOR_YELLOW}${COLOR_NC}"
                            return 3;
                            break
                            ;;
                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                           ;;
                    esac
                done
        #Пользователь mysql "$$username" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$$username"


    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"input_dbUseradd\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта

}


#Удаление пользователя mysql
###Полностью готово. Не трогать. 07.03.2019 г.
###input:
#$1-user ;
#$2-"drop"-подтверждение ;
###return 0 - выполнено успешно,
#1 - не переданы параметры;
#2 - пользователь не существует;
#3 - подтверждение на удаление не получено
#$4 - пользователь не удалился
dbUserdel() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка наличия подтверждения на удаление
		if [ "$2" = "drop" ]
		then
		    #Получено подтверждение на удаление
            #проверка на существование пользователя mysql "$1"
            if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
            then
            #Пользователь mysql "$1" существует
                mysql -e "DROP USER IF EXISTS '$1'@'localhost';"
				mysql -e "DROP USER IF EXISTS '$1'@'%';"

                #Проверка на существование пользователя mysql "$1"
                if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
                then
                #Пользователь mysql "$1" не удалился
                    return 4
                #Пользователь mysql "$1" не удалился (конец)
                else
                #Пользователь mysql "$1" не существует
                    echo -e "${COLOR_GREEN}Пользователь mysql ${COLOR_YELLOW}$1${COLOR_GREEN} удален ${COLOR_NC}"
                    dbDeleteRecordFromDb lamer_webserver db_users username $1 delete
                    return 0
                #Пользователь mysql "$1" не существует (конец)
                fi
                #Конец проверки на существование пользователя mysql "$1"


            #Пользователь mysql "$1" существует (конец)
            else
            #Пользователь mysql "$1" не существует
                echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserdel\" ${COLOR_NC}"
                return 2
            #Пользователь mysql "$1" не существует (конец)
            fi
            #Конец проверки на существование пользователя mysql "$1"
            #Получено подтверждение на удаление - конец
        else
            #Не получено подтверждение на удаление
            echo -e "${COLOR_RED}Подтверждение на удаление пользователя ${COLOR_GREEN}\"$1\"${COLOR_RED} не получено. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserdel\"${COLOR_NC}"
            return 3
            #Не получено подтверждение на удаление (конец)
		fi
		#Проверка наличия подтверждения на удаление (конец)
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUserdel\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}





#Предоставление всех прав пользователю $1 на базу данных $1
###input:
#$1-dbname ;
#$2-user ;
#$3-host ;
###return:
#0 - выполнено успешно;
#1 - отсутствуют параметры;
#2 - пользователь не существует;
#3 - База данных не существует
dbSetFullAccessToBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#проверка на существование пользователя mysql "$2"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$2'" 2>&1`" ]];
		then
		#Пользователь mysql "$2" существует
		    #проверка существования базы данных "$1"
		    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
		    	then
		    	#база $1 - существует
				mysql -e "GRANT ALL PRIVILEGES ON $1.* TO $2@$3 REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0; FLUSH PRIVILEGES;"
				return 0
		    	#база $1 - существует (конец)
		    	else
		    	#база $1 - не существует
		    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetFullAccessToBase\" ${COLOR_NC}"
		    	     return 3
		    	#база $1 - не существует (конец)
		    fi
		    #конец проверки существования базы данных $1

		#Пользователь mysql "$2" существует (конец)
		else
		#Пользователь mysql "$2" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetFullAccessToBase\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$2" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$2"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetFullAccessToBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#обновление инфомрации в базе данных:
###input:
#$1-dbname ;
#$2-user ;
#$3-host ;
###return:
#0 - выполнено успешно;
#1 - отсутствуют параметры;
#2 - пользователь не существует;
#3 - База данных не существует
dbSetUpdateInfoAccessToBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#проверка на существование пользователя mysql "$2"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$2'" 2>&1`" ]];
		then
		#Пользователь mysql "$2" существует
		    #проверка существования базы данных "$1"
		    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
		    	then
		    	#база $1 - существует
				mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON \`$1\`.* TO '$2'@'$3';"
				return 0
		    	#база $1 - существует (конец)
		    	else
		    	#база $1 - не существует
		    	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetUpdateInfoAccessToBase\" ${COLOR_NC}"
		    	     return 3
		    	#база $1 - не существует (конец)
		    fi
		    #конец проверки существования базы данных $1

		#Пользователь mysql "$2" существует (конец)
		else
		#Пользователь mysql "$2" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetUpdateInfoAccessToBase\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$2" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$2"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetUpdateInfoAccessToBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

###Полностью готово. Не трогать. 07.03.2019 г.
#Смена пароля и создание файла ~/.my.cnf (только файл)
###input:
#$1-system user ;
#$2-mysql user ;
#$3-mysql password ;
#return:
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователь не существует
#3 - после выполнения функции файл my.cnf не найден
#4 - пользователь mysql $2 - не существует
dbSetMyCnfFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				#Проверка на существование пользователя mysql "$2"
				if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$2'" 2>&1`" ]];
				then
				#Пользователь mysql "$2" существует
                    #Проверка существования файла ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf""
                    if [ -f "$HOMEPATHWEBUSERS"/"$1"/"my.cnf" ] ; then
                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" существует
                             backupImportantFile $1 "my.cnf"  $HOMEPATHWEBUSERS/$1/.my.cnf
                             sudo sed -i "s/.*password=.*/password=$3/" $HOMEPATHWEBUSERS/$1/.my.cnf
                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" существует (конец)
                    else
                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" не существует
                            sudo touch $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo chmod 666 $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo cat $HOMEPATHWEBUSERS/$1/.my.cnf | sudo grep $HOMEPATHWEBUSERS
                                                {
                                        echo '[mysqld]'
                                        echo 'init_connect=‘SET collation_connection=utf8_general_ci’'
                                        echo 'character-set-server=utf8'
                                        echo 'collation-server=utf8_general_ci'
                                        echo ''
                                        echo '[client]'
                                        echo 'default-character-set=utf8'
                                        echo 'user='$2
                                        echo 'password='$3
                                        } > $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo chmod 600 $HOMEPATHWEBUSERS/$1/.my.cnf
                            sudo chown $1:users $HOMEPATHWEBUSERS/$1/.my.cnf

                            backupImportantFile $1 "my.cnf"  $HOMEPATHWEBUSERS/$1/.my.cnf

                            #Финальная проверка существования файла "$HOMEPATHWEBUSERS/$1/.my.cnf"
                            if [ -f $HOMEPATHWEBUSERS/$1/.my.cnf ] ; then
                                #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" существует
                                return 0
                                #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" существует (конец)
                            else
                                #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" не существует
                                echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"\"${COLOR_RED} не существует${COLOR_NC}"
                                return 3
                                #Файл "$HOMEPATHWEBUSERS/$1/.my.cnf" не существует (конец)
                            fi
                            #Финальная проверка существования файла "$HOMEPATHWEBUSERS/$1/.my.cnf" (конец)

                        #Файл ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf"" не существует (конец)
                    fi
                    #Конец проверки существования файла ""$HOMEPATHWEBUSERS"/"$1"/"my.cnf""

				#Пользователь mysql "$2" существует (конец)
				else
				#Пользователь mysql "$2" не существует
				    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetMyCnfFile\" ${COLOR_NC}"
				    return 4
				#Пользователь mysql "$2" не существует (конец)
				fi
				#Конец проверки на существование пользователя mysql "$2"
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbSetMyCnfFile\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbSetMyCnfFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод всех таблиц базы данных $1
###input:
#$1-dbname ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - база данных не существует
dbShowTables() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#проверка существования базы данных "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
			then
			#база $1 - существует
				mysql -e "SHOW TABLES FROM $1;"
				return 0
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbShowTables\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Вывод прав пользователя mysql на все базы
#Готово, но лучше проверить. 11.03.2019 г.
###input
#$1-user ;
#$2-host ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователь не существует
dbViewUserGrant() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then
		#Пользователь mysql "$1" существует
		    mysql -e "SHOW GRANTS FOR '$1'@'$2';"
		    return 0
		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"dbViewUserGrant\"${COLOR_NC}"
		    return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewUserGrant\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод списка всех пользователей mysql
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
dbViewAllUsers() {
    echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL ${COLOR_NC}"
	mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user;"
}

#Вывод списка всех баз данных
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
dbViewAllBases() {
    echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL ${COLOR_NC}"
	mysql -e "show databases;"
}


#Отобразить список всех баз данных mysql с названием, содержащим переменную $1
#Полностью готово. 12.03.2019
###input:
#$1-Переменная, по которой необходимо осуществить поиск баз данных ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователи отсутствуют
dbViewBasesByTextContain() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SHOW DATABASES LIKE '%$1%';") ]]; then
					#непустой результат
					echo -e "${COLOR_YELLOW}Перечень баз данных MYSQL содержащих в названии слово ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
			        mysql -e "SHOW DATABASES LIKE '%$1%';"
			        return 0
					#непустой результат (конец)
				else
				    #пустой результат
					echo -e "${COLOR_LIGHT_RED}\nБазы данных, в имени которых содержится значение ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} отсутствуют${COLOR_NC}"
					return 2
					#пустой результат (конец)
				fi
		#Конец проверки на пустой результат
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewBasesByTextContain\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Отобразить список всех пользователей mysql,содержащих в названии переменную $1
###input:
#$1-переменная для поиска пользователя ;
###return
#0 - выполнено успешно
#1 - отсутствуют параметры вызова функции
#2 - пользователи с заданным именем не существуют
dbViewAllUsersByContainName() {
	#Проверка на существование параметров запуска скрипта
		#Проверка на существование параметров запуска скрипта
		if [ -n "$1" ]
		then
		#Параметры запуска существуют
		    #проверка на пустой результат
		    		if [[ $(mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '%%$1%%' ORDER BY User ASC") ]]; then
		    			#непустой результат
		    			echo -e "${COLOR_YELLOW}Перечень пользователей MYSQL, содержащих в названии ${COLOR_GREEN}\"$1\" ${COLOR_NC}"
		                mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv,Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '%%$1%%' ORDER BY User ASC"
		                return 0
		    			#непустой результат (конец)
		    		else
		    		    #пустой результат
		    			echo -e "${COLOR_LIGHT_RED}Пользователи, в имени которых содержится значение ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} отсутствуют. Ошибка вызова функциии ${COLOR_YELLOW}\"dbViewAllUsersByContainName\"${COLOR_NC}"
		    			return 2
		    			#пустой результат (конец)
		    		fi
		    #Конец проверки на пустой результат
		#Параметры запуска существуют (конец)
		else
		#Параметры запуска отсутствуют
		    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewAllUsersByContainName\"${COLOR_RED} ${COLOR_NC}"
		    return 1
		#Параметры запуска отсутствуют (конец)
		fi
		#Конец проверки существования параметров запуска скрипта
}

#Вывести информацию о пользователе mysql $1. Проверка существования пользователя
#Полностью готово. 13.03.2019
###input
#$1-user ;
#$2-если в параметре значение "0", то результат не выводится, если "1" - результат выводится
###return
#0 - пользователь существует,
#1 - параметры не переданы
#2 - пользователь не существует;
dbViewUserInfo() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#проверка на пустой результат
				if [[ $(mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv, Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '$1' ORDER BY User ASC") ]]; then
					#непустой результат
                    #выводим или нет информацию о выполнении команды
			        case "$2" in
			        	0)  return 0
			        		;;
			        	1)
			        		echo -e "${COLOR_YELLOW}\nИнформация о пользователе MYSQL ${COLOR_GREEN}\"$1\" ${COLOR_NC}";
			                mysql -e "SELECT User,Host,Grant_priv,Create_priv,Drop_priv,Create_user_priv, Delete_priv,account_locked, password_last_changed FROM mysql.user WHERE User like '$1' ORDER BY User ASC";
			                return 0;;
			        	*)
			        		echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_GREEN}\"dbViewUserInfo\"${COLOR_NC}";;
			        esac
                    #выводим или нет информацию о выполнении команды (конец)
					#непустой результат (конец)
				else
				    #пустой результат
				    case "$2" in
				    	0)  return 2
				    		;;
				    	1)
				    		echo -e "${COLOR_LIGHT_RED}Пользователь mysql ${COLOR_YELLOW}\"$1\"${COLOR_LIGHT_RED} не существует ${COLOR_NC}";
					        return 2;;
				    	*)
				    		echo -e "${COLOR_RED}Ошибка передачи параметра в функцию ${COLOR_RED}\"dbViewUserInfo\"${COLOR_NC}";;
				    esac
					#пустой результат (конец)
				fi
		#Конец проверки на пустой результат
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbViewUserInfo\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}










#удаление записи из таблицы
#Полностью проверено. 13.03.2019
###input:
#$1-dbname ;
#$2-table;
#$3 - столбец;
#$4 - текст для поиска;
#$5-подтверждение "delete"
###return
#0 - выполнено успешно
#1 - отсутствуют параметры запуска
#2 - не существует база данных $2
#3 - таблица не существует
#4 - столбец не существует
#5 - запись отсутствует
#6  - отсутствует подтверждение
dbDeleteRecordFromDb() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
		#Проверка существования базы данных "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
			then
			#база $1 - существует
				#Проверка существования таблицы в базе денных $1
				if [[ ! -z "`mysql -qfsBe "SHOW TABLES FROM $1 LIKE '$2'" 2>&1`" ]];
					then
					#таблица $2 существует
                        #Проверка существования столбца $3 в таблице $2
                        if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$2'" 2>&1`" ]];
                        	then
                        	#столбец $2 существует
                                #Проверка существования записи в базе денных
                                if [[ ! -z "`mysql -qfsBe "SELECT $3 FROM $1.$2 WHERE $3='$4'" 2>&1`" ]];
                                	then
                                	#запись существует
                                		case "$5" in
                                			delete)
                                				mysql -e "DELETE FROM $2 WHERE $3 = '$4'" $1
                                				return 0
                                				;;
                                			*)
                                				echo -e "${COLOR_RED}Ошибка передачи подтверждения в функцию ${COLOR_GREEN}\"dbDeleteRecordFromDb\"${COLOR_NC}"
                                				return 6
                                				;;
                                		esac
                                	#запись существует (конец)
                                	else
                                	#запись не существует
                                        return 5
                                	#запись не существует
                                fi
                                #Проверка существования записи в базе денных (конец)
                        	#столбец $2 существует (конец)
                        	else
                        	#столбец $2 не существует

                        	    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$2\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
                        	    return 4
                        	#столбец $2 не существует (конец)
                        fi
                        #Проверка существования столбца $3 в таблице $2 (конец)
					#таблица $2 существует (конец)
					else
					#таблица $2 не существует
					     echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
					     return 3
					#таблица $2 не существует (конец)
				fi
				#Проверка существования таблицы в базе денных $1 (конец)
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbDeleteFromDbUsers\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




#Проверка существования таблицы
#Полностью проверено. 14.03.2019
###input
#$1-dbname ;
#$2-table
###return
#0 - таблица существует
#1- не переданы параметры
#2- база данных $1 не существует
#3-таблица не существует
dbExistTable() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования базы данных "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
			then
			#база $1 - существует

			    #Проверка существования таблицы в базе денных $1
			    if [[ ! -z "`mysql -qfsBe "SHOW TABLES FROM $1 LIKE '$2'" 2>&1`" ]];
			    	then
			    	#таблица $2 существует
			    		return 0
			    	#таблица $2 существует (конец)
			    	else
			    	#таблица $2 не существует
			    	     return 3
			    	    echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"\" ${COLOR_NC}"
			    	#таблица $2 не существует (конец)
			    fi
			    #Проверка существования таблицы в базе денных $1 (конец)

			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbExistTable\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbExistTable\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


##########################################BACKUPS################################################
#Создание бэкапа файлов сайта
#Полностью готово. Не трогать. Работает. 15.03.2019. Каталог по умолчанию в режиме querryCreateDestFolder при отсутствии папки все равно создается
###input
#$1-user ;
#$2-domain ;
#$3-mode:createDestFolder/querryCreateDestFolder
#$4-path destination; - не обязательно
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#3 - каталог не существует,
#4 - пользователь отменил создание каталога
#5 - ошибка передачи параметра mode:createDestFolder/querryCreateDestFolder
#6 - ошибка при проверке заархивированного файла
backupSiteFiles() {
    date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    #Проверка существования каталога "$HOMEPATHWEBUSERS/$1/$2"
	    if [ -d $HOMEPATHWEBUSERS/$1/$2 ] ; then
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует
            #Проверка на существование параметров запуска скрипта
            if [ -n "$4" ]
            then
            #Параметры запуска существуют
                #Проверка существования каталога "$4"
                if [ -d $4 ] ; then
                    #Каталог "$4" существует
                    DESTINATION=$4
                    #Каталог "$4" существует (конец)
                else
                    case "$3" in
                        createDestFolder)
                            mkdirWithOwn $4 $1 www-data 755;
                            DESTINATION=$4
                            ;;
                        querryCreateDestFolder)
                            echo -n -e "${COLOR_YELLOW}Каталог ${COLOR_GREEN}\"$4\"${COLOR_YELLOW} не существует. Введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW} для создания каталога или для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                                    while read
                                    do
                                        case "$REPLY" in
                                            y|Y)
                                                sudo mkdirWithOwn $4 $1 www-data 755;
                                                DESTINATION=$4;
                                                break
                                                ;;
                                            n|N)
                                                return 4
                                                break
                                                ;;
                                            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                                               ;;
                                        esac
                                    done
                            ;;
                    	*)
                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode:createDestFolder/querryCreateDestFolder\"${COLOR_RED} в функцию ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_NC}";
                    	    return 5
                    	    ;;
                    esac
                fi
                #Конец проверки существования каталога "$4"

            #Параметры запуска существуют (конец)
            else
            #Параметры запуска отсутствуют
                DESTINATION=$BACKUPFOLDER_DAYS/$1/$2/$date
            #Параметры запуска отсутствуют (конец)
            fi
            #Конец проверки существования параметров запуска скрипта
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует (конец)


	        if ! [ -d $DESTINATION ] ; then
                        #Каталог "$DESTINATION" не существует
                        mkdirWithOwn $DESTINATION $1 www-data 755
                        #Каталог "$DESTINATION" не существует (конец)
            fi

            FILENAME=site.$1==$2__$datetime.tar.gz
            #tar_folder_structure $HOMEPATHWEBUSERS/$1/$2 $DESTINATION/$FILENAME
            tarFolder $HOMEPATHWEBUSERS/$1/$2 $DESTINATION/$FILENAME str silent rewrite $1 www-data 644

            #Проверка существования файла "$DESTINATION/$FILENAME"
            if [ -f $DESTINATION/$FILENAME ] ; then
                #Файл "$DESTINATION/$FILENAME" существует
                return 0
                #Файл "$DESTINATION/$FILENAME" существует (конец)
            else
                #Файл "$DESTINATION/$FILENAME" не существует
                echo -e "${COLOR_RED}Произошла ошибка при создании бэкапа сайта ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2\"${COLOR_RED} в архив ${COLOR_GREEN}\"$DESTINATION/$FILENAME\"${COLOR_NC}"
                return 6

                #Файл "$DESTINATION/$FILENAME" не существует (конец)
            fi
            #Конец проверки существования файла "$DESTINATION/$FILENAME"

	    else
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" не существует
	        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_NC}"
	        return 3
	        #Каталог "$HOMEPATHWEBUSERS/$1/$2" не существует (конец)
	    fi
	    #Конец проверки существования каталога "$HOMEPATHWEBUSERS/$1/$2"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupSiteFiles\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#создание копии конфигов для вебсервера у сайта
###!ПОЛНОСТЬЮ ГОТОВО. 27.03.2019
###input
#$1-user ;
#$2-domain ;
#$3-mode:full_info/error_only
#$4-path-не обязательный - назначение.
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
#3 - ошибка передачи параметра mode:full_info/error_only
#4 - не выполнена операция
backupSiteWebserverConfig() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
        date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`

        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка на существование параметров запуска скрипта
                if [ -n "$4" ]
                then
                #Параметры запуска существуют
                    DESTINATION=$4
                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют
                    DESTINATION=$BACKUPFOLDER_DAYS/$1/$2/$date
                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта

                FILENAME=wserv.$1==$2__$datetime

                #Проверка существования каталога "$DESTINATION/$1_$2"
                if ! [ -d $DESTINATION/$1_$2 ] ; then
                    #Каталог "$DESTINATION" не существует
                    sudo mkdir -p $DESTINATION/$1_$2
                    #Каталог "$DESTINATION" не существует (конец)
                fi
                #Конец проверки существования каталога "$DESTINATION/$1_$2"


                if [ -f "$NGINXENABLED"/"$1_$2.conf" ] ; then
                    sudo cp -R "$NGINXENABLED"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--ngEnabled"
                fi

                if [ -f "$NGINXAVAILABLE"/"$1_$2.conf" ] ; then
                    sudo cp -R "$NGINXAVAILABLE"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--ngAvailable"
                fi

                if [ -f "$APACHEENABLED"/"$1_$2.conf" ] ; then
                    sudo cp -R "$APACHEENABLED"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--apEnabled"
                fi

                if [ -f "$APACHEAVAILABLE"/"$1_$2.conf" ] ; then
                    sudo cp -R "$APACHEAVAILABLE"/"$1_$2.conf" "$DESTINATION"/"$1_$2"/"$1_$2.conf--apAvailable"
                fi

                #Проверка существования системного пользователя "$1"
                	grep "^$1:" /etc/passwd >/dev/null
                	if  [ $? -eq 0 ]
                	then
                	#Пользователь $1 существует
                		chModAndOwnFolderAndFiles "$DESTINATION"/"$1_$2" 644 755 $1 www-data
                	#Пользователь $1 существует (конец)
                	else
                	#Пользователь $1 не существует
                        chModAndOwnFolderAndFiles "$DESTINATION"/"$1_$2" 644 755 $USERLAMER www-data
                	#Пользователь $1 не существует (конец)
                	fi
                #Конец проверки существования системного пользователя $1

                tarFolder $DESTINATION/$1_$2 $DESTINATION/$FILENAME.tar.gz nostr_rem silent rewrite $1 www-data 644

                #Проверка существования файла ""$DESTINATION/$FILENAME.tar.gz""
                if [ -f "$DESTINATION/$FILENAME.tar.gz" ] ; then
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" существует
                    case "$3" in
                        full_info)
                            echo -e "${COLOR_YELLOW}Архивация файлов конфигурации веб-серверов для домена ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} выполнена в архив ${COLOR_GREEN}\"$DESTINATION/$FILENAME.tar.gz\"${COLOR_YELLOW}  ${COLOR_NC}";
                            return 0
                            ;;
                        error_only)
                            return 0
                            ;;
                        *)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_NC}";
                	    ;;
                    esac
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" существует (конец)
                else
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" не существует
                    case "$3" in
                        full_info)
                            echo -e "${COLOR_RED}Архивация файлов конфигурации веб-серверов для домена ${COLOR_YELLOW}\"$2\"${COLOR_RED} не выполнена ${COLOR_NC}";
                            return 4
                            ;;
                        error_only)
                            return 4
                            ;;
                        *)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_NC}";
                	    ;;
                    esac
                    #Файл ""$DESTINATION/$FILENAME.tar.gz"" не существует (конец)
                fi
                #Конец проверки существования файла ""$DESTINATION/$FILENAME.tar.gz""




        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1




	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupSiteWebserverConfig\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Создание бэкапов файлов всех сайтов указанного пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 27.03.2019
###input
#$1-username ;
#$2-mode:createDestFolder/querryCreateDestFolder
#$3-path destination
###return
#0 - выполнено успешно,
#1 - нет параметров,
#2 - нет пользователя
backupUserSitesFiles() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				i=1
                #ls -d $HOMEPATHWEBUSERS/$1/$1_* | cut -d'_' -f 2 | while read line >>/dev/null
                ls $HOMEPATHWEBUSERS/$1 | while read line >>/dev/null
                do
                    #Проверка на существование параметров запуска скрипта
                    if [ -n "$3" ]
                    then
                    #Параметры запуска существуют
                        backupSiteFiles $1 $line createDestFolder $3
                    #Параметры запуска существуют (конец)
                    else
                    #Параметры запуска отсутствуют
                        backupSiteFiles $1 $line createDestFolder
                    #Параметры запуска отсутствуют (конец)
                    fi
                    #Конец проверки существования параметров запуска скрипта
                    (( i++ ))
                done

			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Функция ${COLOR_GREEN}\"backupUserSitesFiles\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"backupUserSitesFiles\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}






#Выгрузка всех баз данных, принадлежащих к определенному домену
###input
#$1-domain ;
#$2-user;
#$3 - full_info/error_only - вывод сообщений о выполнении операции
#$4 - mode - data/structure
#$5 - mode - DeleteBase/NoDeleteBase (удаление после создания бэкапа)
#$6-В параметре $6 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - ошибка передачи параметра mode: full_info/error_only
#3 - ошибка передачи параметра mode: data|structure
#4 - ошибка передачи параметра mode: DeleteBase/NoDeleteBase
dbBackupBasesOneDomainAndUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]&& [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
		date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`

        #Параметры запуска существуют
        case "$4" in
            data|structure)
                case "$5" in
                    DeleteBase|NoDeleteBase)
                        true
                        ;;
                    *)
                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: DeleteBase/NoDeleteBase\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneDomainAndUser\"${COLOR_NC}";
                        return 4
                        ;;
                esac
                ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: data/structure\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneDomainAndUser\"${COLOR_NC}";
                return 3
                ;;
        esac

        case "$3" in
            full_info|error_only)
                true
             ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: full_info/error_only\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneDomainAndUser\"${COLOR_NC}";
                return 2
                ;;
        esac

        #Проверка на существование параметров запуска скрипта
        if [ -n "$6" ]
        then
        #Параметры запуска существуют
            DESTINATION=$6
        #Параметры запуска существуют (конец)
        else
        #Параметры запуска отсутствуют
             DESTINATION=""
        #Параметры запуска отсутствуют (конец)
        fi
        #Конец проверки существования параметров запуска скрипта

        databases=`mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like '$2\_$1%' or SCHEMA_NAME like '$2\_$1'" | tr -d "| " | grep -v SCHEMA_NAME`

                        #выгрузка баз данных
                        for db in $databases; do
                        #echo $db
                           # if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then

								#извлечение имени владельца
                                dbExtractUser=${db%\_*}
                                #echo $dbExtractUser
                                #основная база и дополнительная
                                dbNameWithDopBase=${db#$dbExtractUser\_}
                                #echo $dbNameWithDopBase
                                #извлечение названия дополнительной базы
                                dbNameDopBase=${dbNameWithDopBase#*--*}
                                #echo $dbNameDopBase
                                #извлечения названия основной базы (домена)
                                dbNameMainBase=${dbNameWithDopBase%--$dbNameDopBase}
                                #echo $dbNameMainBase
                           #  fi

                             case "$3" in
                                full_info)
                                    case "$4" in
                                        data)
                                            dbBackupBase $db full_info data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db full_info structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                                error_only)
                                    case "$4" in
                                        data)
                                            dbBackupBase $db error_only data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db error_only structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                            esac

                            case "$5" in
                                DeleteBase)
                                    dbDropBase $db drop
                                    ;;
                                NoDeleteBase)
                                   true
                                    ;;
                            esac
                        done
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBasesOneDomainAndUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Выгрузка всех баз данных, принадлежащих к определенному домену
###input
#$1-domain ;
#$2 - full_info/error_only - вывод сообщений о выполнении операции
#$3 - mode - data/structure
#$4 - mode - DeleteBase/NoDeleteBase (удаление после создания бэкапа)
#$5-В параметре $5 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - ошибка передачи параметра mode: full_info/error_only
#3 - ошибка передачи параметра mode: data|structure
#4 - ошибка передачи параметра mode: DeleteBase/NoDeleteBase
dbBackupBasesOneDomain() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`

        #Параметры запуска существуют
        case "$3" in
            data|structure)
                case "$4" in
                    DeleteBase|NoDeleteBase)
                        true
                        ;;
                    *)
                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: DeleteBase/NoDeleteBase\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                        return 4
                        ;;
                esac
                ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: data/structure\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                return 3
                ;;
        esac

        case "$3" in
            full_info|error_only)
                true
             ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: full_info/error_only\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                return 2
                ;;
        esac

        #Проверка на существование параметров запуска скрипта
        if [ -n "$5" ]
        then
        #Параметры запуска существуют
            DESTINATION=$5
        #Параметры запуска существуют (конец)
        else
        #Параметры запуска отсутствуют
             DESTINATION=""
        #Параметры запуска отсутствуют (конец)
        fi
        #Конец проверки существования параметров запуска скрипта

        databases=`mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like '%\_$1%' or SCHEMA_NAME like '%\_$1'" | tr -d "| " | grep -v SCHEMA_NAME`

                        #выгрузка баз данных
                        for db in $databases; do
                        #echo $db
                           # if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then

								#извлечение имени владельца
                                dbExtractUser=${db%\_*}
                                #echo $dbExtractUser
                                #основная база и дополнительная
                                dbNameWithDopBase=${db#$dbExtractUser\_}
                                #echo $dbNameWithDopBase
                                #извлечение названия дополнительной базы
                                dbNameDopBase=${dbNameWithDopBase#*--*}
                                #echo $dbNameDopBase
                                #извлечения названия основной базы (домена)
                                dbNameMainBase=${dbNameWithDopBase%--$dbNameDopBase}
                                #echo $dbNameMainBase
                           #  fi

                             case "$2" in
                                full_info)
                                    case "$3" in
                                        data)
                                            dbBackupBase $db full_info data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db full_info structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                                error_only)
                                    case "$3" in
                                        data)
                                            dbBackupBase $db error_only data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db error_only structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                            esac

                            case "$4" in
                                DeleteBase)
                                    dbDropBase $db drop
                                    ;;
                                NoDeleteBase)
                                   true
                                    ;;
                            esac
                        done
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#создание бэкапа всех баз данных одного пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 27.03.2019
###input
#$1-user ;
#$2 - full_info/error_only - вывод сообщений о выполнении операции
#$3 - mode - data/structure
#$4 - mode - DeleteBase/NoDeleteBase  - удалить ли базы после создания бэкапов
#$5-В параметре $5 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d` ;
#return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - ошибка передачи параметра mode: full_info/error_only
#3 - ошибка передачи параметра mode: data|structure
#4 - ошибка передачи параметра mode: DeleteBase/NoDeleteBase

dbBackupBasesOneUser() {
    #Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		date=`date +%Y.%m.%d`
        datetime=`date +%Y.%m.%d-%H.%M.%S`

        #Параметры запуска существуют
        case "$3" in
            data|structure)
                case "$4" in
                    DeleteBase|NoDeleteBase)
                        true
                        ;;
                    *)
                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: DeleteBase/NoDeleteBase\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                        return 4
                        ;;
                esac
                ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: data/structure\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                return 3
                ;;
        esac

        case "$2" in
            full_info|error_only)
                true
             ;;
            *)
                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: full_info/error_only\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_NC}";
                return 2
                ;;
        esac

        #Проверка на существование параметров запуска скрипта
        if [ -n "$5" ]
        then
        #Параметры запуска существуют
            DESTINATION=$5
        #Параметры запуска существуют (конец)
        else
        #Параметры запуска отсутствуют
             DESTINATION=""
        #Параметры запуска отсутствуют (конец)
        fi
        #Конец проверки существования параметров запуска скрипта

        databases=`mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like '$1\_%'" | tr -d "| " | grep -v SCHEMA_NAME`

                        #выгрузка баз данных
                        for db in $databases; do
                        echo $db
                           # if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "phpmyadmin" ]] && [[ "$db" != "sys" ]] ; then

								#извлечение имени владельца
                                dbExtractUser=${db%\_*}
                                #echo $dbExtractUser
                                #основная база и дополнительная
                                dbNameWithDopBase=${db#$dbExtractUser\_}
                                #echo $dbNameWithDopBase
                                #извлечение названия дополнительной базы
                                dbNameDopBase=${dbNameWithDopBase#*--*}
                                #echo $dbNameDopBase
                                #извлечения названия основной базы (домена)
                                dbNameMainBase=${dbNameWithDopBase%--$dbNameDopBase}
                                #echo $dbNameMainBase
                           #  fi

                             case "$2" in
                                full_info)
                                    case "$3" in
                                        data)
                                            dbBackupBase $db full_info data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db full_info structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                                error_only)
                                    case "$2" in
                                        data)
                                            dbBackupBase $db error_only data $DESTINATION
                                            ;;
                                        structure)
                                            dbBackupBase $db error_only structure $DESTINATION
                                            ;;
                                    esac
                                    ;;
                            esac

                            case "$4" in
                                DeleteBase)
                                    dbDropBase $db drop
                                    ;;
                                NoDeleteBase)
                                   true
                                    ;;
                            esac
                        done
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupBasesOneUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Создание бэкапа отдельной таблицы
#Полностью проверено.14.03.2019
###input
#$1-dbname ;
#$2-tablename ;
#$3-path-Путь по желанию ;
###return
#0-выполнено успешно
#1-отсутствуют параметры запуска
#2-нет базы данных
#3-нет таблицы
#4-ошибка проверки после экспорта
dbBackupTable() {

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		d=`date +%Y.%m.%d`;
	    dt=`date +%Y.%m.%d-%H.%M.%S`;
	    #проверка существования базы данных "$1"
	    if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$1'" 2>&1`" ]];
	    	then
	    	#база $1 - существует

	    		#Проверка существования таблицы в базе денных $1
	    		if [[ ! -z "`mysql -qfsBe "SHOW TABLES FROM $1 LIKE '$2'" 2>&1`" ]];
	    			then
	    			#таблица $2 существует

	    				    #Проверка на существование параметров запуска скрипта
	    		if [ -n "$3" ]
	    		then
	    		#Параметры запуска существуют
	    		    DESTINATION=$3
	    		#Параметры запуска существуют (конец)
	    		else

	    		                user1=${1%_*}
								user=${user1%_*}

								#обрезаем пользователя слева
								domain1=${1#${user}_}
								#echo domain1 - $domain1
								#обрезаем дополнительную базу справа
								domain=${domain1%_*}

	    		#Параметры запуска отсутствуют
	    		    DESTINATION=$BACKUPFOLDER_DAYS/$dbExtractUser/$domain/$d
			        mkdir -p $DESTINATION
	    		#Параметры запуска отсутствуют (конец)
	    		fi
	    		#Конец проверки существования параметров запуска скрипта

	    		#пусть к файлу с бэкапом без расширения
        		FILENAME=$DESTINATION/mysqlTable-"$2"."$1"-$datetime
                #FILENAME=$DESTINATION/mysql
                    #Проверка существования каталога "$DESTINATION"
                    if [ -d $DESTINATION ] ; then
                        #Каталог "$DESTINATION" существует
            #            mysql -e "mysqldump -c $1 $2 > $FILENAME.sql;"
            		    mysqldump -c $1 $2 > $FILENAME.sql
                        #tar_file_without_structure_remove
                        tarFile $FILENAME.sql $FILENAME.sql.tar.gz str_rem silent rewrite
                        dbCheckExportedBase $1 error_only $FILENAME.sql.tar.gz
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                        	then
                        		#предыдущая команда завершилась успешно
                        		return 0
                        		#предыдущая команда завершилась успешно (конец)
                        	else
                        		#предыдущая команда завершилась с ошибкой
                        		return 4
                        		#предыдущая команда завершилась с ошибкой (конец)
                        fi
                        #Конец проверки на успешность выполнения предыдущей команды
                        #Каталог "$DESTINATION" существует (конец)
                    else
                        #Каталог "$DESTINATION" не существует
                        echo -e "${COLOR_RED} Каталог ${COLOR_YELLOW}\"$DESTINATION\"${COLOR_NC}${COLOR_RED} не найден. Создать его? Функция ${COLOR_GREEN}\"dbBackupTable\"${COLOR_NC}"
                        echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$DESTINATION\"${COLOR_nC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

                        while read
                        do
                        echo -n ": "
                            case "$REPLY" in
                            y|Y)
                                mkdir -p $DESTINATION;
                                mysqldump -c $1 $2 > $FILENAME.sql
                                #tar_file_without_structure_remove $FILENAME.sql $FILENAME.sql.tar.gz
                                tarFile $FILENAME.sql $FILENAME.sql.tar.gz str_rem silent rewrite
                                dbCheckExportedBase $1 error_only $FILENAME.sql.tar.gz
                                    #Проверка на успешность выполнения предыдущей команды
                                    if [ $? -eq 0 ]
                                        then
                                            #предыдущая команда завершилась успешно
                                            return 0
                                            #предыдущая команда завершилась успешно (конец)
                                        else
                                            #предыдущая команда завершилась с ошибкой
                                            return 4
                                            #предыдущая команда завершилась с ошибкой (конец)
                                    fi
                                    #Конец проверки на успешность выполнения предыдущей команды
                                break;;
                            n|N)
                                 break;;
                            esac
                        done
                        #Каталог "$DESTINATION" не существует (конец)
                    fi
                    #Конец проверки существования каталога "$DESTINATION"

	    			#таблица $2 существует (конец)
	    			else
	    			#таблица $2 не существует
	    			    echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbBackupTable\" ${COLOR_NC}"
	    			    return 3
	    			#таблица $2 не существует (конец)
	    		fi
	    		#Проверка существования таблицы в базе денных $1 (конец)





	    	#база $1 - существует (конец)
	    	else
	    	#база $1 - не существует
	    	    echo -e "${COLOR_RED}Ошибка создания бэкапа базы данных ${COLOR_YELLOW}\"$1\"${COLOR_NC}${COLOR_RED}. Указанная база не существует${COLOR_NC}"
	    	    return 2
	    	#база $1 - не существует (конец)
	    fi
	    #конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbBackupTable\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




#Смена пароля пользователю mysql
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###input
#$1-user ;
#$2-host ;
#$3-password ;
#$4-autentification type (mysql_native_password) ;
#$5 - system user (не обязательно. Без этого параметра в файл my.cnf изменение не записывается. Можно использовать для дополнительного пользователя mysql)
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - пользователь не существует
#3 - системный пользователь $5 не существует
dbChangeUserPassword() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$5"
			grep "^$5:" /etc/passwd >/dev/null

				#проверка на существование пользователя mysql "$1"
                if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
                then
                #Пользователь mysql "$1" существует
                    mysql -e "ALTER USER '$1'@'$2' IDENTIFIED WITH '$4' BY '$3';"
                    echo -e "${COLOR_LIGHT_PURPLE}Пароль пользователя $1 изменен ${COLOR_NC}"
                    return 0
            #Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbChangeUserPassword\"${COLOR_NC}"
			return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbChangeUserPassword\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



########################################FILES###############################################

##########################################site##########################################################
#отобразить реквизиты доступа к серверу FTP
#Полностью готово. 13.03.2019 г.
###input
#$1 - user;
#$2 - password,
#$3 - port,
#$4 - сервер
###return
#0 - выполнено успешно,
#1 - не переданы параметры
viewFtpAccess(){
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты FTP-Доступа" ${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" $4 "${COLOR_NC}"
		echo -e "Порт ${COLOR_YELLOW}" $3 "${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Пароль: ${COLOR_YELLOW}" $2 "${COLOR_NC}"
		echo $LINE
		return 0
	else
		echo -e "${COLOR_RED}Не переданы параметры в функцию ${COLOR_GREEN}\"viewFtpAccess\"${COLOR_RED}. Выполнение скрипта аварийно завершено ${COLOR_NC}"
		return 1
	fi
}


#Отобразить реквизиты доступа
###input
#$1-user ;
#$2-mode (full_info);

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - ошибка передачи mode
viewAccessDetail() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		file=$HOMEPATHWEBUSERS/$1/.myconfig/info.txt
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				case "$2" in
				    full_info)
				        echo -e "\n${COLOR_PURPLE}Реквизиты доступа для пользователя ${COLOR_YELLOW}\"$1\"${COLOR_GREEN}:${COLOR_NC}"
				        cat $file | highlight green Password | highlight green Username | highlight green Server | highlight green Host| highlight green Port| highlight yellow SSH-Пользователь| highlight yellow Mysql-User | highlight green "Ключевой файл" | highlight green "Использован открытый ключ"
				        ;;
					*)
					    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"viewAccessDetail\"${COLOR_NC}";
					    return 3
					    ;;
				esac
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"viewAccessDetail\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewAccessDetail\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}

#отобразить реквизиты доступа к серверу SSH
###input
#$1 - user
#$2 - сервер
#$3 - порт
#$4 -  тип подключения (0- по паролю/1 - с использованием ключевого файла) - не обязательно
#$5 -  путь к ключевому файлу (при использовании ключевого файла) - не обязательно
###return
#0 - выполнено успешно,
#1 - отсутствуеют параметры
viewSshAccess(){
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
		echo ""
		echo $LINE
		echo -e "${COLOR_GREEN}"Реквизиты SSH-Доступа" ${COLOR_NC}"
		echo -e "${COLOR_YELLOW}Сервер: ${COLOR_GREEN}" $2 "${COLOR_NC}"
		echo -e "${COLOR_YELLOW}Порт ${COLOR_GREEN}" $3 "${COLOR_NC}"
		echo -e "${COLOR_YELLOW}Пользователь: ${COLOR_GREEN}" $1 "${COLOR_NC}"
		#Проверка на существование параметров запуска скрипта
		if [ -n "$4" ]
		then
		#Параметры запуска существуют
		    case "$4" in
		        0)
		            echo -e "${COLOR_YELLOW}Тип подключения к серверу по SSH: ${COLOR_GREEN}" с использованием пароля "${COLOR_NC}"
		            ;;
		        1)
		            echo -e "${COLOR_YELLOW}Тип подключения к серверу по SSH: ${COLOR_GREEN}" с использованием ключевого файла "${COLOR_NC}"
		            ;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"viewSshAccess\"${COLOR_NC}";
		    	    ;;
		    esac
		#Параметры запуска существуют (конец)
		fi
		if [ -n "$5" ]
		then
		#Параметры запуска существуют

		    echo -e "${COLOR_YELLOW}Путь к ключевому файлу: ${COLOR_GREEN}" $5 "${COLOR_NC}"
		#Параметры запуска существуют (конец)
		fi
		#Конец проверки существования параметров запуска скрипта
		echo $LINE
		return 0
	else
		echo -e "${COLOR_LIGHT_RED}Не передан параметр в функцию ${COLOR_GREEN}\"viewSshAccess\"${COLOR_NC}"
		return 1
	fi
}



#Добавление php-сайта
###input
#$1-username-кому добавляется сайт ;
#$2-domain ;
#$3-site_path ;
#$4-apache_config ;
#$5-nginx_config ;
#$6-username - кем добавляется сайт;
###return
#0 - выполнено успешно
#1 - отсутствуют параметры
#2 - пользователь $1 не  существует
#3 - конфигурация apache не существует
#4 - конфигурация nginx не существует
#5 - каталог сайта уже существует
siteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ]
	then
	#Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка существования файла "$TEMPLATES/apache2/$4"
        		if [ -f $TEMPLATES/apache2/$4 ] ; then
        		    #Файл "$TEMPLATES/apache2/$4" существует
        		    #Проверка существования файла "$TEMPLATES/nginx/$5"
        		    if [ -f $TEMPLATES/nginx/$5 ] ; then
        		        #Файл "$TEMPLATES/nginx/$5" существует
                        #Проверка существования каталога "$3"
                        if [ -d $3 ] ; then
                            #Каталог сайта "$3" уже существует
                            echo -e "${COLOR_RED}Каталог сайта ${COLOR_GREEN}\"$3\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
                            return 5
                            #Каталог сайта "$3" уже существует (конец)
                        else
                            #Каталог сайта "$3" не существует

                            #добавление ftp-пользователя
                            siteAddFtpUser $1 $2 autogenerate $6
                            sudo cp -R /etc/skel/* $3

                            siteAddTestIndexFile $1 $2 public_html replace phpinfo

                           #nginx
                           sudo cp -rf $TEMPLATES/nginx/$5 /etc/nginx/sites-available/"$1"_"$2".conf
                           chModAndOwnFile /etc/nginx/sites-available/"$1"_"$2".conf $1 www-data 644

                           siteChangeWebserverConfigs nginx $1 $2 $HTTPNGINXPORT

                           siteStatus $1 $2 nginx enable

                            #apache2
                           sudo cp -rf $TEMPLATES/apache2/$4 /etc/apache2/sites-available/"$1"_"$2".conf
                           chModAndOwnFile /etc/apache2/sites-available/"$1"_"$2".conf $1 www-data 644
                            siteChangeWebserverConfigs apache $1 $2 $APACHEHTTPPORT

                            siteStatus $1 $2 apache enable

                            chModAndOwnSiteFileAndFolder $3 $WWWFOLDER $1 644 755

                            dbCreateBase $1_$2 utf8 utf8_general_ci error_only
                            mysqlpassword="$(openssl rand -base64 14)";
                            dbUseradd $1_$2 $mysqlpassword % pass user





                            cd $3/$WWWFOLDER
                            #echo -e "\033[32m" Инициализация Git "\033[0;39m"
                            git init
                            git config user.email "$1@$2"
                            git config user.name "$1"
                            git add .
                            git commit -m "initial commit"

                            echo -e "==========================================="
                            echo -e "Сайт доступен по адресу: ${COLOR_YELLOW} Параметры подключения к сайту ${COLOR_NC} (nginx)"
                            echo -e "Сайт доступен по адресу: ${COLOR_YELLOW} http://"$2" ${COLOR_NC} (nginx)"
                            echo -e "Сайт доступен по адресу: ${COLOR_YELLOW} http://"$2":8080 ${COLOR_NC} (apache)"
                            echo -e "Сервер FTP: ${COLOR_YELLOW} "$2":10081 ${COLOR_NC}"
                            echo -e "FTP User: ${COLOR_YELLOW} $1_$2 ${COLOR_NC}"
                            echo -e "PhpMyAdmin: ${COLOR_YELLOW} https://conf.mmgx.ru/dbase ${COLOR_NC}"
                            echo -e "Adminer: ${COLOR_YELLOW} https://conf.mmgx.ru/a ${COLOR_NC}"
                            echo -e "MYSQL User: ${COLOR_YELLOW} $1_$2 ${COLOR_NC}"
                            echo -e "MYSQL DB: ${COLOR_YELLOW} $1_$2 ${COLOR_NC}"

                            #Каталог сайта "$3" не существует (конец)
                        fi
                        #Конец проверки существования каталога "$3"

        		        #Файл "$TEMPLATES/nginx/$5" существует (конец)
        		    else
        		        #Файл "$TEMPLATES/nginx/$5" не существует
        		        echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		        return 4
        		        #Файл "$TEMPLATES/nginx/$5" не существует (конец)
        		    fi
        		    #Конец проверки существования файла "$TEMPLATES/nginx/$5"

        		    #Файл "$TEMPLATES/apache2/$4" существует (конец)
        		else
        		    #Файл "$TEMPLATES/apache2/$4" не существует
        		    echo -e "${COLOR_RED}Конфигурация apache2 ${COLOR_GREEN}\"$TEMPLATES/apache2/$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		    return 3
        		    #Файл "$TEMPLATES/apache2/$4" не существует (конец)
        		fi
        		#Конец проверки существования файла "$TEMPLATES/apache2/$4"

        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#включение-выключение сайта
###!ПОЛНОСТЬЮ ГОТОВО. 28.03.2019
###input
#$1-user;
#$2-domain;
#$3-mode: apache/nginx ;
#$4-mode: enable/disable ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - ошибка передачи параметра mode: enable/disable
#3 - ошибка передачи параметра mode: apache/nginx
#4 - файл /etc/nginx/sites-available/$1_$2.conf не существует
#5 - файл $NGINXENABLED"/"$1_$2.conf уже не существует
siteStatus() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		case "$4" in
		    enable)
                case "$3" in
                    apache)
                        sudo a2ensite $1_$2.conf
                        ;;
                    nginx)
                        #Проверка существования файла ""$NGINXAVAILABLE"/"$1_$2.conf""
                        if [ -f "$NGINXAVAILABLE"/"$1_$2.conf" ] ; then
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" существует
                            sudo ln -s "$NGINXAVAILABLE"/"$1_$2.conf" $NGINXENABLED
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" существует (конец)
                        else
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" не существует
                            echo -e "${COLOR_RED}Конфигурация сайта ${COLOR_GREEN}\""$NGINXAVAILABLE"/"$1_$2.conf"\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}"
                            return 4
                            #Файл ""$NGINXAVAILABLE"/"$1_$2.conf"" не существует (конец)
                        fi
                        #Конец проверки существования файла ""$NGINXAVAILABLE"/"$1_$2.conf""
                        ;;
                	*)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: apache/nginx\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}";
                	    return 3
                	    ;;
                esac
		        ;;
		    disable)
                case "$3" in
                    apache)
                        sudo a2dissite $1_$2.conf
                        ;;
                    nginx)
                        #Проверка существования файла ""$NGINXENABLED"/"$1_$2.conf""
                        if [ -f "$NGINXENABLED"/"$1_$2.conf" ] ; then
                            #Файл ""$NGINXENABLED"/"$1_$2.conf"" существует
                            sudo rm "$NGINXENABLED"/"$1_$2.conf"
                            #Файл ""$NGINXENABLED"/"$1_$2.conf"" существует (конец)
                        else
                            return 5
                        fi
                        #Конец проверки существования файла ""$NGINXENABLED"/"$1_$2.conf""

                        ;;
                	*)
                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: apache/nginx\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}";
                	    return 3
                	    ;;
                esac
		        ;;
			*)
			    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: enable/disable\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteStatus\"${COLOR_NC}";
			    return 2
			    ;;
		esac
		webserverReload
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteStatus\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Добавление ftp-пользователя
###input
#$1-user ;
#$2-domain ;
#$3-mode: password type - autogenerate/querry/manual;
#$4-created by

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь ftp-уже существует
#3 - Ошибка передачи параметра mode - manual|querry|autogenerate
#4 - пользователь created by не существует
siteAddFtpUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1_$2"
			grep "^$1_$2:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1_$2\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAddFtpUser\"${COLOR_NC}"
				return 2
			#Пользователь $1_$2 существует (конец)
			else
			#Пользователь $1_$2 не существует
			    #Проверка существования системного пользователя "$4"
			    	grep "^$4:" /etc/passwd >/dev/null
			    	if  [ $? -eq 0 ]
			    	then
			    	#Пользователь $4 существует
                        case "$3" in
                            "manual"|"querry"|"autogenerate")
                                #Проверка существования каталога ""$HOMEPATHWEBUSERS"/"$1"/"$2""
                                if ! [ -d "$HOMEPATHWEBUSERS"/"$1"/"$2" ] ; then
                                    #Каталог ""$HOMEPATHWEBUSERS"/"$1"/"$2"" не существует
                                    sudo mkdir -p "$HOMEPATHWEBUSERS"/"$1"/"$2"
                                    #Каталог ""$HOMEPATHWEBUSERS"/"$1"/"$2"" не существует (конец)
                                fi
                                #Конец проверки существования каталога ""$HOMEPATHWEBUSERS"/"$1"/"$2""

                                sudo useradd -c "Ftp-user for user $1. domain $2" $1_$2 -N -d "$HOMEPATHWEBUSERS"/"$1"/"$2" -m -s /bin/false -g ftp-access -G www-data
                                sudo adduser $1_$2 www-data
                                dbRecordAdd_addUser $1_$2 "$OMEPATHWEBUSERS"/"$1"/"$2" $4 2
                                infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt
                                fileAddLineToFile $infoFile "FTP-Пользователь:"

                                #смена пароля на пользователя
                                userChangePassword $1_$2 $3
                                fileAddLineToFile $infoFile "Server: $MYSERVER ($2)"
                                fileAddLineToFile $infoFile "Port: $FTPPORT"
                                fileAddLineToFile $infoFile "------------------------"
                                return 0
                                ;;
                            *)
                                echo -e "${LOR_RED}Ошибка передачи параметра ${LOR_GREEN}\"mode - manual|querry|autogenerate\"${LOR_RED} в функцию ${OLOR_GREEN}\"siteAddFtpUser\"${OLOR_NC}";
                                return 3
                                ;;
                        esac
                            #Пользователь $4 существует (конец)
                            else
                            #Пользователь $4 не существует
                                echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAddFtpUser\"${COLOR_NC}"
                                return  4
                            #Пользователь $4 не существует (конец)
                            fi
                        #Конец проверки существования системного пользователя $4

			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAddFtpUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Запрос информации для создания пользователя ftp
###input
#$1-user ;
#$2-domain ;
#$3-mode password: manual/querry/autogenerate ;

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - Пользователь уже существует
#3 - Каталог сайта $HOMEPATHWEBUSERS/$1/$2 не существует
#4 - Ошибка передачи параметра mode password: manual/querry/autogenerate
#5 - пароль пустой
input_siteAddFtpUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteAddFtpUser\"${COLOR_NC}"
				return 2
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
                #Проверка существования каталога "$HOMEPATHWEBUSERS/$1/$2"
                if [ -d $HOMEPATHWEBUSERS/$1/$2 ] ; then
                    #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует
                    case "$3" in
                        manual)

                            ;;
                        querry)

                            ;;
                    	autogenerate)

                    		;;
                    	*)
                    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode password: manual/querry/autogenerate\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
                    	    return 4
                    	    ;;
                    esac
                    #Каталог "$HOMEPATHWEBUSERS/$1/$2" существует (конец)
                else
                    #Каталог "$HOMEPATHWEBUSERS/$1/$2" не существует
                    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteAddFtpUser\"${COLOR_NC}"
                    return 3
                    #Каталог "$HOMEPATHWEBUSERS/$1/$2" не существует (конец)
                fi
                #Конец проверки существования каталога "$HOMEPATHWEBUSERS/$1/$2"

			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_siteAddFtpUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



##########################################ssh-server######################################################
#Генерация ssh-ключа для пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###input
#$1-user ;
#$2 - домашний каталог пользователя
###return
#0 - выполнено без ошибок,
#1 - отсутствуют параметры запуска
#2 - нет указанного пользователя
sshKeyGenerateToUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

	#Проверка существования системного пользователя "$1"
		grep "^$1:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $1 существует

                        DATE=`date '+%Y-%m-%d__%H-%M-%S'`
                        #DATE_TYPE2=$`date +%Y-%m-%d\ %H:%M:%S`
						DATE_TYPE2=`date +%Y.%m.%d-%H.%M.%S`
                    #Проверка существования каталога "$2/.ssh"
                        if [ -d $2/.ssh ] ; then
                            #Каталог "$2/.ssh" существует
                           # tar_folder_structure
                            tarFolder $2/.ssh/ $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_backuped_$DATE.tar.gz str error_only rewrite $1 users 644
                            #Каталог "$2/.ssh" существует (конец)
                        fi
                    #Конец проверки существования каталога "$2/.ssh"
                        #mkdir -p $2/.ssh
                        mkdirWithOwn $2/.ssh $1 users 766
                        cd $2/.ssh
                        echo -e "\n${COLOR_YELLOW} Генерация ключа. Сейчас необходимо будет установить пароль на ключевой файл.Минимум - 5 символов${COLOR_NC}"
                        ssh-keygen -t rsa -f ssh_$1 -C "ssh_$1 ($DATE_TYPE2)"
                        #echo -e "\n${COLOR_YELLOW} Конвертация ключа в формат программы Putty. Необходимо ввести пароль на ключевой файл, установленный на предыдушем шаге ${COLOR_NC}"
                        puttygen $2/.ssh/ssh_$1 -C "ssh_$1 ($DATE_TYPE2)" -o $2/.ssh/ssh_$1.ppk
                        mkdirWithOwn $BACKUPFOLDER_IMPORTANT/ssh/$1 $1 users 766
                        cat $2/.ssh/ssh_$1.pub >> $2/.ssh/authorized_keys
                        tarFolder $2/.ssh/ $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_generated_$DATE.tar.gz str error_only rewrite $1 users 644
                        chModAndOwnFile $BACKUPFOLDER_IMPORTANT/ssh/$1/ssh_generated_$DATE.tar.gz $1 users 644
                        chown $1:users $2/.ssh/*
                        #chModAndOwnFolderAndFiles $2/.ssh 700 600 $1 users
                        usermod -G ssh-access -a $1
                        dbUpdateRecordToDb $WEBSERVER_DB users username $1 isSshAccess 1 update
                        return 0

		#Пользователь $1 существует (конец)
		else
		#Пользователь $1 не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyGenerateToUser\"${COLOR_NC}"
			return 2
		#Пользователь $1 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshKeyGenerateToUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Импорт ssh-ключа
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
sshKeyImport() {
    #TODO сделать проверки на наличие файла, цикл и т.п., бэкап файла

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
			    infoFile="$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt

                echo -e "\n${COLOR_YELLOW} Список возможных ключей для импорта: ${COLOR_NC}"
			    ls -l $SETTINGS/ssh/keys/
			    echo -n -e "${COLOR_BLUE} Укажите название открытого ключа, который необходимо применить к текущему пользователю: ${COLOR_NC}"
			    read -p ":" key
				mkdir -p $HOMEPATHWEBUSERS/$1/.ssh
				cat $SETTINGS/ssh/keys/$key >> $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys
				echo "" >> $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys
				DATE=`date '+%Y-%m-%d__%H-%M'`
				mkdir -p $BACKUPFOLDER_IMPORTANT/ssh/$1
				chmod 700 $HOMEPATHWEBUSERS/$1/.ssh
				chmod 600 $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys
				chown $1:users $HOMEPATHWEBUSERS/$1/.ssh
				chown $1:users $HOMEPATHWEBUSERS/$1/.ssh/authorized_keys
				usermod -G ssh-access -a $1
				dbUpdateRecordToDb $WEBSERVER_DB users username $1 isSshAccess 1 update
				echo -e "\n${COLOR_YELLOW} Импорт ключа $COLOR_LIGHT_PURPLE\"$key\"${COLOR_YELLOW} пользователю $COLOR_LIGHT_PURPLE\"$1\"${COLOR_YELLOW} выполнен${COLOR_NC}"
				fileAddLineToFile $infoFile "Использован открытый ключ - $SETTINGS/ssh/keys/$key"
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyImport\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshKeyImport\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Добавление существующего ключа $2 пользователю $1
#ПРОТЕСТИРОВАНО
#Полностью готово. 14.03.2019
#$1-user ;
#2 - group;
#$3 - путь к ключу ;
#$4 - домашний каталог пользователя
#return
#0 - выполнено успешно
#1 - отсутствуют параметры,
#2 - пользователь не существует,
#3 - группа не существует
#4 - ключ не найден,
#5 - каталог не найден,
#6 - не выполнена финальная провека существования файла $4/.ssh/authorized_keys
sshKeyAddToUser()
{
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
    then
    #Параметры запуска существуют
        #Проверка существования системного пользователя "$1"
        	grep "^$1:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $1 существует
        		#Проверка существования системной группы пользователей "$2"
        		if grep -q $2 /etc/group
        		    then
        		        #Группа "$2" существует
                        #Проверка существования файла "$3"
                        if [ -f $3 ] ; then
                            #Файл "$3" существует
                            #Проверка существования каталога "$4"
                            if [ -d $4 ] ; then
                                #Каталог "$4" существует
                                 mkdirWithOwn $4/.ssh $1 $2 755
                                 DATE=`date '+%Y-%m-%d__%H-%M-%S'`
                                 mkdirWithOwn $BACKUPFOLDER_IMPORTANT/ssh/$1 $1 $2 755
                                 cat $3 >> $4/.ssh/authorized_keys
                                 echo "" >> $4/.ssh/authorized_keys
                                 #tar_file_structure $4/.ssh/authorized_keys $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz
                                 tarFile $4/.ssh/authorized_keys $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz str silent rewrite $1 $2 644
                                 chModAndOwnFile $BACKUPFOLDER_IMPORTANT/ssh/$1/authorized_keys_$DATE.tar.gz $1 $2 644
                                 chModAndOwnFile $4/.ssh/authorized_keys $1 $2 600
                                 chown $1:$2 $4/.ssh
                                 usermod -G ssh-access -a $1

                                 #финальная проверка импорта ключа
                                 #Проверка существования файла "$4/.ssh/authorized_keys"
                                 if [ -f $4/.ssh/authorized_keys ] ; then
                                     #Файл "$4/.ssh/authorized_keys" существует
                                     echo -e "\n${COLOR_YELLOW} Импорт ключа ${COLOR_LIGHT_PURPLE}\"$3\"${COLOR_YELLOW} пользователю ${COLOR_LIGHT_PURPLE}\"$1\"${COLOR_YELLOW} выполнен${COLOR_NC}"
                                     return 0
                                     #Файл "$4/.ssh/authorized_keys" существует (конец)
                                 else
                                     #Файл "$4/.ssh/authorized_keys" не существует
                                     echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$4/.ssh/authorized_keys\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                                     return 6
                                     #Файл "$4/.ssh/authorized_keys" не существует (конец)
                                 fi
                                 #Конец проверки существования файла "$4/.ssh/authorized_keys"

                                 #финальная проверка импорта ключа (конец)
                                #Каталог "$4" существует (конец)
                            else
                                #Каталог "$4" не существует
                                echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                                return 5
                                #Каталог "$4" не существует (конец)
                            fi
                            #Конец проверки существования каталога "$4"

                            #Файл "$3" существует (конец)
                        else
                            #Файл "$3" не существует
                            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
                            return 4
                            #Файл "$3" не существует (конец)
                        fi
                        #Конец проверки существования файла "$3"

        		        #Группа "$2" существует (конец)
        		    else
        		        #Группа "$2" не существует
        		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
        				return 3
        				#Группа "$2" не существует (конец)
        		    fi
        		#Конец проверки существования системной группы пользователей $2


        	#Пользователь $1 существует (конец)
        	else
        	#Пользователь $1 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_NC}"
        		return 2
        	#Пользователь $1 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $1
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"sshKeyAddToUser\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта
}




#удаление сайта
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует пользователь $1
input_siteRemove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				echo "--------------------------------------"
                echo "Удаление виртуального хоста:"
                echo "Список имеющихся доменов для пользователя $1:"
                ls $HOMEPATHWEBUSERS/$1
                echo ''
                echo -n "Введите домен для удаления: "
                read domain
                path=$HOMEPATHWEBUSERS/$1/$domain
                echo ''

                bash -c "source $SCRIPTS/include/inc.sh; siteRemove $domain $1 createbackup";
			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteRemove\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_siteRemove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Удаление логов с сайта
###input
#$1-user ;
#$2-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
siteRemoveLogs() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют

		path=$HOMEPATHWEBUSERS/$1/$2
        if [ -f $path/logs/error_apache.log ] ;  then
           sudo rm $path/logs/error_apache.log
        fi

        if [ -f $path/logs/access_apache.log ] ;  then
           sudo rm $path/logs/access_apache.log
        fi

        if [ -f $path/logs/access_nginx.log ] ;  then
           rm $path/logs/access_nginx.log
        fi

        if [ -f $path/logs/error_nginx.log ] ;  then
           sudo rm $path/logs/error_nginx.log
fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemoveLogs\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}




#Удаление конфигов веб-серверов
###input
#$1-user ;
#$2-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
siteRemoveWebserverConfig() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		if [ -f "$NGINXENABLED"/"$1_$2.conf" ] ; then
            sudo rm "$NGINXENABLED"/"$1_$2.conf"
        fi

        if [ -f "$NGINXAVAILABLE"/"$1_$2.conf" ] ; then
           sudo rm "$NGINXAVAILABLE"/"$1_$2.conf"
        fi

        if [ -f "$APACHEENABLED"/"$1_$2.conf" ] ; then
           sudo rm "$APACHEENABLED"/"$1_$2.conf"
        fi

        if [ -f "$APACHEAVAILABLE"/"$1_$2.conf" ] ; then
           sudo rm "$APACHEAVAILABLE"/"$1_$2.conf"
        fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemoveWebserverConfig\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Удаление сайта
###input
#$1-domain ;
#$2-user ;
#$3-mode:createbackup/nocreatebackup ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не найден каталог сайта $2
#3 - ошибка передачи параметра mode:createbackup/nocreatebackup
#4 пользователь $2 не существует
siteRemove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then

	date=`date +%Y.%m.%d`
    datetime=`date +%Y.%m.%d-%H.%M.%S`

	#Проверка существования системного пользователя "$2"
		grep "^$2:" /etc/passwd >/dev/null
		if  [ $? -eq 0 ]
		then
		#Пользователь $2 существует
			true
		#Пользователь $2 существует (конец)
		else
		#Пользователь $2 не существует
		    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteRemove\"${COLOR_NC}"
			return 4
		#Пользователь $2 не существует (конец)
		fi
	#Конец проверки существования системного пользователя $2

	path="$HOMEPATHWEBUSERS"/"$2"/"$1"
	pathBackup=$BACKUPFOLDER/vds/removed/$2/$1/$date
	#Параметры запуска существуют
        #Проверка существования каталога "$path"
            case "$3" in
                createbackup)
                    backupSiteWebserverConfig $2 $1 error_only $pathBackup;
                    dbBackupBasesOneDomainAndUser $1 $2 error_only data DeleteBase $pathBackup;
                    ##TODO сделать проверку успешности выполнения бэкапа

                    #Проверка существования каталога "$path"
                    if [ -d $path ] ; then
                        #Каталог "$path" существует
                        backupSiteFiles $2 $1 createDestFolder $pathBackup
                        #Каталог "$path" существует (конец)
                    fi
                    #Конец проверки существования каталога "$path"
                    ;;
                nocreatebackup)
                    true
                    ;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: createbackup/nocreatebackup\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteRemove\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac

                    siteStatus $2 $1 apache disable;
                    siteStatus $2 $1 nginx disable;
                    siteRemoveWebserverConfig $2 $1;
                    siteRemoveLogs $2 $1;

                    #Проверка существования каталога "$path"
                    if [ -d $path ] ; then
                        #Каталог "$path" существует
                        sudo rm -Rf $path
                        #Каталог "$path" существует (конец)
                    fi
                    #Конец проверки существования каталога "$path"

                    #Проверка существования системного пользователя "$2_$1"
                    	grep "^$2_$1:" /etc/passwd >/dev/null
                    	if  [ $? -eq 0 ]
                    	then
                    	#Пользователь $2_$1 существует
                    		userDelete_system $2_$1
                    	#Пользователь $2_$1 существует (конец)
                    	fi
                    #Конец проверки существования системного пользователя $2_$1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteRemove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



##########################################webserver#######################################################
#Перезапуск Веб-сервера
#Полностью готово. 13.03.2019
webserverRestart() {
    /etc/init.d/apache2 restart
    /etc/init.d/nginx restart
}


#обновление конфигураций веб-серверов
webserverReload() {
    sudo systemctl reload nginx
    sudo systemctl reload apache2
}

#вывод информации о версии PHP
viewPHPVersion(){
	echo ""
	echo "Версия PHP:"
	php -v
	echo ""
}

#Вывод перечня сайтов указанного пользователя (конфиги веб-сервера)
###input
#$1 - имя пользователя
###return
#0 - выполнено успешно,
#1 - не передан параметр,
#2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
viewSiteConfigsByName(){
	if [ -n "$1" ]
	then
		if [ -d $HOMEPATHWEBUSERS/$1 ] ;  then
            echo -e "\nСписок сайтов в каталоге пользователя ${COLOR_YELLOW}\"$1\"${COLOR_NC}" $HOMEPATHWEBUSERS/$1:
			ls $HOMEPATHWEBUSERS/$1 | echo ""
		else
		    echo -e "${COLOR_RED}Каталог  ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1\"${COLOR_RED} не найден.Ошибка выполнения функции ${COLOR_GREEN}\"viewSiteConfigsByName\"${COLOR_RED}  ${COLOR_NC}"
		    return 2
        fi

		echo -n "Apache - sites-available (user:$1): "
		ls $APACHEAVAILABLE | grep -E "$1.*$1" | echo ""
		echo  -n "Apache - sites-enabled (user:$1): "
		ls $APACHEENABLED | grep -E "$1.*$1" | echo ""
		echo  -n "Nginx - sites-available (user:$1): "
		ls $NGINXAVAILABLE | grep -E "$1.*$1" | echo ""
		echo  -n "Nginx - sites-enabled (user:$1): "
		ls $NGINXENABLED | grep -E "$1.*$1" | echo ""
		echo $LINE
		return 0
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewSiteConfigsByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

#Вывод перечня сайтов указанного пользователя
###input
# $1 - имя пользователя
###return
#0  - выполнено успешно,
#1 - не передан параметр,
#2 - отсутствует каталог $HOMEPATHWEBUSERS/$1
viewSiteFoldersByName(){
	if [ -n "$1" ]
	then
		if [ -d $HOMEPATHWEBUSERS/$1 ] ;  then
            echo -e "\nСписок сайтов в каталоге пользователя ${COLOR_YELLOW}\"$1\"${COLOR_NC}" $HOMEPATHWEBUSERS/$1:
			ls $HOMEPATHWEBUSERS/$1/
			retun 0
		else
			echo -e "${COLOR_RED}Каталог $HOMEPATHWEBUSERS/$1/ не существует. Ошибка выполнения функции viewSiteFoldersByName ${COLOR_NC}"
			return 2
        fi
	else
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewSiteFoldersByName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

############################ufw########################################
#Добавление порта с исключением в firewall ufw
###input
#$1-port ;
#$2-protocol ;
#$3-комментарий ;
###return
#0 - выполнено успешно,
#1 - не переданы параметры,
#2 - ошибка добавления правила
ufwAddPort() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
		ufw allow $1/$2 comment $3 && return 0 || return 2
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"ufwAddPort\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод открытых портов ufw
ufwOpenPorts() {
    netstat -ntulp
}


############################################menu#############################################
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
                    "7") source /my/scripts/include/inc.sh && testFunction $USERNAME;  break;;
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
menuSite() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        echo ''
        echo -e "${COLOR_GREEN} ===Управление сайтами===${COLOR_NC}"

        echo '1: Добавить сайт на сервер'
        echo '2: Удаление сайта с сервера'
        echo '3: Список виртуальных хостов на сервере'
        echo '4: Сертификаты'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1")  menuSiteAdd $1; break;;
                "2")  input_siteRemove $1;  break;;
                "3")  $SCRIPTS/info/site_info/show_sites.sh $1; break;;
                "4")  $MENU/submenu/site_cert.sh $1; break;;
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
        echo '2: PHP/HTML (упрощенная настройка)'
        echo '3: Framework Laravel'
        echo '4: Framework Laravel (с вводом доп.параметров)'

        echo '0: Назад'
        echo 'q: Выход'
        echo ''
        echo -n 'Выберите пункт меню:'

        while read
            do
                case "$REPLY" in
                "1") input_SiteAdd_php $1 querry; break;;
                "2") input_SiteAdd_php $1 lite; break;;
                "3")   $1; break;;
                "4")   $1; break;;

                "0")  $MYFOLDER/scripts/menu $1;  break;;
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

        echo '1: certbot certificates'
        echo '2: letsencrypt'

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
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"menuSite_cert\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

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


                "0")  $MYFOLDER/scripts/menu $1;  break;;
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
                        "1")  menuGit_commit $1; break;;
                        "2")  menuGit_remotePush $1; break;;
                        "3")  menuGit_remoteView $1; break;;
                        "0")  menuMain $1;  break;;
                        "q"|"Q")  exit 0;;
                         *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
                        esac
                    done
                    return 0
}

#Создание коммита
menuGit_commit() {
    echo -n -e "Для создания коммита репозитария ${COLOR_YELLOW}\""$SCRIPTS"\"${COLOR_NC} введите ${COLOR_BLUE}\"y\"${COLOR_NC}, для выхода - ${COLOR_BLUE}\"n\"${COLOR_NC}: "
    while read
        do
            case "$REPLY" in
            "y"|"Y")
                echo -n -e "Для задания имени коммита введите ${COLOR_BLUE}\"y\"${COLOR_NC}, задания вместо имени даты-времени - введите ${COLOR_BLUE}\"любой символ\"${COLOR_NC}: "
                    while read
                        do
                            case "$REPLY" in
                            "y"|"Y")
                                echo -n -e "${COLOR_BLUE}Введите комментарий коммита${COLOR_NC}"
                                read -p ": " comment
                                dt=$(date '+%d/%m/%Y %H:%M:%S')
                                sudo git add .
                                sudo git commit -m "$dt - $comment"
                                break
                                ;;
                            *)
                                dt=$(date '+%d/%m/%Y %H:%M:%S')
                                sudo git add .
                                sudo git commit -m "$dt"
                                break;;
                            esac
                        done
                break
                ;;
            "n"|"N")
                echo 'Отмена создания коммита'
                    menuGit $1
                break;;

            *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
            esac
        done
        menuGit $1
}

#публикация проекта во внешнем репозитарии
menuGit_remotePush() {
    cd $SCRIPTS
    echo -e "\n${COLOR_YELLOW}Публикация репозитария на github.com и Bitbucket.org:${COLOR_NC}"
    sudo git remote add github https://trashsh@github.com/trashsh/scripts.git
    sudo git remote add bitbucket https://gothundead@bitbucket.org/gothundead/scripts.git
    sudo git push github master
    sudo git push bitbucket master
    echo ""
    menuGit $1
}

# просмотр удаленных репозитариев
menuGit_remoteView() {
        echo $1
		cd $SCRIPTS
		echo -e "\n${COLOR_YELLOW}Список удаленных репозиториев:${COLOR_NC}"
		git remote -v
		menuGit $1
}


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
        echo -e "${COLOR_GREEN} ===Управление сервром===${COLOR_NC}"

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
                "1")   $1; break;;

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




###############################################input####################################################
#Запрос имени пользователя для вывода списка групп, в которых он состоит
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
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



#Запрос подтверждения удаления всех баз данных конкретного пользователя
###input
#$1-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - баз данных пользователя не существует
input_dbUserDeleteBase() {
	dbViewAllUsers
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

                                dbBackupBasesOneUser $username full_info data DeleteBase;
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



#запрос данных для смены пароля пользователя mysql
###input
#$1-имя системного пользователя;

###return
#0 - выполнено успешно
#1 - пользователь mysql не существует
#2 - пароль пустой. отмена выполнения
#3 - произошла ошибка при смене пароля
input_dbChangeUserPassword() {
    dbViewAllUsers
    echo -e "${COLOR_GREEN}Смена пароля на пользователя mysql: ${COLOR_NC}"
	echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql: ${COLOR_NC}"
	read username
	#Проверка на существование пользователя mysql "$username"
	if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
	then
	#Пользователь mysql "$username" существует
        echo -n -e "${COLOR_BLUE}Введите новый пароль для пользователя ${COLOR_YELLOW}\"$username\"${COLOR_BLUE}: ${COLOR_NC}"
	    read password
	    if [[ -z "$password" ]]; then
             #переменная имеет пустое значение
              echo -e "${COLOR_RED}"Пароль не может быть пустым. Отмена смены пароля пользователя ${COLOR_GREEN}\"$username\""${COLOR_NC}"
              return 2
        else
            echo -n -e "${COLOR_BLUE}Введите хост  ${COLOR_YELLOW}\"(localhost/%)\"${COLOR_BLUE}: ${COLOR_NC}"
	        read host

           dbChangeUserPassword $username $host $password mysql_native_password $1
           #Проверка на успешность выполнения предыдущей команды
           if [ $? -eq 0 ]
           	then
           		#предыдущая команда завершилась успешно
           		#Проверка существования системного пользователя "$username"
           			grep "^$username:" /etc/passwd >/dev/null
           			if  [ $? -eq 0 ]
           			then
           			#Пользователь $username существует
           				dbSetMyCnfFile $username $username $password
           			#Пользователь $username существует (конец)
           			fi
           		#Конец проверки существования системного пользователя $username
           		#предыдущая команда завершилась успешно (конец)
           	else
           		#предыдущая команда завершилась с ошибкой
           		echo -e "${COLOR_RED}Произошла ошибка при смене пароля для mysql-пользователя ${COLOR_GREEN}\"$username\"${COLOR_RED}  ${COLOR_GREEN}\"\"${COLOR_RED}  ${COLOR_NC}"
           		return 3
           		#предыдущая команда завершилась с ошибкой (конец)
           fi
           #Конец проверки на успешность выполнения предыдущей команды

        fi
	#Пользователь mysql "$username" существует (конец)
	else
	#Пользователь mysql "$username" не существует
	    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbChangeUserPassword\" ${COLOR_NC}"
	    return 1
	#Пользователь mysql "$username" не существует (конец)
	fi
	#Конец проверки на существование пользователя mysql "$username"
}

#Запрос имени пользователя mysql на удаление
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
###input
#$1 - username - необязательно
###return
#0 - выполнено успешно
#2 - пользователь mysql не существует
#3 - операция отменена пользователем
input_dbUserDelete_querry() {
    clear
    echo -e "${COLOR_GREEN}Удаление пользователя mysql ${COLOR_NC}"
    dbViewAllUsers
    d=`date +%Y.%m.%d`

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    username=$1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql для его удаления: ${COLOR_NC}"
	    read username
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	#Проверка на существование пользователя mysql "$username"
	if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
	then
	#Пользователь mysql "$username" существует
        echo -n -e "${COLOR_YELLOW}Подтвердите удаление mysql-пользователя ${COLOR_GREEN}\"$username\"${COLOR_YELLOW} введите для удаления ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для отмены - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
            while read
            do
                case "$REPLY" in
                    y|Y)
                        sudo bash -c "source $SCRIPTS/include/inc.sh; mkdirWithOwn $path $USERLAMER users 755"
                        dbBackupBasesOneUser $username full_info data NoDeleteBase
                        clear;
                        dbUserdel $username drop; dbViewAllUsers; menuUserMysql $1;
                        return 0;
                        break
                        ;;
                    n|N)
                        echo -e "${COLOR_YELLOW}Операция отменена пользователем${COLOR_NC}";
                        menuUserMysql $1;
                        return 3;
                        break
                        ;;
                    *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                       ;;
                esac
            done
	#Пользователь mysql "$username" существует (конец)
	else
	#Пользователь mysql "$username" не существует
	    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserDelete_querry\" ${COLOR_NC}"
	    input_dbUserDelete_querry $username
	    return 2
	#Пользователь mysql "$username" не существует (конец)
	fi
	#Конец проверки на существование пользователя mysql "$username"
}

#смена прав доступа на сервер для пользователя
###!ПОЛНОСТЬЮ ГОТОВО. 29.03.2019
###input
#$1-type ; 1 - grant , 2 - admin , 3 - user
#$2-host ;
#$3-username ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь mysql не существует
#3 - ошибка host_type
#4 - ошибка mode_access
dbUserChangeAccess() {
    #Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
        #Проверка на существование пользователя mysql "$3"
        if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$3'" 2>&1`" ]];
        then
        #Пользователь mysql "$3" существует
            username=$3
        #Пользователь mysql "$3" существует (конец)
        else
        #Пользователь mysql "$3" не существует
            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserChangeAccess\" ${COLOR_NC}"
            return 2
        #Пользователь mysql "$3" не существует (конец)
        fi
        #Конец проверки на существование пользователя mysql "$3"

        #Проверка на существование параметров запуска скрипта
        if [ -n "$2" ]
        then
        #Параметры запуска существуют
            case "$2" in
                localhost)
                    host="localhost"
                    ;;
                %)
                    host="%"
                    ;;
                *)
                    echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"dbUserChangeAccess\" ${COLOR_NC}";
                    return 3
                    ;;
            esac
        #Параметры запуска существуют (конец)
		fi
		#Проверка на существование параметров запуска скрипта
        if [ -n "$1" ]
        then
        #Параметры запуска существуют
            case "$1" in
#                    1)
#                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT USAGE ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
#                        mysql -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$username'@'$2';";
#                        mysql -e "FLUSH PRIVILEGES;"
#                        ;;
#                    2)
#                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT RELOAD, PROCESS,  SHOW DATABASES, SUPER, LOCK TABLES, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
#                        mysql -e "FLUSH PRIVILEGES;"
#                        ;;
#                    3)
#                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; GRANT RELOAD, PROCESS, SHOW DATABASES, SUPER, LOCK TABLES, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO '$username'@'$2' REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
#                        mysql -e "FLUSH PRIVILEGES;"
#                        ;;

                    1)
                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT ALL PRIVILEGES ON *.* TO '$username'@'$2' WITH GRANT OPTION;";
                        mysql -e "FLUSH PRIVILEGES;"
                        ;;

                    2)
                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EXECUTE ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
                        mysql -e "FLUSH PRIVILEGES;"
                        ;;
                    3)
                        mysql -e "REVOKE ALL PRIVILEGES ON *.* FROM '$username'@'$2'; REVOKE GRANT OPTION ON *.* FROM '$username'@'$2'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, FILE, INDEX, ALTER, CREATE TEMPORARY TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON *.* TO '$username'@'$2' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";
                        mysql -e "FLUSH PRIVILEGES;"
                        ;;
                   *)
                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_dbUserChangeAccess\"${COLOR_NC}";
                        return 4
                        ;;
                esac

        #Параметры запуска существуют (конец)
		fi
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUserChangeAccess\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта


}



#установка прав доступа пользователю на базу
###input
#$1-mysql user ;
#$2-dbname ;
#$3-type - lanAccess (localhost/%) ;
#4 - type-standart/adminGrant/select_only
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь mysql не существует
#3 - база данных не существует
#4 - ошибка передачи параметра lanAccess (localhost/%) ;
dbUserSetAccessToBase() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют

	    case "$3" in
	        %)
	            lanAccess="%"
	            ;;
	        localhost)
	            lanAccess="localhost"
	            ;;
	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode lanAccess (localhost/%)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"dbUserSetAccessToBase\"${COLOR_NC}";
	    	    return 4
	    	    ;;
	    esac

		#Проверка на существование пользователя mysql "$1"
		if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$1'" 2>&1`" ]];
		then
		#Пользователь mysql "$1" существует
            #Проверка существования базы данных "$2"
            if [[ ! -z "`mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$2'" 2>&1`" ]];
            	then
            	#база $2 - существует
            		case "$4" in
            		    standart)
                            mysql -e "REVOKE ALL PRIVILEGES ON \`$2\`.* FROM '$1'@'$lanAccess';";
                            mysql -e "GRANT USAGE ON \`$2\`.* TO '$1'@'$lanAccess';";
                            #mysql -e "GRANT OPTION FROM '$1'@'$lanAccess';";
                            mysql -e "FLUSH PRIVILEGES;"
            		        ;;
            		    adminGrant)
                            mysql -e "REVOKE ALL PRIVILEGES ON \`$2\`.* FROM '$1'@'$lanAccess';";
                            mysql -e "GRANT ALL PRIVILEGES ON \`$2\`.* TO '$1'@'$lanAccess' WITH GRANT OPTION;";
                            mysql -e "FLUSH PRIVILEGES;"
            		        ;;
            			select_only)
            			    mysql -e "REVOKE ALL PRIVILEGES ON \`$2\`.* FROM '$1'@'$lanAccess';";
            			    #mysql -e "REVOKE GRANT OPTION ON \`$2\`.* FROM '$1'@'$lanAccess';";
                            mysql -e "GRANT SELECT ON \`$2\`.* TO '$1'@'$lanAccess';";
                            mysql -e "FLUSH PRIVILEGES;"

            				;;
            			*)
            			    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"\"${COLOR_NC}";
            			    ;;
            		esac
            	#база $2 - существует (конец)
            	else
            	#база $2 - не существует
            	     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"\" ${COLOR_NC}"
            	     return 3
            	#база $2 - не существует (конец)
            fi
            #конец проверки существования базы данных $2


		#Пользователь mysql "$1" существует (конец)
		else
		#Пользователь mysql "$1" не существует
		    echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbUserSetAccessToBase\" ${COLOR_NC}"
		    return 2
		#Пользователь mysql "$1" не существует (конец)
		fi
		#Конец проверки на существование пользователя mysql "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbUserSetAccessToBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#запрос имени пользователя для того, чтобы сделать из пользователя администратора
###input
#$1-type (user/admin/adminGrant) ;
#$2 - host
#$3-username - не обязательно
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#4 - пользователь $3 не существует
#3 - ошибка type (user/admin/adminGrant)
input_dbUserChangeAccess() {
	dbViewAllUsers

	#Проверка на существование параметров запуска скрипта
	if [ -n "$3" ]
	then
	#Параметры запуска существуют
	    #Проверка на существование пользователя mysql "$3"
	    if [[ ! -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$3'" 2>&1`" ]];
	    then
	    #Пользователь mysql "$3" существует
	        username=$3
	    #Пользователь mysql "$3" существует (конец)
	    else
	    #Пользователь mysql "$3" не существует
	        echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserChangeAccess\" ${COLOR_NC}"
	        return 4
	    #Пользователь mysql "$3" не существует (конец)
	    fi
	    #Конец проверки на существование пользователя mysql "$3"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql для смены типа доступа: ${COLOR_NC}"
	        read username

	        #Проверка на существование пользователя mysql "$username"
	        if [[ -z "`mysql -qfsBe "SELECT User FROM mysql.user WHERE User='$username'" 2>&1`" ]];
	        then
	        #Пользователь mysql "$username" не существует
	            echo -e "${COLOR_RED}Пользователь mysql ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_dbUserChangeAccess\" ${COLOR_NC}"
	            return 4
	        #Пользователь mysql "$username" не существует (конец)
	        fi
	        #Конец проверки на существование пользователя mysql "$username"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта



	#Проверка на существование параметров запуска скрипта
	if [ -n "$2" ]
	then
	#Параметры запуска существуют
	    host=$2
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
        echo -n -e "${COLOR_YELLOW}Выберите вид доступа пользователя к базам данных mysql ${COLOR_GREEN}\"localhost/%\"${COLOR_NC}: "
                                    while read
                                    do
                                        case "$REPLY" in
                                            localhost)
                                                host=localhost;
                                                break;;
                                            %)
                                                host="%";
                                                break;;
                                            *)
                                                 echo -e -n "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"host_type\"${COLOR_RED} в функцию  ${COLOR_GREEN}\"input_dbUserChangeAccess\"${COLOR_YELLOW}\nПовторите ввод вида доступа пользователя ${COLOR_GREEN}\"localhost/%\":${COLOR_RED}  ${COLOR_NC}";;
                                        esac
                                done
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
        typeAccess=$1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -n -e "${COLOR_YELLOW}Введите тип доступа для пользователя.${COLOR_GREEN}1${COLOR_YELLOW}-admin grant, ${COLOR_GREEN}2${COLOR_YELLOW}-admin, ${COLOR_GREEN}3${COLOR_YELLOW}-user${COLOR_NC}: "
	    read typeAccess
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

	dbUserChangeAccess $typeAccess $host $username
	dbViewAllUsers
}

#Запрос имени пользователя для вывода полной информации о пользователе
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

#Запрос части имени пользователя для вывода пользователей группы admin-access
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
input_viewGroupAdminAccessByName() {
    echo -e -n "${COLOR_YELLOW}Введите имя или часть имени для поиска пользователей группы ${COLOR_GREEN}\"admin-access\"${COLOR_YELLOW}: ${COLOR_NC}"
    read username
    clear
    viewGroupAdminAccessByName $username
}

#Запрос части имени пользователя для вывода пользователей группы sudo
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
input_viewGroupSudoAccessByName() {
    echo -e -n "${COLOR_YELLOW}Введите имя или часть имени для поиска пользователей группы ${COLOR_GREEN}\"sudo\"${COLOR_YELLOW}: ${COLOR_NC}"
    read username
    clear
    viewGroupSudoAccessByName $username
}

#Запрос части имени пользователя для вывода пользователей группы users
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
input_viewUserInGroupUsersByPartName() {
    echo -e -n "${COLOR_YELLOW}Введите имя или часть имени для поиска пользователей группы ${COLOR_GREEN}\"users\"${COLOR_YELLOW}: ${COLOR_NC}"
    read username
    clear
    viewUserInGroupUsersByPartName $username
}

#Запрос названия группы для вывода списка ее членов
###!ПОЛНОСТЬЮ ГОТОВО. 18.03.2019
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


#Проверка наличия сайта
###input
#$1-username;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - Ошибка обработки возвращенного результата выполнения операции в функции input_siteExist-searchSiteConfigAllFolder
#4 - ошибка ввода конфигурации apache
#5 - ошибка ввода конфигурации nginx
#6 - операция добавления отменена пользователем
input_siteExist() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    #Проверка существования системного пользователя "$1"
	    	grep "^$1:" /etc/passwd >/dev/null
	    	if  [ $? -eq 0 ]
	    	then
	    	#Пользователь $1 существует

                echo -n -e "${COLOR_BLUE}Введите домен: ${COLOR_NC}"
	            read domain

	            searchSiteConfigAllFolder $domain success_only
	            #Проверка на успешность выполнения предыдущей команды
	            case "$?" in
	                0)
	                    echo -e "${COLOR_RED}Операция добавления домена ${COLOR_GREEN}\"$domain\"${COLOR_RED} прервана${COLOR_NC}"
	                    ;;
	                2)

                        site_path=$HOMEPATHWEBUSERS/$1/$domain
                        echo ''
                        echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

                        ls $TEMPLATES/apache2/
                        echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
                        echo -n ": "
                        read apache_config

                            #Проверка существования файла "$TEMPLATES/apache2/$apache_config"
                            if ! [ -f $TEMPLATES/apache2/$apache_config ] ; then
                                #Файл "$TEMPLATES/apache2/$apache_config" не существует
                                echo -e "${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$TEMPLATES/apache2/$apache_config\"${COLOR_RED} не существует. Операция прервана${COLOR_NC}"
                                return 4
                                #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                            fi
                            #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"

                        echo ''
                        echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
                        ls $TEMPLATES/nginx/
                        echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
                        echo -n ": "
                        read nginx_config

                            #Проверка существования файла "$TEMPLATES/nginx/$nginx_config"
                            if ! [ -f $TEMPLATES/nginx/$nginx_config ] ; then
                                #Файл "$TEMPLATES/nginx/$nginx_config" не существует
                                echo -e "${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$TEMPLATES/nginx/$nginx_config\"${COLOR_RED} не существует. Операция прервана${COLOR_NC}"
                                return 5
                                #Файл "$TEMPLATES/nginx/$nginx_config" не существует (конец)
                            fi
                            #Конец проверки существования файла "$TEMPLATES/nginx/$nginx_config"

                        echo ''
                        echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
                        echo -n ": "
                        read item
                        case "$item" in
                            y|Y) echo
                                echo $1 $domain $1 $site_path $apache_config $nginx_config
                                ;;
                            *) echo "Выход..."
                                return 6
                                ;;
                        esac
                        #Параметры запуска существуют (конец)


	                    ;;
	            	*)
	            	    echo -e "${COLOR_RED}Ошибка обработки возвращенного результата выполнения операции в функции ${COLOR_GREEN}\"input_siteExist-searchSiteConfigAllFolder\"${COLOR_NC}";
	            	    return 3
	            	    ;;
	            esac
	    	#Пользователь $1 существует (конец)
	    	else
	    	#Пользователь $1 не существует
	    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_siteExist\"${COLOR_NC}"
                return 2
	    	#Пользователь $1 не существует (конец)
	    	fi
	    #Конец проверки существования системного пользователя $1

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"input_siteExist\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Проверка существования сайта
###input
#$1-domain
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - каталог домена имеется в папках пользователей




#Замена переменных в конфигах веб-серверов
###input
#$1-webserver(apache/nginx)
#$2-username ;
#$3-domain ;
#$4-port ;

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - ошибка передачи параметра mode:webserver(apache/nginx)
#3 - пользователь $2 не существует
#4 - файл "$path"/"$2"_"$3".conf не существует
siteChangeWebserverConfigs() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
        case "$1" in
            apache)
                path="/etc/apache2/sites-available"
                ;;
            nginx)
                path="/etc/nginx/sites-available"
                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: webserver\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_NC}";
        	    return
        	    ;;
        esac

        #Проверка существования системного пользователя "$2"
        	grep "^$2:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $2 существует
        		#Проверка существования файла ""$path"/"$2"_"$3".conf"
        		if [ -f "$path"/"$2"_"$3".conf ] ; then
        		    #Файл ""$path"/"$2"_"$3".conf" существует


                           #sudo echo "Замена переменных в файле "$path"/"$2"_"$3".conf"
                           sudo grep '#__DOMAIN' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/#__DOMAIN/'$3'/g' "$path"/"$2"_"$3".conf
                           sudo grep '#__USER' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/#__USER/'$2'/g' "$path"/"$2"_"$3".conf

                           sudo grep '#__PORT' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/#__PORT/'$4'/g' "$path"/"$2"_"$3".conf
                           sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  "$path"/"$2"_"$3".conf | sudo xargs sed -i 's/'#__HOMEPATHWEBUSERS'/\/home\/webusers/g' "$path"/"$2"_"$3".conf
                            return 0

        		    #Файл ""$path"/"$2"_"$3".conf" существует (конец)
        		else
        		    #Файл ""$path"/"$2"_"$3".conf" не существует
        		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\""$path"/"$2"_"$3".conf\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_NC}"
        		    return 4
        		    #Файл ""$path"/"$2"_"$3".conf" не существует (конец)
        		fi
        		#Конец проверки существования файла ""$path"/"$2"_"$3".conf"

        	#Пользователь $2 существует (конец)
        	else
        	#Пользователь $2 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_NC}"
        		return 3
        	#Пользователь $2 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $2


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteChangeWebserverConfigs\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#Добавление тестового индексного файла при добавлении домена
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1 - user
#$2-domain ;
#$3 - wwwfolder_name
#$4-mode: replace/noreplace ;
#$5-mode (type index file): phpinfo ;

###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - каталог $HOMEPATHWEBUSERS/$1/$2/$3 не существует
#4 - ошибка передачи параметра mode: replace/noreplace
#5 - ошибка передачи параметра mode (type index file): phpinfo
siteAddTestIndexFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует
				#Проверка существования каталога "$HOMEPATHWEBUSERS/$1/$2/$3"
				if [ -d $HOMEPATHWEBUSERS/$1/$2/$3 ] ; then
				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" существует

				    case "$4" in
				        replace)

                            case "$5" in
                                phpinfo)
                                     sudo cp -f $TEMPLATES/index_php/index.php $HOMEPATHWEBUSERS/$1/$2/$3/index.php
                                     sudo cp -f $TEMPLATES/index_php/underconstruction.jpg $HOMEPATHWEBUSERS/$1/$2/$3/underconstruction.jpg
                                     sudo grep '#__DOMAIN' -P -R -I -l  $HOMEPATHWEBUSERS/$1/$2/$3/index.php | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' $HOMEPATHWEBUSERS/$1/$2/$3/index.php;
                                     return 0
                                    ;;

                            	*)
                            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode - (type index file)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}";
                            	    return 5
                            	    ;;
                            esac
				            ;;
				        noreplace)
                            case "$5" in
                                phpinfo)
                                     sudo cp -n $TEMPLATES/index_php/index.php $HOMEPATHWEBUSERS/$1/$2/$3/index.php
                                     sudo cp -n $TEMPLATES/index_php/underconstruction.jpg $HOMEPATHWEBUSERS/$1/$2/$3/underconstruction.jpg
                                     sudo grep '#__DOMAIN' -P -R -I -l  $HOMEPATHWEBUSERS/$1/$2/$3/index.php | sudo xargs sed -i 's/#__DOMAIN/'$2'/g' $HOMEPATHWEBUSERS/$1/$2/$3/index.php;
                                     return 0
                                    ;;

                            	*)
                            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode - (type index file)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}";
                            	    return 5
                            	    ;;
                            esac
				            ;;
				    	*)
				    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}";
				    	    return 4
				    	    ;;
				    esac

				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" существует (конец)
				else
				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" не существует
				    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$HOMEPATHWEBUSERS/$1/$2/$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}"
				    return 3
				    #Каталог "$HOMEPATHWEBUSERS/$1/$2/$3" не существует (конец)
				fi
				#Конец проверки существования каталога "$HOMEPATHWEBUSERS/$1/$2/$3"

			#Пользователь $1 существует (конец)
			else
			#Пользователь $1 не существует
			    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_NC}"
				return 2
			#Пользователь $1 не существует (конец)
			fi
		#Конец проверки существования системного пользователя $1
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAddTestIndexFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

siteExist() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ]
	then
	#Параметры запуска существуют

                #Пользователь $2 существует
                    [ "$(ls -A $NGINXAVAILABLE | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            nginxAvailableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$NGINXAVAILABLE${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            nginxAvailableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команды
                    #echo nginxAvailableExist=$nginxAvailableExist

                    [ "$(ls -A $NGINXENABLED | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            nginxEnableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$NGINXENABLED${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            nginxEnableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команды
                     #echo nginxEnableExist=$nginxEnableExist

                    [ "$(ls -A $APACHEAVAILABLE | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            apacheAvailableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$APACHEAVAILABLE${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            apacheAvailableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команды
                    #echo apacheAvailableExist=$apacheAvailableExist

                    [ "$(ls -A $APACHEENABLED | grep "_$1.conf$")" ]
                    #Проверка на успешность выполнения предыдущей команды
                    if [ $? -eq 0 ]
                        then
                            #предыдущая команда завершилась успешно
                            apacheEnableExist=1
                            echo -e "${COLOR_RED}Файл конфигурации для домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже существует: ${COLOR_GREEN}$APACHEENABLED${COLOR_YELLOW}/$(ls -A $NGINXAVAILABLE | grep "_$1.conf$") ${COLOR_NC}"
                            #предыдущая команда завершилась успешно (конец)
                        else
                            #предыдущая команда завершилась с ошибкой
                            apacheEnableExist=0
                            #предыдущая команда завершилась с ошибкой (конец)
                    fi
                    #Конец проверки на успешность выполнения предыдущей команд
                    #echo apacheEnableExist=$apacheEnableExist


                        #TODO сделать поиск find
                    ls $HOMEPATHWEBUSERS | while read line
                    do
                        echo $HOMEPATHWEBUSERS/$line


                            ls $HOMEPATHWEBUSERS/$line | while read line2
                            do
                                echo $line2
                                if [ $line2 == $1 ]
                                then
                                        echo -e "${COLOR_RED}Каталог домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже имеется в домашней папке пользователя ${COLOR_YELLOW}$line${COLOR_RED} - ${COLOR_GREEN}$HOMEPATHWEBUSERS/$line/$1${COLOR_NC}"
                                        temp=1
                                        break
                                fi
                            (( i++ ))
                            done
                                        		#echo -e "${COLOR_RED}Каталог домена ${COLOR_GREEN}\"$1\"${COLOR_RED} уже имеется в домашней папке пользователя ${COLOR_YELLOW}$line${COLOR_RED} - ${COLOR_GREEN}$HOMEPATHWEBUSERS/$line/$1${COLOR_NC}"
                                        		#return 3
                             if [ $temp==1 ]
                             then
                                echo '123'
                                break
                             fi

                    (( i++ ))
                    done

       if [ "$nginxAvailableExist" == "1" ] || [ "$nginxEnableExist" == "1" ] || [ "$apacheAvailableExist" == "1" ] || [ "$apacheEnableExist" == "1" ]
       then
            return 3
       fi

       folderExistWithInfo $HOMEPATHWEBUSERS/$line/$1 exist silent
                                                #Проверка на успешность выполнения предыдущей команды
                                                if [ $? -eq 6 ]
                                                	then
                                                		#предыдущая команда завершилась успешно
                                                		return 3
                                                		#предыдущая команда завершилась успешно (конец)
                                                fi
                                                #Конец проверки на успешность выполнения предыдущей команды
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в фукнции ${COLOR_GREEN}\"siteExist\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта






}

#Форма ввода данных для добавления сайта php
###input
#$1-username ;
#$2-mode: lite/querry ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - не существует файл apache_config
#3 - не существует файл nginx_config
#4 - не существует пользователь $1
#5 - конфиги для домена уже существуют в настройках сервера
#6 - каталог для домена уже существует на сервере
#7 - ошибка mode: querry/lite
input_SiteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования системного пользователя "$1"
			grep "^$1:" /etc/passwd >/dev/null
			if  [ $? -eq 0 ]
			then
			#Пользователь $1 существует

                clear
                echo "--------------------------------------"
                echo "Добавление виртуального хоста."

                #echo -e "${COLOR_YELLOW}Список имеющихся доменов:${COLOR_NC}"


                echo -n -e "${COLOR_BLUE}\nВведите домен для добавления ${COLOR_NC}: "
                read domain

                searchSiteConfigAllFolder $domain silent
                #Проверка на успешность выполнения предыдущей команды
                if [ $? -eq 0 ]
                	then
                		#Есть конфигурация
                		echo -e "${COLOR_RED}В настройках сервера уже имеется конфигурация для домена ${COLOR_GREEN}\"$domain\"${COLOR_RED}${COLOR_NC}"
                		return 5
                		#Есть конфигурация (конец)
                	else
                		#нет конфигурации

                		#поиск каталога
                        searchSiteFolder $domain $HOMEPATHWEBUSERS silent d 2
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                        	then
                        		#каталог существует
                        		echo -e "${COLOR_RED}В настройках сервера уже имеется каталог домена ${COLOR_GREEN}\"$domain\"${COLOR_RED}${COLOR_NC}"
                        		return 6
                        		#каталог существует (конец)
                        	else
                        		#каталог не существует


                                site_path=$HOMEPATHWEBUSERS/$1/$domain
                                echo ''

                                case "$2" in
                                    querry)
                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

                                                ls $TEMPLATES/apache2/
                                                echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
                                                echo -n ": "
                                                read apache_config
                                                #Проверка существования файла "$TEMPLATES/apache2/$apache_config"
                                                if ! [ -f $TEMPLATES/apache2/$apache_config ] ; then
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует
                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/apache2/$apache_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}"
                                                    return 2
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                                                fi
                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"


                                                echo ''
                                                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
                                                ls $TEMPLATES/nginx/
                                                echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
                                                echo -n ": "
                                                read nginx_config
                                                #Проверка существования файла "$TEMPLATES/nginx/$nginx_config"
                                                if ! [ -f $TEMPLATES/nginx/$nginx_config ] ; then
                                                    #Файл "$TEMPLATES/nginx/$nginx_config" не существует
                                                    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$TEMPLATES/nginx/$nginx_config\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}"
                                                    return 3
                                                    #Файл "$TEMPLATES/apache2/$apache_config" не существует (конец)
                                                fi
                                                #Конец проверки существования файла "$TEMPLATES/apache2/$apache_config"

                                                echo ''
                                                echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
                                                echo -n ": "
                                                read item
                                                case "$item" in
                                                    y|Y) echo
                                                        siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                                        exit 0
                                                        ;;
                                                    *) echo "Выход..."
                                                        exit 0
                                                        ;;
                                                esac
                                                #Параметры запуска существуют (конец)
                                                        ;;
                                    lite)
                                            apache_config="php_base.conf"
                                            nginx_config="php_base.conf"
                                            siteAdd_php $1 $domain $site_path $apache_config $nginx_config $1
                                        ;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode: querry/lite\"${COLOR_RED} в функцию ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}";
                                	    return 7
                                	    ;;
                                esac

                        		#каталог не существует (конец)
                        fi
                        #Конец проверки на успешность выполнения предыдущей команды
                		#нет конфигурациий (конец)
                fi
                #Конец проверки на успешность выполнения предыдущей команды



                    #Пользователь $1 существует (конец)
                    else
                    #Пользователь $1 не существует
                        echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_NC}"
                        return 4
                    #Пользователь $1 не существует (конец)
                    fi
                #Конец проверки существования системного пользователя $1

	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"input_SiteAdd_php\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


################################################search####################################################
#Поиск каталога в указанной папке (с вложением)
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1-domain ;
#$2-path-корневой каталог поиска ;
#$3-mode: full_info/silent ;
#$3-mode: d-directory; f-file;
#$5-максимальная вложенность - не обязательно
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - корневой каталог для начала поиска не существует
#3 - ошибка передачи параметра $3-mode: full_info/silent
#4 - отрицательный результат поиска
#5 - ошибка передачи параметра mode: folder/file - поиск файла или каталога
searchSiteFolder() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
	    case "$4" in
	        d)
	            #directory
	            searchType="d";
	            searchTypeWord="Каталог"
	            ;;
	        f)
	            #file
	             searchType="f";
	             searchTypeWord="Файл"
	            ;;
	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"searchType\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_NC}";
	    	    return 5
	    	    ;;
	    esac

		#Проверка существования каталога "$2"
		if [ -d $2 ] ; then
		    #Каталог "$2" существует
            path=$2
		    #Каталог "$2" существует (конец)
		else
		    #Каталог "$2" не существует
		    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_NC}"
		    return 2
		    #Каталог "$2" не существует (конец)
		fi
		#Конец проверки существования каталога "$2"

        case "$3" in
            full_info)

                #Проверка на существование параметров запуска скрипта - глубина поиска
                if [ -n "$5" ]
                then
                #Параметры запуска существуют

                    if [[ ! -z "$(sudo find $2 -maxdepth $5 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} расположен по следующему пути ${COLOR_GREEN}\"$(sudo find $2 -type $searchType -name "$1")\"${COLOR_YELLOW} с вложенностью поиска - ${COLOR_GREEN}$5${COLOR_NC}"
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} не найден во вложенных каталогах папки ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} с вложенностью поиска - ${COLOR_GREEN}$5${COLOR_NC}"
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют

                        #Поиск каталога по имени
                        if [[ ! -z "$(sudo find $2 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} расположен по следующему пути ${COLOR_GREEN}\"$(sudo find $2 -type $searchType -name "$1")\"${COLOR_YELLOW}  ${COLOR_NC}"
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             echo -e "${COLOR_YELLOW}$searchTypeWord ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} не найден во вложенных каталогах папки ${COLOR_GREEN}\"$2\"${COLOR_YELLOW}  ${COLOR_NC}"
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта  - глубина поиска (конец)
                ;;

            silent)
                #Проверка на существование параметров запуска скрипта - глубина поиска
                if [ -n "$5" ]
                then
                #Параметры запуска существуют

                    if [[ ! -z "$(sudo find $2 -maxdepth $5 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска существуют (конец)
                else
                #Параметры запуска отсутствуют

                        #Поиск каталога по имени
                        if [[ ! -z "$(sudo find $2 -type $searchType -name "$1")" ]]
                        then
                            #Результат поиска положительный
                            return 0
                            #Результат поиска положительный (конец)
                         else
                             #Результат поиска отрицательный
                             return 4
                             #Результат поиска отрицательный (конец)
                         fi
                        #Поиск каталога по имени (конец)

                #Параметры запуска отсутствуют (конец)
                fi
                #Конец проверки существования параметров запуска скрипта  - глубина поиска (конец)

                ;;
        	*)
        	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_NC}";
        	    return 3
        	    ;;
        esac
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteFolder\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#Вывод списка конфигов apache2
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1 - Каталог (aa/ae/na/ne)
#$2 - domain
#$3 - mode: full_info/error_only/success_only/silent
#$4 - Username - не обязательно ; без параметра выводятся все конфиги
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - пользователь не существует
#3 - ошибка передачи параметра mode: apache2/nginx
#4 - результат отрицательный
#5 - ошибка передачи параметра mode-full_info/error_only/success_only/silent
searchSiteConfig() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
	then
	#Параметры запуска существуют
	    case "$1" in
	        aa)
                folder="/etc/apache2/sites-available"
	            ;;
	        ae)
                folder="/etc/apache2/sites-enabled"
	            ;;
	        na)
	            folder="/etc/nginx/sites-available"
	            ;;
	        ne)
	            folder="/etc/nginx/sites-enabled"
	            ;;

	    	*)
	    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-webserver\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
	    	    return 3
	    	    ;;
	    esac

	    #Проверка на существование параметров запуска скрипта
	    if [ -n "$4" ]
	    then
	    #Параметры запуска существуют
            #Проверка существования системного пользователя "$4"
        	grep "^$4:" /etc/passwd >/dev/null
        	if  [ $? -eq 0 ]
        	then
        	#Пользователь $4 существует

                        [ "$(ls -A $folder | grep "$4_$2.conf$")" ]
                        #Проверка на успешность выполнения предыдущей команды
                        if [ $? -eq 0 ]
                            then
                                #предыдущая команда завершилась успешно

                                case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} существует${COLOR_NC}"
                                        return 0
                                        ;;
                                    error_only)
                                         return 4
                                        ;;
                                	success_only)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} существует${COLOR_NC}"
                                        return 0
                                		;;
                                	silent)
                                        return 4
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac

                                #предыдущая команда завершилась успешно (конец)
                            else
                                #предыдущая команда завершилась с ошибкой
                                case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} отсутствует${COLOR_NC}"
                                        return 4
                                        ;;
                                    error_only)
                                        echo -e "\n${COLOR_GREEN}Конфигурация ${COLOR_YELLOW}\"$4_$2.conf\"${COLOR_GREEN} в каталоге ${COLOR_YELLOW}$folder${COLOR_GREEN} отсутствует${COLOR_NC}"
                                        return 4
                                        ;;
                                	success_only)
                                	    return 4
                                		;;
                                	silent)
                                        return 4
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac

                                #предыдущая команда завершилась с ошибкой (конец)
                        fi
                        #Конец проверки на успешность выполнения предыдущей команды


        	#Пользователь $4 существует (конец)
        	else
        	#Пользователь $2 не существует
        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}"
        		return 2
        	#Пользователь $4 не существует (конец)
        	fi
        #Конец проверки существования системного пользователя $4
	    #Параметры запуска существуют (конец)
	    else
	    #Параметры запуска отсутствуют
		            [ "$(ls -A $folder | grep "_$2.conf$")" ]
		            case "$?" in
		                0)
		                    case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_GREEN}Список всех конфигураций ${COLOR_LIGHT_RED}$1${COLOR_GREEN}:${COLOR_NC}";
		                                ls -l -A -L $folder | grep "$2.conf$"
		                                return 0
                                        ;;
                                    error_only)
                                        return 0
                                        ;;
                                	success_only)
                                	    echo -e "\n${COLOR_GREEN}Список всех конфигураций ${COLOR_LIGHT_RED}$1${COLOR_GREEN}:${COLOR_NC}";
		                                ls -l -A -L $folder | grep "$2.conf$"
		                                return 0
                                		;;
                                	silent)
                                        return 0
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac


		                    ;;
		                1)
		                    case "$3" in
                                    full_info)
                                        echo -e "\n${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$2.conf\"${COLOR_RED} в каталоге ${COLOR_YELLOW}$folder${COLOR_RED} - отсутствует${COLOR_NC}";
                                        return 4
                                        ;;
                                    error_only)
                                        echo -e "\n${COLOR_RED}Конфигурация ${COLOR_GREEN}\"$2.conf\"${COLOR_RED} в каталоге ${COLOR_YELLOW}$folder${COLOR_RED} - отсутствует${COLOR_NC}";
                                        return 4
                                        ;;
                                	success_only)
                                	    return 4
                                		;;
                                	silent)
                                	    return 4
                                		;;
                                	*)
                                	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode-full_info/error_only/success_only/silent\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
                                	    return 5
                                	    ;;
                                esac

		                    ;;
		            	*)
		            	    echo -e "${COLOR_RED}Код ошибки отличается от 0/1 в функции ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_NC}";
		            	    ;;
		            esac
	    fi
	    #Конец проверки существования параметров запуска скрипта
	else
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteConfig\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}

#Поиск файла конфигурации сайта в каталогах серверов apache2, nginx
###!ПОЛНОСТЬЮ ГОТОВО. 21.03.2019
###input
#$1-домен ;
#$2-mode full_info/error_only/success_only/silent ;
###return
#0 - Конфигурация существует
#1 - не переданы параметры в функцию
#2 - конфигурация отсутствует
#3 - ошибка передачи параметра mode full_info/error_only/success_only/silent
searchSiteConfigAllFolder() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		[ "$(ls -A $APACHEAVAILABLE | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_aa=0; else res_aa=1; folder=$APACHEAVAILABLE; fi

		[ "$(ls -A $APACHEENABLED | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_ae=0; else res_ae=1; folder=$APACHEENABLED; fi

        [ "$(ls -A $NGINXAVAILABLE | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_na=0; else res_na=1; folder=$NGINXAVAILABLE; fi

		[ "$(ls -A $NGINXENABLED | grep "_$1.conf$")" ]
		 if [ $? -eq 0 ]; then res_ne=0; else res_ne=1; folder=$NGINXENABLED; fi


		 if [ $res_aa -eq 0 ] || [ $res_ae -eq 0 ] || [ $res_na -eq 0 ] || [ $res_ne -eq 0 ]
		 then
            case "$2" in
                full_info)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} имеется в каталоге ${COLOR_GREEN}\"$folder\"${COLOR_YELLOW} ${COLOR_NC}"
                    ;;
                error_only)

                    ;;
            	success_only)
            	    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} имеется в каталоге ${COLOR_GREEN}\"$folder\"${COLOR_YELLOW} ${COLOR_NC}"
            		;;
                silent)

            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            return 0

         else
            case "$2" in
                full_info)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствует в каталогах веб-серверов${COLOR_NC}"
                    ;;
                error_only)
                    echo -e "${COLOR_YELLOW}Конфигурация домена ${COLOR_GREEN}\"$1\"${COLOR_YELLOW} отсутствует в каталогах веб-серверов${COLOR_NC}"
                    ;;
            	success_only)
            		;;
                silent)

            		;;
            	*)
            	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode\"${COLOR_RED} в функцию ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_NC}";
            	    return 3
            	    ;;
            esac
            return 2
		 fi

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"searchSiteConfigAllFolder\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
