#!/bin/bash

declare -x -f fileAddLineToFile
#Добавление строки в файл и его создание при необходимости
#в конце применить права к файлу вручную
###input
#$1-Путь к файлу
#$2-string ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - каталог не существует
fileAddLineToFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
	   	    #Проверка существования файла "$1"
	   	    if ! [ -f $1 ] ; then
	   	        #Файл "$1" не существует
	   	        #Проверка существования каталога "`dirname $1`"
	   	        if ! [ -d `dirname $1` ] ; then
	   	            #Каталог "`dirname $1`" не существует
                    sudo mkdir -p `dirname $1`
	   	            #Каталог "`dirname $1`" не существует (конец)
	   	        fi
	   	        sudo touch $1
	   	        #sudo echo $2 >> $1
	   	        #Файл "$1" не существует (конец)
	   	    else
	   	        #sudo chmod 666 $1
	   	        sudo echo $2 >> $1
	   	    fi
	   	    #Конец проверки существования файла "$1"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"fileAddLineToFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f mkdirWithOwn
#Создание папки и применение ей владельца и прав доступа
###input
#$1-путь к папке ;
#$2-user ;
#$3-group ;
#$4-разрешения ;
###return
#0 - выполнено успешно,
#1 - не переданы параметры,
#2 - пользователь не существует,
#3 - группа не существует
mkdirWithOwn() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		    #Проверка существования системного пользователя "$2"
		    	grep "^$2:" /etc/passwd >/dev/null
		    	if  [ $? -eq 0 ]
		    	then
		    	#Пользователь $2 существует
		    		#Проверка существования системной группы пользователей "$3"
		    		if grep -q $3 /etc/group
		    		    then
		    		        #Группа "$3" существует
		    		            sudo mkdir -p $1
		    		            sudo chmod $4 $1
				                sudo chown $2:$3 $1
				                return 0

		    		        #Группа "$3" существует (конец)
		    		    else
		    		        #Группа "$3" не существует
		    		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
                            return 3
		    				#Группа "$3" не существует (конец)
		    		    fi
		    		#Конец проверки существования системного пользователя $3
		    	#Пользователь $2 существует (конец)
		    	else
		    	#Пользователь $2 не существует
		    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
		    	    return 2
		    	#Пользователь $2 не существует (конец)
		    	fi
		    #Конец проверки существования системного пользователя $2


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f touchFileWithModAndOwn
#создание файла и применение прав к нему и владельца
###input
#$1-путь к файлу ;
#$2-user ;
#$3-group ;
#$4-права доступ ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры запуска,
#2 - пользователь не существует,
#3 - группа не существует,
#4 - файл существовал, применены лишь права
touchFileWithModAndOwn() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then


    #Проверка существования системного пользователя "$2"
    	grep "^$2:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $2 существует
    		#Проверка существования системной группы пользователей "$3"
    		if grep -q $3 /etc/group
    		    then
    		        #Группа "$3" существует
    		         #Проверка существования файла "$1"
    		         if [ -f $1 ] ; then
    		             #Файл "$1" существует
    		             sudo chmod $4 $1
		    			 sudo chown $2:$3 $1
		    			 return 4
    		             #Файл "$1" существует (конец)
    		         else
    		             #Файл "$1" не существует
    		             sudo touch $1
                         sudo chmod $4 $1
		    			 sudo chown $2:$3 $1
		    			 return 0
    		             #Файл "$1" не существует (конец)
    		         fi
    		         #Конец проверки существования файла "$1"

    		        #Группа "$3" существует (конец)
    		    else
    		        #Группа "$3" не существует
    		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_NC}"
    				return 3
    				#Группа "$3" не существует (конец)
    		    fi
    		#Конец проверки существования системной группы пользователей $3



    	#Пользователь $2 существует (конец)
    	else
    	#Пользователь $2 не существует
    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_NC}"
    		return 2
    	#Пользователь $2 не существует (конец)
    	fi
    #Конец проверки существования системного пользователя $2



	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f chModAndOwnFile
