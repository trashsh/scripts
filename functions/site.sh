#!/bin/bash
#Функции mysql
source $SCRIPTS/functions/archive.sh
source $SCRIPTS/functions/mysql.sh


#Полностью протестировано
declare -x -f mkdirWithOwn #Создание папки и применение ей владельца и прав доступа: ($1-путь к папке ; $2-user ; $3-group ; $4-разрешения )
                                #return 1 - не переданы параметры, 2 - пользователь не существует, 3 - группа не существует
declare -x -f chOwnFolderAndFiles #Смена владельца на файлы в папке и саму папку: ($1-path; $2-user; $3-group)
                    #return 0 - выполнено успешно, 1 - каталог не существует, 2 - пользователь не существует, 3 - группа не существует
declare -x -f chModAndOwnFolderAndFiles #Смена разрешений на каталог и файлы, а также владельца: ($1-путь к каталогу; $2-права на каталог ; $3-Права на файлы ; $4-Владелец-user ; $5-Владелец-группа ;)
                            #return 0 - выполнено успешно, 1 - отсутствуют параметры запуска,
                            #2 - не существует каталог, 3 - не существует пользователь, 4 - не существует группа
declare -x -f chModAndOwnFile #Смена владельна и прав доступа на файл: ($1-путь к файлу ; $2-user ; $3-group ; $4-права доступа на файл ;)
                                #$1-путь к файлу ; $2-user ; $3-group ; $4-права доступа на файл ;
                                #return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - отсутствует файл
                                #3 - отсутствует пользователь, #4 - отсутствует группа



declare -x -f touchFileWithModAndOwn    #создание файла и применение прав к нему и владельца: #$1-путь к файлу ; $2-user ; $3-group ; $4-права доступ ;
                                        #return 0 - выполнено успешно, 1 - файл существовал, применены лишь права, 2 - пользователь не существует, 3 - группа не существует

declare -x -f createSite_Laravel #Создание сайта: # $1 - домен ($DOMAIN), $2 - имя пользователя, $3 - путь к папке с сайтом,  $4 - шаблон виртуального хоста apache, $5 - шаблон виртуального хоста nginx

declare -x -f addSite_php #:Добавление сайта php $1-$USERNAME process $2 - домен ($DOMAIN), $3 - имя пользователя, $4 - путь к папке с сайтом,  $5 - шаблон виртуального хоста apache, $6 - шаблон виртуального хоста nginx
#

