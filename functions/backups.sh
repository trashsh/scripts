#!/bin/bash



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