#Смена владельна и прав доступа на файл
###!Полностью готово. Не трогать больше
###input
#$1-путь к файлу ;
#$2-user ;
#$3-group ;
#$4-права доступа на файл ;
###return
#0 - выполнено успешно,
#1 - отсутствуют параметры,
#2 - отсутствует файл
#3 - отсутствует пользователь,
#4 - отсутствует группа
chModAndOwnFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    #Проверка существования системного пользователя "$2"
		    	grep "^$2:" /etc/passwd >/dev/null
		    	if  [ $? -eq 0 ]
		    	then
		    	#Пользователь $2 существует
		    		#Проверка существования системной группы пользователей "$3"
		    		if grep -q $3 /etc/group
		    		    then
		    		        #Группа "$3" существует
		    		            sudo chmod $4 $1
				                sudo chown $2:$3 $1
		    		        #Группа "$3" существует (конец)
		    		    else
		    		        #Группа "$3" не существует
		    		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
                            return 4
		    				#Группа "$3" не существует (конец)
		    		    fi
		    		#Конец проверки существования системного пользователя $3
		    	#Пользователь $2 существует (конец)
		    	else
		    	#Пользователь $2 не существует
		    	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
		    	    return 3
		    	#Пользователь $2 не существует (конец)
		    	fi
		    #Конец проверки существования системного пользователя $2
		    #Файл "$1" существует (конец)
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}${COLOR_NC}"
		    return 2
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chModAndOwnFile\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

declare -x -f chModAndOwnSiteFileAndFolder
#Смена прав,владельца для файлов и каталога сайта
###input
#$1-sitepath ;
#$2-wwwfolder ;
#$3-user ;
#$4-file permittion ;
#$5-folder permittion ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
#2 - каталог $1 не существует
#3 - каталог $1/$2 не существует
#4 - пользовтель $3 не существует
chModAndOwnSiteFileAndFolder() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
	then
	#Параметры запуска существуют
		#Проверка существования каталога "$1"
		if [ -d $1 ] ; then
		    #Каталог "$1" существует
		    #Проверка существования каталога ""$1"/"$2""
		    if [ -d "$1"/"$2" ] ; then
		        #Каталог ""$1"/"$2"" существует
		        #Проверка существования системного пользователя "$3"
		        	grep "^$3:" /etc/passwd >/dev/null
		        	if  [ $? -eq 0 ]
		        	then
		        	#Пользователь $3 существует
		        		sudo find $1 -type d -exec chmod $5 {} \;
                        sudo find $1 -type f -exec chmod $4 {} \;
                        #Проверка существования каталога ""$1"/"$2""
                        if [ -d "$1"/"$2" ] ; then
                            #Каталог ""$1"/"$2"" существует
                            sudo find $1/$2 -type d -exec chmod $5 {} \;
                            sudo find $1/$2 -type f -exec chmod $4 {} \;
                            #Каталог ""$1"/"$2"" существует (конец)
                        fi
                        #Конец проверки существования каталога ""$1"/"$2""
                         #Проверка существования каталога ""$1"/logs"
                        if [ -d "$1"/logs ] ; then
                            #Каталог ""$1"/logs" существует
                             sudo find $1/logs -type f -exec chmod $4 {} \;
                            #Каталог ""$1"/logs" существует (конец)
                        fi
                        #Конец проверки существования каталога ""$1"/logs"

                        sudo find $1 -type d -exec chown $3:www-data {} \;
                        sudo find $1 -type f -exec chown $3:www-data {} \;
		        	#Пользователь $3 существует (конец)
		        	else
		        	#Пользователь $3 не существует
		        	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnSiteFileAndFolder\"${COLOR_NC}"
		        		return 4
		        	#Пользователь $3 не существует (конец)
		        	fi
		        #Конец проверки существования системного пользователя $3
		        #Каталог ""$1"/"$2"" существует (конец)
		    else
		        #Каталог ""$1"/"$2"" не существует
		        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1/$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnSiteFileAndFolder\"${COLOR_NC}"
		        return 3

		        #Каталог ""$1"/"$2"" не существует (конец)
		    fi
		    #Конец проверки существования каталога ""$1"/"$2""

		    #Каталог "$1" существует (конец)
		else
		    #Каталог "$1" не существует
		    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnSiteFileAndFolder\"${COLOR_NC}"
		    return 2
		    #Каталог "$1" не существует (конец)
		fi
		#Конец проверки существования каталога "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chModAndOwnSiteFileAndFolder\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


