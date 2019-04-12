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
	   	        echo $2 >> $1
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
