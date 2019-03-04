#!/bin/bash


declare -x -f tar_folder_structure #Архивация каталога с сохранением структуры относительно корня: ($1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ; )
declare -x -f tar_folder_structure_remove #Архивация каталога с сохранением структуры каталогов относительно корня, с последующим удалением исходного каталога: ($1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ; )
declare -x -f tar_folder_without_structure #Архивация каталога без сохранения структуры каталогов относительно корня: ($1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ; )
declare -x -f tar_folder_without_structure_remove #Архивация каталога без сохранения структуры каталогов относительно корня, с последующим удалением исходного каталога: ($1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ; )
declare -x -f tar_file_structure #Архивация файла с сохранением структуры каталогов: ($1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;)
                                 #return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
                                 #3 - конечный каталог не найден, пользоватль отменил создание каталога
declare -x -f tar_file_structure_remove #Архивация файла с сохранением структуры каталогов с последующим удалением исходного файла: ($1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;)
                                 #return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
                                 #3 - конечный каталог не найден, пользоватль отменил создание каталога
declare -x -f tar_file_without_structure #Архивация файла без сохранения структуры каталогов: ($1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;)
                                         #return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
                                         #3 - конечный каталог не найден, пользоватль отменил создание каталога
declare -x -f tar_file_without_structure_remove #Архивация файла без сохранения структуры каталогов с последующим удалением исходного файла: ($1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;)
                                                #return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
                                                #3 - конечный каталог не найден, пользоватль отменил создание каталога




declare -x -f userAddSystem_old #Добавление системного пользователя: ($1-user ;)
#Готово. Можно добавить доп.функционал
#Добавление системного пользователя
#$1-user ;
#return 0 - выполнено успешно, 1 - пользователь уже существует
#2 - пользователь отменил создание пользователя
userAddSystem_old() {
    echo -e "${COLOR_YELLOW}"Список имеющихся пользователей системы:"${COLOR_NC}"
	viewGroupUsersAccessAll
	#Проверка на существование параметров запуска скрипта

	if [ -n "$1" ]
	then
	#Параметры запуска существуют
	    username=$1
	    dt=$DATETIMESQLFORMAT

	else
	    echo -e -n "${COLOR_BLUE}"Введите имя нового пользователя: "${COLOR_NC}"
		read username
	fi
	    grep "^$username:" /etc/passwd >/dev/null

	    #Проверка на успешность выполнения предыдущей команды
	    if [ $? -eq 0 ]
	    	then
	    		#Пользователь уже существует
	    		echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} уже существует${COLOR_NC}"
	    		return 1
	    		#Пользователь уже существует (конец)
	    else
                #Пользователь не существует и будет добавлен
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
                                mkdir -p $HOMEPATHWEBUSERS/$username
                                useradd -N -g users -G ftp-access -d $HOMEPATHWEBUSERS/$username -s /bin/bash $username

                                dbAddRecordToDb $WEBSERVER_DB users username $username insert
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username homedir $HOMEPATHWEBUSERS/$username update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username created "$dt" update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username created_by $(whoami) update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username isAdminAccess 0 update
                                dbUpdateRecordToDb $WEBSERVER_DB users username $username isFtpAccess 1 update

                                echo "$username:$password" | chpasswd

                                mkdirWithOwn $HOMEPATHWEBUSERS/$username/.backups $username users 777
                                mkdirWithOwn $HOMEPATHWEBUSERS/$username/.backups/auto $username users 755
                                mkdirWithOwn $HOMEPATHWEBUSERS/$username/.backups/manually $username users 755
                                touchFileWithModAndOwn $HOMEPATHWEBUSERS/$username/.bashrc $username users 644
                                touchFileWithModAndOwn $HOMEPATHWEBUSERS/$username/.sudo_as_admin_successful $username users 644
                                echo "source /etc/profile" >> $HOMEPATHWEBUSERS/$username/.bashrc
                                sed -i '$ a source $SCRIPTS/include/include.sh'  $HOMEPATHWEBUSERS/$username/.bashrc
                               # sed -i '$ a $SCRIPTS/menu'  $HOMEPATHWEBUSERS/$username/.bashrc
                                dbSetMyCnfFile $username $password
                                chModAndOwnFile $HOMEPATHWEBUSERS/$username/.my.cnf $username users 600
                                #chModAndOwnFolderAndFiles $HOMEPATHWEBUSERS/$username 755 644 $username users
                                #добавление в группу sudo
                                userAddToGroup $username sudo 1

                                #Проверка на успешность выполнения предыдущей команды
                                if [ $? -eq 0 ]
                                	then
                                		#предыдущая команда завершилась успешно
                                		    dbUpdateRecordToDb $WEBSERVER_DB users username $username isSudo 1 update
                                		#предыдущая команда завершилась успешно (конец)
                                	else
                                		#предыдущая команда завершилась с ошибкой
                                		    dbUpdateRecordToDb $WEBSERVER_DB users username $username isSudo 0 update
                                		#предыдущая команда завершилась с ошибкой (конец)
                                fi
                                #Конец проверки на успешность выполнения предыдущей команды

                                echo -n -e "${COLOR_YELLOW}Введите ${COLOR_BLUE}\"g\"${COLOR_NC}${COLOR_YELLOW} для генерации ssh-ключа, ${COLOR_GREEN}\"i\"${COLOR_NC}${COLOR_YELLOW} - для импорта существующего на сервер ключа, ${COLOR_BLUE}\"q\"${COLOR_YELLOW} - для отмены добавления ssh-ключа${COLOR_NC}: "
                                	while read
                                	do
                                    	echo -n ": "
                                    	case "$REPLY" in
                                	    	g|G) sshKeyGenerateToUser $username;
                                	    	     sshKeyAddToUser $username 0 $sshAdminKeyFilePath;
                                	    	     dbUpdateRecordToDb $WEBSERVER_DB users username $username isSshAccess 1 update
                                		    	break;;
                                		    i|I)
                                                sshKeyAddToUser $username 1;
                                                sshKeyAddToUser $username 0 $sshAdminKeyFilePath;
                                                dbUpdateRecordToDb $WEBSERVER_DB users username $username isSshAccess 1 update
                                		    	break;;
                                		    q|Q)
                                		        dbUpdateRecordToDb $WEBSERVER_DB users username $username isSshAccess 0 update
                                			    break;;
                                	    esac
                                	done

                                #создание пользователя mysql
                                dbUseradd $username $password % pass user
                                dbAddRecordToDb $WEBSERVER_DB db_users username $username insert
                                dbUpdateRecordToDb $WEBSERVER_DB db_users username $username created "$dt" update
                                dbUpdateRecordToDb $WEBSERVER_DB db_users username $username created_by $(whoami) update
                                dbUpdateRecordToDb $WEBSERVER_DB db_users username $username comment "$username" update


                                echo -e "${COLOR_GREEN}Пользователь ${COLOR_YELLOW}\"$username\"${COLOR_GREEN} успешно добавлен${COLOR_YELLOW}\"\"${COLOR_GREEN} ${COLOR_NC}"
                                viewUserFullInfo $username

                                return 0
                            fi
                            #Проверка на пустое значение переменной (конец)

                            break
                            ;;
                        n|N)
                            echo -e "${COLOR_RED}Отмена создания пользователя ${COLOR_GREEN}\"$username\"${COLOR_NC}"
                            return 2
                            break
                            ;;
                        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
                           ;;
                    esac
                done

	##Здесь описать порядок действий при создании пользователя
	return 0
                #Пользователь не существует и будет добавлен (конец)
	    fi
	    #Конец проверки на успешность выполнения предыдущей команды
	#Параметры запуска существуют (конец)
}


