#!/bin/bash

declare -x -f useradd_test #user: ($1-domain)
#user
###input
#$1-domain ;
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
useradd_test() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют
         userAddSystem $1 $HOMEPATHWEBUSERS/$1 "/bin/bash" users 123  $1
                                #input_userAddToGroupSudo $1 $username
                                userAddToGroupSudo $1
                                sshKeyImport $1
                                sshKeyAddToUser $1 users $SETTINGS/ssh/keys/lamer $HOMEPATHWEBUSERS/$1
                                dbUseradd $1 123 localhost pass admin
                                 #Проверка существования файла ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt"
                if [ -f "$HOMEPATHWEBUSERS"/"$1"/.myconfig/info.txt ] ; then
                    #Файл ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt" существует
                    viewAccessDetail $1 full_info
                    #Файл ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt" существует (конец)
                fi
                #Конец проверки существования файла ""$HOMEPATHWEBUSERS"/"$username"/.myconfig/info.txt"
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"useradd_test\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта

}