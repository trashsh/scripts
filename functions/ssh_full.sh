#!/bin/bash

declare -x -f sshKeyAddToUser
#Добавление существующего ключа $2 пользователю $1
###!Полностью готово. Не трогать больше
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
                                    # echo -e "\n${COLOR_YELLOW} Импорт ключа ${COLOR_LIGHT_PURPLE}\"$3\"${COLOR_YELLOW} пользователю ${COLOR_LIGHT_PURPLE}\"$1\"${COLOR_YELLOW} выполнен${COLOR_NC}"
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