#Архивация файла с сохранением структуры каталогов
#$1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;
#return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
#3 - каталог не найден, пользоватль отменил создание каталога
tar_file_structure() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        tar -czpf $2 -P $1
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		    echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_file_structure\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					tar -czpf $2 -P $1;
					break;;
				n|N)
				     return 3;
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"

		     #Финальная проверка существования файла "$2"
		        if [ -f $2 ] ; then
		            #Файл "$2" существует
		            return 0
		            #Файл "$2" существует (конец)
		        else
		            #Файл "$2" не существует
		            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не найден после завершения архивации. Функция ${COLOR_GREEN}\"tar_file_structure\"${COLOR_NC}"
		            return 2
		            #Файл "$2" не существует (конец)
		        fi
		        #Финальная проверка существования файла "$2"

		    #Файл "$1" существует (конец)
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует файл ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\".${COLOR_RED}Функция ${COLOR_GREEN}\"tar_file_structure\"${COLOR_NC}"
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_file_structure\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Архивация файла с сохранением структуры каталогов, с последующим удалением исходного файла
#$1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;
#return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
#3 - каталог не найден, пользоватль отменил создание каталога
tar_file_structure_remove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        tar -czpf $2 -P $1 --remove-files
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		    echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_file_structure_remove\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					tar -czpf $2 -P $1 --remove-files;
					break;;
				n|N)
				     return 3;
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"

		     #Финальная проверка существования файла "$2"
		        if [ -f $2 ] ; then
		            #Файл "$2" существует
		            return 0
		            #Файл "$2" существует (конец)
		        else
		            #Файл "$2" не существует
		            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не найден после завершения архивации. Функция ${COLOR_GREEN}\"tar_file_structure_remove\"${COLOR_NC}"
		            return 2
		            #Файл "$2" не существует (конец)
		        fi
		        #Финальная проверка существования файла "$2" (конец)

		    #Файл "$1" существует (конец)
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует файл ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\".${COLOR_RED}Функция ${COLOR_GREEN}\"tar_file_structure_remove\"${COLOR_NC}"
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_file_structure_remove\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Архивация файла без сохранения структуры каталогов
#$1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;
#return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
#3 - каталог не найден, пользоватль отменил создание каталога
tar_file_without_structure() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        cd `dirname $1` && tar -czpf $2 `basename $1`
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		    echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					cd `dirname $1` && tar -czpf $2 `basename $1`;
					break;;
				n|N)
				     return 3;
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"

		     #Финальная проверка существования файла "$2"
		        if [ -f $2 ] ; then
		            #Файл "$2" существует
		            return 0
		            #Файл "$2" существует (конец)
		        else
		            #Файл "$2" не существует
		            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не найден после завершения архивации. Функция ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_NC}"
		            return 2
		            #Файл "$2" не существует (конец)
		        fi
		        #Финальная проверка существования файла "$2" (конец)

		    #Файл "$1" существует (конец)
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует файл ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\".${COLOR_RED}Функция ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_NC}"
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#Архивация файла без сохранения структуры каталогов с последующим удалением исходного файла
#$1-Ссылка на файл для архивации ; $2-Ссылка на конечный архив ;
#return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - файл не найден после архивации
#3 - каталог не найден, пользоватль отменил создание каталога
tar_file_without_structure_remove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        cd `dirname $1` && tar -czpf $2 `basename $1` --remove-files;
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		    echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Фунция ${COLOR_GREEN}\"tar_file_without_structure_remove\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					cd `dirname $1` && tar -czpf $2 `basename $1` --remove-files;
					break;;
				n|N)
				     return 3;
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"

		     #Финальная проверка существования файла "$2"
		        if [ -f $2 ] ; then
		            #Файл "$2" существует
		            return 0
		            #Файл "$2" существует (конец)
		        else
		            #Файл "$2" не существует
		            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не найден после завершения архивации. Функция ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_NC}"
		            return 2
		            #Файл "$2" не существует (конец)
		        fi
		        #Финальная проверка существования файла "$2" (конец)

		    #Файл "$1" существует (конец)
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует файл ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\".${COLOR_RED}Функция ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_NC}"
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_file_without_structure\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