#Создание сайта
# $1 - домен ($DOMAIN), $2 - имя пользователя, $3 - путь к папке с сайтом,  $4 - шаблон виртуального хоста apache, $5 - шаблон виртуального хоста nginx
createSite_Laravel() {
	#Проверка на существование параметров запуска скрипта
if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]
then

        cd $HOMEPATHWEBUSERS/$2
        composer create-project --prefer-dist laravel/laravel $1

        #make user
        echo "Добавление веб пользователя $2_$1 с домашним каталогом: $3 для домена $1"
        sudo mkdir -p $3
        sudo useradd $2_$1 -N -d $3 -m -s /bin/false -g ftp-access -G www-data
        #sudo adduser $2_$1 www-data
        sudo passwd $2_$1
        sudo cp /etc/skel/* $3
        sudo rm -rf $3/public_html

		cd $3
		cp -a $3/.env.example $3/.env
		php artisan key:generate
		php artisan config:cache


       #nginx
       sudo cp -rf $TEMPLATES/nginx/$5 /etc/nginx/sites-available/$2_$1.conf
       sudo echo "Замена переменных в файле /etc/nginx/sites-available/$2_$1.conf"
       sudo grep '#__DOMAIN' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/#__DOMAIN/'$1'/g' /etc/nginx/sites-available/$2_$1.conf
	   sudo grep '#__USER' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/#__USER/'$2'/g' /etc/nginx/sites-available/$2_$1.conf
       sudo grep '#__PORT' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/#__PORT/'$HTTPNGINXPORT'/g' /etc/nginx/sites-available/$2_$1.conf
       sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/nginx/sites-available/$2_$1.conf | xargs sed -i 's/'#__HOMEPATHWEBUSERS'/\/home\/webusers/g' /etc/nginx/sites-available/$2_$1.conf

       sudo ln -s /etc/nginx/sites-available/$2_$1.conf /etc/nginx/sites-enabled/$2_$1.conf
       sudo systemctl reload nginx

        #apache2
       sudo cp -rf $TEMPLATES/apache2/$4 /etc/apache2/sites-available/$2_$1.conf
       sudo grep '#__DOMAIN' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__DOMAIN/'$1'/g' /etc/apache2/sites-available/$2_$1.conf
	   sudo grep '#__USER' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__USER/'$2'/g' /etc/apache2/sites-available/$2_$1.conf
       sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__HOMEPATHWEBUSERS/\/home\/webusers/g' /etc/apache2/sites-available/$2_$1.conf
       sudo grep '#__PORT' -P -R -I -l  /etc/apache2/sites-available/$2_$1.conf | xargs sed -i 's/#__PORT/'$HTTPAPACHEPORT'/g' /etc/apache2/sites-available/$2_$1.conf

       sudo a2ensite $2_$1.conf
       sudo systemctl reload apache2

	   cp -rf $TEMPLATES/laravel/.gitignore $3/.gitignore

       echo -e "\033[32m" Применение прав к папкам и каталогам. Немного подождите "\033[0;39m"

        #chmod
       sudo find $3 -type d -exec chmod 755 {} \;
       sudo find $3/public -type d -exec chmod 755 {} \;
       sudo find $3 -type f -exec chmod 644 {} \;
       sudo find $3/public -type f -exec chmod 644 {} \;
       sudo find $3/logs -type f -exec chmod 644 {} \;
	   sudo find $3 -type d -exec chown $2:www-data {} \;
	   sudo find $3 -type f -exec chown $2:www-data {} \;

       sudo chown -R $2:www-data $3/logs
       sudo chown -R $2:www-data $3/public
       sudo chown -R $2:www-data $3/tmp


       sudo chmod 777 $3/bootstrap/cache -R
       sudo chmod 777 $3/storage -R

	   cd $3
		echo -e "\033[32m" Инициализация Git "\033[0;39m"
	    git init
		git add .
		git commit -m "initial commit"

else
    echo "Возможные варианты шаблонов apache:"
    ls $TEMPLATES/apache2/
    echo "Возможные варианты шаблонов nginx:"
    ls $TEMPLATES/nginx/
    echo "--------------------------------------"
    echo "Параметры запуска не найдены. Необходимы параметры: домен, имя пользователя,путь к папке с сайтом,название шаблона apache,название шаблона nginx."
    echo "Например $0 domain.ru user /home/webusers/domain.ru php.conf php.conf"
    FileParamsNotFound "$2" "Для запуска главного введите" "$SCRIPTS/menu"
fi

	#Конец проверки существования параметров запуска скрипта
}



#Смена владельна и прав доступа на файл
#$1-путь к файлу ; $2-user ; $3-group ; $4-права доступа на файл ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры, 2 - отсутствует файл
#3 - отсутствует пользователь, #4 - отсутствует группа
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
		    		            chmod $4 $1
				                chown $2:$3 $1
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
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует${COLOR_NC}"
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


#Создание папки и применение ей владельца и прав доступа
#$1-путь к папке ; $2-user ; $3-group ; $4-разрешения ;
#return 1 - не переданы параметры, 2 - пользователь не существует, 3 - группа не существует
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
		    		            mkdir -p $1
		    		            chmod $4 $1
				                chown $2:$3 $1
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
		    	    echo -e "\n${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"mkdirWithOwn\"${COLOR_NC}"
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
         				find $1 -type d -exec chmod $3 {} \;
                        find $1 -type f -exec chmod $3 {} \;
                        find $1 -type d -exec chown $4:$5 {} \;
                        find $1 -type f -exec chown $4:$5 {} \;
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



#Смена владельца на файлы в папке и папку
#$1-path ; $2-user; $3-group
#return 0 - выполнено успешно, 1 - каталог не существует, 2 - пользователь не существует, 3 - группа не существует
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
         	    echo -e "${COLOR_RED}Пользователь ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует${COLOR_NC}"
         		return 1
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





#создание файла и применение прав к нему и владельца
#$1-путь к файлу ; $2-user ; $3-group ; $4-права доступ ;
#return 0 - выполнено успешно, 1 - отсутствуют параметры запуска, 2 - пользователь не существует, 3 - группа не существует, 4 - файл существовал, применены лишь права
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
		    			    #Проверка существования файла "$1"
                            if [ -f $1 ] ; then
                                #Файл "$1" уже существует. Применяются просто права доступа
                                chmod $4 $1
		    			        chown $2:$3 $1
		    			        return 4
                                #Файл "$1" существует. Применяются просто права доступа (конец)
                            else
                                #Файл "$1" не существует
                                    touch $1
                                    chmod $4 $1
		    			            chown $2:$3 $1
		    			            return 0
                                #Файл "$1" не существует (конец)
                            fi
                            #Конец проверки существования файла "$1"

т
		    			    else
		    			        #Группа "$3" не существует
		    			        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"touchFileWithModAndOwn\"${COLOR_NC}"
		    					return 3
		    					#Группа "$3" не существует (конец)
		    			    fi
		    			#Конец проверки существования системного пользователя $3

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




declare -x -f siteAdd_php #Добавление сайта. Тип - php: ($1-username process ; $2- домен ($DOMAIN) ; $3-имя пользователя ; $4-путь к папке с сайтом ; $5- шаблон виртуального хоста apache; $6-шаблон виртуального хоста nginx)
#Добавление сайта. Тип - php
#$1-username process ; $2- домен ($DOMAIN) ; $3-имя пользователя ; $4-путь к папке с сайтом ; $5- шаблон виртуального хоста apache; $6-шаблон виртуального хоста nginx
siteAdd_php() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ]  && [ -n "$6" ]
	then
	#Параметры запуска существуют
		echo " "
	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"siteAdd_php\"${COLOR_RED} ${COLOR_NC}"
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта    
}