declare -x -f chModAndOwnFolderAndFiles
#Смена разрешений на каталог и файлы, а также владельца
#$1-путь к каталогу; $2-права на каталог ; $3-Права на файлы ; $4-Владелец-user ; $5-Владелец-группа ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска,
#2 - не существует каталог, 3 - не существует пользователь, 4 - не существует группа
chModAndOwnFolderAndFiles() {
 #Проверка на существование параметров запуска скрипта
 if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
 then
 #Параметры запуска существуют
     #Проверка существования каталога "$1"
     if [ -d $1 ] ; then
         #Каталог "$1" существует
         #Проверка существования системного пользователя "$4"
         	grep "^$4:" /etc/passwd >/dev/null
         	if [ $? -eq 0 ]
         	then
         	#Пользователь $4 существует
         		existGroup $5 >/dev/null
         		#Проверка на успешность выполнения предыдущей команды
         		if [ $? -eq 0 ]
         			then
         				#предыдущая команда завершилась успешно
         				find $1 -type d -exec sudo chmod $3 {} \;
                        find $1 -type f -exec sudo chmod $3 {} \;
                        find $1 -type d -exec sudo chown $4:$5 {} \;
                        find $1 -type f -exec sudo chown $4:$5 {} \;
         				#предыдущая команда завершилась успешно (конец)
         			else
         				#предыдущая команда завершилась с ошибкой
         				echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$5\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
         				return 4
         				#предыдущая команда завершилась с ошибкой (конец)
         		fi
         		#Конец проверки на успешность выполнения предыдущей команды
         	#Пользователь $4 существует (конец)
         	else
         	#Пользователь $4 не существует
         	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$4\"${COLOR_RED} не существует${COLOR_NC}"
                return 3
         	#Пользователь $4 не существует (конец)
         	fi
         #Конец проверки существования системного пользователя $4
         #Каталог "$1" существует (конец)
     else
         #Каталог "$1" не существует
         echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chModAndOwnFolderAndFiles\"${COLOR_NC}"
         return 2
         #Каталог "$1" не существует (конец)
     fi
     #Конец проверки существования каталога "$1"

 #Параметры запуска существуют (конец)
 else
 #Параметры запуска отсутствуют
     echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chModAndOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
     return 1
 #Параметры запуска отсутствуют (конец)
 fi
 #Конец проверки существования параметров запуска скрипта
}

declare -x -f chOwnFolderAndFiles
#Смена владельца на файлы в папке и папку
###input
#$1-path ;
#$2-user;
#$3-group
###return
#0 - выполнено успешно,
#1 - каталог не существует,
#2 - пользователь не существует,
#3 - группа не существует
chOwnFolderAndFiles() {
 #Проверка на существование параметров запуска скрипта
 if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
 then
 #Параметры запуска существуют
     #Проверка существования каталога "$1"
     if [ -d $1 ]  ; then
         #Каталог "$1" существует
         #Проверка существования системного пользователя "$2"
         	grep "^$2:" /etc/passwd >/dev/null
         	if [ $? -eq 0 ]
         	then
         	#Пользователь $2 существует
         		existGroup $3 >/dev/null
         		#Проверка на успешность выполнения предыдущей команды
         		if [ $? -eq 0 ]
         			then
         				#предыдущая команда завершилась успешно
                        find $1 -type d -exec chown $2:$3 {} \;
                        find $1 -type f -exec chown $2:$3 {} \;
                        return 0
         				#предыдущая команда завершилась успешно (конец)
         			else
         				#предыдущая команда завершилась с ошибкой
         				echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
         				return 3
         				#предыдущая команда завершилась с ошибкой (конец)
         		fi
         		#Конец проверки на успешность выполнения предыдущей команды
         	#Пользователь $2 существует (конец)
         	else
         	#Пользователь $2 не существует
         	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_NC}"
         		return 2
         	#Пользователь $2 не существует (конец)
         	fi
         #Конец проверки существования системного пользователя $2
         #Каталог "$1" существует (конец)
     else
         #Каталог "$1" не существует
         echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_NC}"
         return 1
         #Каталог "$1" не существует (конец)
     fi
     #Конец проверки существования каталога "$1"

 #Параметры запуска существуют (конец)
 else
 #Параметры запуска отсутствуют
     echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"chOwnFolderAndFiles\"${COLOR_RED} ${COLOR_NC}"
 #Параметры запуска отсутствуют (конец)
 fi
 #Конец проверки существования параметров запуска скрипта
}


declare -x -f fileExistWithInfo
#проверка существования файла с выводом информации.
###!Полностью готово. Не трогать больше
#$1-path,
#$2-type (create/exist)
#return
#1 - не переданы параметры,
#2 - ошибка передачи параметров
#3 - файл не создан,
#4 -файл создан,
#5 - файл не существует,
#6 - файл существует
fileExistWithInfo(){

	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
	    case "$2" in
				"create")
					if ! [ -f $1 ] ; then
						echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не создан${COLOR_NC}"
						return 3
					else
						echo -e "${COLOR_GREEN}Файл ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} создан успешно${COLOR_NC}"
						return 4
					fi
						;;
				"exist")
					if ! [ -f $1 ] ; then
						echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
						return 5
					else
						echo -e "${COLOR_GREEN}Файл ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} существует${COLOR_NC}"
						return 6
					fi
					;;
				*)
					echo -e "${COLOR_GREEN}Ошибка параметров в функции ${COLOR_YELLOW}\"folderExistWithInfo\"${COLOR_NC}"
					return 2;;
	esac
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
	    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"fileExistWithInfo\"${COLOR_RED} ${COLOR_NC}"
	    return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