#
#Архивация каталога с сохранением структуры относительно корня
#$1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ;
#return 0 - выполнено успешно, 1-не переданы параметры в функцию, 2 - каталог архивации не найден
tar_folder_structure() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования каталога "$1"
		if [ -d $1 ] ; then
		    #Каталог "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        tar -czpf $2 -P $1
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		        echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_folder_structure\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					tar -czpf $2 -P $1  ;
					break;;
				n|N)
				     return 3;
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"

		    #Финальная проверка существования файла "$2"
		        if [ -f $2 ] ; then
		            #Файл "$2" существует
		            return 0
		            #Файл "$2" существует (конец)
		        else
		            #Файл "$2" не существует
		            echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$2\"${COLOR_RED} не найден после завершения архивации. Функция ${COLOR_GREEN}\"tar_folder_structure\"${COLOR_NC}"
		            return 2
		            #Файл "$2" не существует (конец)
		        fi
		        #Финальная проверка существования файла "$2" (конец)

		    #Каталог "$1" существует (конец)
		else
		    #Каталог "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\". ${COLOR_RED}Ошибка выполнения функции ${COLOR_GREEN}\"tar_folder_structure\"${COLOR_NC}"
		    return 2
		    #Каталог "$1" не существует (конец)
		fi
		#Конец проверки существования каталога "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_folder_structure\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Архивация каталога с сохранением структуры относительно корня, с последующим удалением исходной папки
#$1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ;
tar_folder_structure_remove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования каталога "$1"
		if [ -d $1 ] ; then
		    #Каталог "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        tar -czpf $2 -P $1 --remove-files
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		        echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_folder_structure_remove\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					tar -czpf $2 -P $1 --remove-files;
					break;;
				n|N)
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"
		    return
		    #Каталог "$1" существует (конец)
		else
		    #Каталог "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\"${COLOR_NC}"
		    return
		    #Каталог "$1" не существует (конец)
		fi
		#Конец проверки существования каталога "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_folder_structure_remove\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Архивация каталога без сохранения структуры каталогов относительно корня
#$1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ;
tar_folder_without_structure() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования каталога "$1"
		if [ -d $1 ] ; then
		    #Каталог "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        tar -cpf - -P -C $1 . | gzip -c > $2
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		        echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_folder_without_structure\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					tar -cpf - -P -C $1 . | gzip -c > $2;
					break;;
				n|N)
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"
		    return
		    #Каталог "$1" существует (конец)
		else
		    #Каталог "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\"${COLOR_NC}"
		    return
		    #Каталог "$1" не существует (конец)
		fi
		#Конец проверки существования каталога "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_folder_without_structure\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#Архивация каталога без сохранения структуры каталогов относительно корня, с последующим удалением исходного файла
#$1-Ссылка на каталог для архивации ; $2-Ссылка на конечный архив ;
tar_folder_without_structure_remove() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования каталога "$1"
		if [ -d $1 ] ; then
		    #Каталог "$1" существует
		    #Проверка существования каталога "`dirname $2`"
		    if [ -d `dirname $2` ] ; then
		        #Каталог "`dirname $2`" существует
		        tar -cpf - -P -C $1 . --remove-files | gzip -c > $2
		        #Каталог "`dirname $2`" существует (конец)
		    else
		        #Каталог "`dirname $2`" не существует
		        echo -e "${COLOR_RED} Каталог \"`dirname $2`\" не найден. Создать его? Функция ${COLOR_GREEN}\"tar_folder_without_structure_remove\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"`dirname $2`\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p `dirname $2`;
					tar -cpf - -P -C $1 . --remove-files | gzip -c > $2;
					break;;
				n|N)
					 break;;
				esac
			done
		        #Каталог "`dirname $2`" не существует (конец)
		    fi
		    #Конец проверки существования каталога "`dirname $2`"
		    return
		    #Каталог "$1" существует (конец)
		else
		    #Каталог "$1" не существует
		    echo -e "${COLOR_RED}Отсутствует каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} для архивации в ${COLOR_GREEN}\"$2\"${COLOR_NC}"
		    return
		    #Каталог "$1" не существует (конец)
		fi
		#Конец проверки существования каталога "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"tar_folder_without_structure_remove\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f untar_without_structure #разархивирование без сохранения структуры каталогов относительно корня: ($1-Ссылка на каталог назначения ; $2-Ссылка на архив)



#разархивирование без сохранения структуры каталогов относительно корня
#$1-Ссылка на каталог назначения ; $2-Ссылка на архив ;
untar_without_structure() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$2"
		if [ -f $2 ] ; then
		    #Файл "$2" существует
		    #Проверка существования каталога "$1"
		    if [ -d $1 ] ; then
		        #Каталог "$1" существует
		        tar -xpf $2 -P -C $1
		        #Каталог "$1" существует (конец)
		    else
		        #Каталог "$1" не существует
		        echo -e "${COLOR_RED} Каталог \"$1\" не найден. Создать его? Функция ${COLOR_GREEN}\"untar_without_structure\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$1\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p $1;
					tar -xpf $2 -P -C $1;
					break;;
				n|N)
					 break;;
				esac
			done
		        #Каталог "$1" не существует (конец)
		    fi
		    #Конец проверки существования каталога "$1"
		    return
		    #Файл "$2" существует (конец)
		else
		    #Файл "$2" не существует
		    echo -e "${COLOR_RED} Отсутствует архив ${COLOR_YELLOW}\"$2\"${COLOR_NC}"
	        return
		    #Файл "$2" не существует (конец)
		fi
		#Конец проверки существования файла "$2"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"untar_without_structure\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#
#разархивирование с сохранением структуры каталогов относительно корня
#$1-Ссылка на каталог назначения ; $2-Ссылка на архив ;
untar_with_structure() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$2"
		if [ -f $2 ] ; then
		    #Файл "$2" существует
		    #Проверка существования каталога "$1"
		    if [ -d $1 ] ; then
		        #Каталог "$1" существует
		        tar -xzpf $2 -P -C $1
		        #Каталог "$1" существует (конец)
		    else
		        #Каталог "$1" не существует
		        echo -e "${COLOR_RED} Каталог \"$1\" не найден. Создать его? Функция ${COLOR_GREEN}\"untar_with_structure\"${COLOR_NC}"
			echo -n -e "Введите ${COLOR_BLUE}\"y\"${COLOR_NC} для создания каталога ${COLOR_YELLOW}\"$1\"${COLOR_NC}, для отмены операции - ${COLOR_BLUE}\"n\"${COLOR_NC}: "

			while read
			do
			echo -n ": "
				case "$REPLY" in
				y|Y)
					mkdir -p $1;
					tar -xzpf $2 -P -C $1;
					break;;
				n|N)
					 break;;
				esac
			done
		        #Каталог "$1" не существует (конец)
		    fi
		    #Конец проверки существования каталога "$1"
		    return
		    #Файл "$2" существует (конец)
		else
		    #Файл "$2" не существует
		    echo -e "${COLOR_RED} Отсутствует архив ${COLOR_YELLOW}\"$2\"${COLOR_NC}"
	        return
		    #Файл "$2" не существует (конец)
		fi
		#Конец проверки существования файла "$2"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"untar_without_structure\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


