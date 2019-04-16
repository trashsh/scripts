#!/bin/bash


############################backups######################
declare -x -f viewBackupsRange
declare -x -f viewBackupsToday
declare -x -f viewBackupsYestoday
declare -x -f viewBackupsWeek
declare -x -f viewBackupsRangeInput
declare -x -f viewUsersInGroupByPartName
declare -x -f viewMysqlAccess


declare -x -f untarFile #разархивация архива по указанному пути: ($1-ссылка на архив ; $2-ссылка на каталог назначения ; $3-mode:rewrite/norewrite ; $4-mode: showinfo/silent; $5 - mode:createfolder/nocreatefolder/querrycreatefolder)


#не проверно
#USERS
#Полностью проверено

#Полностью протестировано

declare -x -f createSite_Laravel #Создание сайта: # $1 - домен ($DOMAIN), $2 - имя пользователя, $3 - путь к папке с сайтом,  $4 - шаблон виртуального хоста apache, $5 - шаблон виртуального хоста nginx

declare -x -f siteAdd_php_temp #:Добавление сайта php $1-$USERNAME process $2 - домен ($DOMAIN), $3 - имя пользователя, $4 - путь к папке с сайтом,  $5 - шаблон виртуального хоста apache, $6 - шаблон виртуального хоста nginx
#


#запрос на добавление сайта laravel
declare -x -f inputSite_Laravel





#####################ПОЛНОСТЬЮ ГОТОВО


#mysql

#backups


declare -x -f dbBackupTable #Создание бэкапа отдельной таблицы: ($1-dbname ; $2-tablename ; $3-В параметре $3 может быть установлен каталог выгрузки. По умолчанию грузится в $BACKUPFOLDER_DAYS\`date +%Y.%m.%d`)


######ПОЛНОСТЬЮ ПРОТЕСТИРОВАНО







#ALLFUNCTIONS




#declare -x -f dbInsertToDbUsers     #Добавление записи в базу mysql-webserver-users
                                    #$1-username ;
                                    #$2-homedir ;

                                    #return 0 - выполнено успешно, 1 - отсутствуют параметры
                                    #2 - отсутствует база данных
                                    #3 - пользователь уже имелся в базе данных mysql
                                    #4 - после попытки создания записи, запись не обнаружена

#Вывод бэкапов за сегодня
#return 0 - выполнено успешно, 1 - каталог не найден
viewBackupsToday(){
	echo ""
	DATE=$(date +%Y.%m.%d)
	if [ -d "$BACKUPFOLDER_DAYS"/"$DATE"/"mysql" ] ; then
		echo -e "${COLOR_YELLOW}"Список бэкапов за сегодня - $DATE" ${COLOR_NC}"
		echo -e "${COLOR_BROWN}"$BACKUPFOLDER_DAYS/$DATE/mysql:" ${COLOR_NC}"
		ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
		return 0
	else
		echo -e "${COLOR_RED}Бэкапы mysql за $(date --date today "+%Y.%m.%d") отсутствуют${COLOR_NC}"
		return 1
	fi
}

#Вывод бэкапов за вчерашний день
#return 0 - выполнено успешно, 1 - каталог не найден
viewBackupsYestoday(){
	echo ""
	DATE=$(date --date yesterday "+%Y.%m.%d")
	 if [ -d "$BACKUPFOLDER_DAYS"/"$DATE"/"mysql" ] ; then
		echo -e "${COLOR_YELLOW}"Список бэкапов за сегодня - $DATE" ${COLOR_NC}"
		echo -e "${COLOR_BROWN}"$BACKUPFOLDER_DAYS/$DATE/mysql:" ${COLOR_NC}"
		ls -l $BACKUPFOLDER_DAYS/$DATE/mysql
		return 0
	else
		echo -e "${COLOR_RED}Бэкапы mysql за $(date --date yesterday "+%Y.%m.%d") отсутствуют${COLOR_NC}"
		return 1
	fi
}

#Вывод бэкапов за последнюю неделю
#return 0 - выполнено успешно, 1 - каталог не найден
viewBackupsWeek(){
	echo ""
	TODAY=$(date +%Y.%m.%d)
	DATE=$(date --date='7 days ago' "+%Y.%m.%d")
	echo -e "${COLOR_YELLOW}"Список бэкапов за Неделю - $DATE-$TODAY" ${COLOR_NC}"

	for ((i=0; i<7; i++))
	do
		DATE=$(date --date=''$i' days ago' "+%Y.%m.%d");
		if [ -d "$BACKUPFOLDER_DAYS"/"$DATE" ] ; then
			echo -e "$COLOR_BROWN"$DATE:" ${COLOR_NC}"
			ls -l $BACKUPFOLDER_DAYS/$DATE/
			return 0
		else
		    echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$BACKUPFOLDER_DAYS/$DATE/\"${COLOR_RED}не найден${COLOR_NC}"
		    return 1
		fi
	done
}


#Вывод бэкапов за указанный диапазон дат ($1-date1, $2-data2)
#return 0 - выполнено, 1 - отсутствуют параметры
viewBackupsRangeInput(){
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ] && [ -n "$2" ]
    then
    #Параметры запуска существуют
        echo -e "${COLOR_YELLOW}"Список бэкапов $(date --date $1 "+%Y.%m.%d") - $(date --date $2 "+%Y.%m.%d")" ${COLOR_NC}"
        start_ts=$(date -d "$1" '+%s')
        end_ts=$(date -d "$2" '+%s')
        range=$(( ( end_ts - start_ts )/(60*60*24) ))
        echo -e "$COLOR_BROWN" Базы данных mysql:" ${COLOR_NC}"
        n=0
        for ((i=0; i<${range#-}+1; i++))
        do
            DATE=$(date --date=''$i' days ago' "+%Y.%m.%d");
            if [ -d "$BACKUPFOLDER_DAYS"/"$DATE" ] ; then
                echo -e "$COLOR_BROWN"$DATE:" ${COLOR_NC}"
                ls -l $BACKUPFOLDER_DAYS/$DATE/
                n=$(($n+1))

            fi

        done
        echo $n
        return 0
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewBackupsRangeInput\"${COLOR_RED} ${COLOR_NC}"
        return 1
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта

}

#Вывод бэкапов конкретный день ($1-DATE)
viewBackupsRange(){
#Проверка на существование параметров запуска скрипта
#return 0 - выполнено успешно, 1 - отсутствуют параметры
#2 - бэкапы за указанный диапазон отсутствуют
if [ -n "$1" ]
then
#Параметры запуска существуют
    echo ''
    if [ -d "$BACKUPFOLDER_DAYS"/"$1"/ ] ; then
        echo -e "${COLOR_YELLOW}"Список бэкапов $(date --date $1 "+%Y.%m.%d")" ${COLOR_NC}"
        echo -e "$COLOR_BROWN"$1 - Базы данных mysql:" ${COLOR_NC}"
        ls -l $BACKUPFOLDER_DAYS/$1/
        return 0
    else
        echo -e "${COLOR_RED}Бэкапы за $(date --date $1 "+%Y.%m.%d") отсутствуют${COLOR_NC}"
        return 2
    fi
#Параметры запуска существуют (конец)
else
#Параметры запуска отсутствуют
    echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewBackupsRange\"${COLOR_RED} ${COLOR_NC}"
    return 1
#Параметры запуска отсутствуют (конец)
fi
#Конец проверки существования параметров запуска скрипта
}



#разархивация архива по указанному пути
#$1-ссылка на архив ; $2-ссылка на каталог назначения ; $3-mode:rewrite/norewrite ; $4-mode: showinfo/silent ; $5 - mode:createfolder/nocreatefolder/querrycreatefolder; $6 - mode:structure/nostructure
#return 0 - выполнено успешно, 1 - параметры не переданы, 2 - нет архива, 3 - ошибка параметра mode (createfolder/nocreatefolder/querrycreatefolder)
#4 - каталог назначения не существует при параметре nocreatefolder, 5 - ошибка параметра mode (showinfo/silent),
#6 - ошибка параметра mode (rewrite/norewrite), 7 - ошибка параметра mode (structure/nostructure), 8 - пользователем отменена операция создания каталога $2
untarFile() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ]
	then
	#Параметры запуска существуют
		#Проверка существования файла "$1"
		if [ -f $1 ] ; then
		    #Файл "$1" существует
		    case "$5" in
		        createfolder)
                    #Проверка существования каталога "$2"
                    if ! [ -d $2 ] ; then
                        #Каталог "$2" не существует
                        mkdir -p $2
                        #Каталог "$2" не существует (конец)
                    fi
                    #Конец проверки существования каталога "$2"
		            ;;
		        nocreatefolder)
                    #Проверка существования каталога "$2"
                    if ! [ -d $2 ] ; then
                        #Каталог не "$2" существует
                        echo -e "${COLOR_RED}Каталог ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"untarFile\"${COLOR_NC}"
                        #Каталог не "$2" существует (конец)
                        return 4
                    fi
                    #Конец проверки существования каталога "$2"

		            ;;
		        querrycreatefolder)
		            #Проверка существования каталога "$2"
                    if ! [ -d $2 ] ; then
                        echo -e "${COLOR_YELLOW}Каталог ${COLOR_GREEN}\"$2\"${COLOR_YELLOW} не существует${COLOR_NC}"
                        echo -n -e "${COLOR_YELLOW}Введите ${COLOR_BLUE}\"y\"${COLOR_NC}${COLOR_YELLOW} для создания каталога  ${COLOR_GREEN}\"$2\"${COLOR_NC}${COLOR_YELLOW}, для отмены операции - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
                            while read
                            do
                                echo -n ": "
                                case "$REPLY" in
                                    y|Y)
                                        mkdir -p $2;
                                        break;;
                                    n|N)
                                        echo -e "${COLOR_RED}Создание каталога ${COLOR_GREEN}\"$2\"${COLOR_RED} отменено пользователем при распаковке архива ${COLOR_GREEN}\"$1\"${COLOR_NC}";
                                        return 9;;
                                esac
                            done
                    fi
                    #Конец проверки существования каталога "$2"

		            ;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (createfolder/nocreatefolder/querrycreatefolder)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
		    	    return 3
		    	    ;;
		    esac
		    #Файл "$1" существует (конец)

		    case "$6" in
		        structure)
                        case "$4" in
                            showinfo)
                                case "$3" in
                                    rewrite)
                                        tar -xzpf $1 -P -C $2 && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xzkpf $1 -P -C $2 && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            silent)
                                case "$3" in
                                    rewrite)
                                        tar -xzpf $1 -P -C $2;
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xzkpf $1 -P -C $2;
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            *)
                                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (showinfo/silent)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                return 5
                                ;;
                        esac
		            ;;
		        nostructure)
                        case "$4" in
                            showinfo)
                                case "$3" in
                                    rewrite)
                                        tar -xpf $1 --strip-components 1 -P -C $2 && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xpkf $1 --strip-components 1 -P -C $2  && echo -e "${COLOR_GREEN}Архив ${COLOR_YELLOW}\"$1\"${COLOR_GREEN} успешно распакован в каталог ${COLOR_YELLOW}\"$2\"${COLOR_GREEN}  ${COLOR_NC}";
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            silent)
                                case "$3" in
                                    rewrite)
                                        tar -xpf $1 --strip-components 1 -P -C $2;
                                        return 0
                                        ;;
                                    norewrite)
                                        tar -xpkf $1 --strip-components 1 -P -C $2;
                                        return 0
                                        ;;
                                    *)
                                        echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (rewrite/norewrite)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                        return 6
                                        ;;
                                esac
                                ;;
                            *)
                                echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (showinfo/silent)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
                                return 5
                                ;;
                        esac
		            ;;
		    	*)
		    	    echo -e "${COLOR_RED}Ошибка передачи параметра ${COLOR_GREEN}\"mode (structure/nosctucture)\"${COLOR_RED} в функцию ${COLOR_GREEN}\"untarFile\"${COLOR_NC}";
		    	    return 7
		    	    ;;
		    esac
		else
		    #Файл "$1" не существует
		    echo -e "${COLOR_RED}Файл ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"untarFile\"${COLOR_NC}"
		    return 2
		    #Файл "$1" не существует (конец)
		fi
		#Конец проверки существования файла "$1"

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"untarFile\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}


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
    echo -n -e "${COLOR_YELLOW}Для запуска главного введите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода введите ${COLOR_BLUE}\"n\"${COLOR_NC}:"
fi

	#Конец проверки существования параметров запуска скрипта
}




#Добавление сайта. Тип - php
#$1-username process ; $2- домен ($DOMAIN) ; $3-имя пользователя ; $4-путь к папке с сайтом ; $5- шаблон виртуального хоста apache; $6-шаблон виртуального хоста nginx
siteAdd_php_temp() {
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





#запрос на добавление сайта laravel
#$1 - whoami
#return 0 - выполнено успешно, 1 - пользователя $username не существует
inputSite_Laravel() {
    #Проверка на существование параметров запуска скрипта
    if [ -n "$1" ]
    then
    #Параметры запуска существуют
        username=$1
    #Параметры запуска существуют (конец)
    else
    #Параметры запуска отсутствуют
        read -p "Введите имя пользователя, от чьего имени будет запущен скрипт: " username
    #Параметры запуска отсутствуют (конец)
    fi
    #Конец проверки существования параметров запуска скрипта

    #Проверка существования системного пользователя "$username"
    	grep "^$username:" /etc/passwd >/dev/null
    	if  [ $? -eq 0 ]
    	then
    	#Пользователь $username существует
                echo -e "\n${COLOR_GREEN}Добавление сайта на фреймворке Laravel ${COLOR_NC}"
                echo -e "${COLOR_YELLOW}Список имеющихся доменов на сервере: ${COLOR_NC}"
                ls $HOMEPATHWEBUSERS/$username
                echo ""
                echo -n -e "${COLOR_BLUE}Введите домен${COLOR_NC}"
                read -p ": " domain
                echo ''
                site_path=$HOMEPATHWEBUSERS/$username/$domain
                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache: ${COLOR_NC}"
                ls $TEMPLATES/apache2/
                echo -n -e "${COLOR_BLUE}Введите название конфигурации apache: ${COLOR_NC}"
                read apache_config
                echo ''
                echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx: ${COLOR_NC}"
                ls $TEMPLATES/nginx/
                echo -n -e "${COLOR_BLUE}Введите название конфигурации nginx: ${COLOR_NC}"
                read nginx_config
                echo ''
                echo -n -e "Для создания домена ${COLOR_YELLOW} $domain ${COLOR_NC}, пользователя ${COLOR_YELLOW} $username ${COLOR_NC} в каталоге ${COLOR_YELLOW} $site_path ${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW} \"$apache_config\" ${COLOR_NC} и конфирурацией nginx ${COLOR_YELLOW} \"$nginx_config\" ${COLOR_NC} введите ${COLOR_BLUE}\"y\"${COLOR_NC}, для выхода - любой символ: "
                read item
                case "$item" in
                    y|Y) echo
                        createSite_Laravel $domain $username $site_path $apache_config $nginx_config
                        exit 0
                        ;;
                    *) echo "Выход..."
                        exit 0
                        ;;
                esac
    	#Пользователь $username существует (конец)
    	else
    	#Пользователь $username не существует
    	    echo -e "\n${COLOR_RED}Пользователь ${COLOR_GREEN}\"$username\"${COLOR_RED} не существует. Выполнение скрипта ${COLOR_GREEN}\"inputSite_Laravel\" остановлено${COLOR_NC}"
    	    viewGroupUsersAccessAll "Полный перечень пользователей системы:"
            return 1
    	#Пользователь $username не существует (конец)
    	fi
    #Конец проверки существования системного пользователя $username



}



######################################разобраться потом
#Вывод списка пользователей, входящих в группу $2 по части имени пользователя $1
#$1-часть имени ; $2 - название группы
#return 0 - выполнено успешно,  1- отсутствуют параметры, 2 - группа не существует
viewUsersInGroupByPartName() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ]
	then
	#Параметры запуска существуют

		#Проверка существования системной группы пользователей "$2"
		if grep -q $2: /etc/group
		    then
		        #Группа "$2" существует
		         echo -e "\n${COLOR_YELLOW}Список пользователей группы \"$2\", содержащих в имени \"$1\"${COLOR_NC}"
		         more /etc/group | grep -E "$2.*$1" | highlight green "$1" | highlight magenta "$2"
	             return 0
		        #Группа "$2" существует (конец)
		    else
		        #Группа "$2" не существует
		        echo -e "${COLOR_RED}Группа ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует${COLOR_NC}"
				return 2
				#Группа "$2" не существует (конец)
		    fi
		#Конец проверки существования системного пользователя $2

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewUsersInGroupByPartName\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}

#отобразить реквизиты доступа к серверу MYSQL
###input
#$1 - user
###return
#0 - выполнено успешно,
#1 - не переданы параметры,
#2 - файл my.cnf не найден
viewMysqlAccess(){
	if [ -n "$1" ]
	then
		echo -e "${COLOR_YELLOW}"Реквизиты PHPMYADMIN" ${COLOR_NC}"
		echo -e "Пользователь: ${COLOR_YELLOW}" $1 "${COLOR_NC}"
		echo -e "Сервер: ${COLOR_YELLOW}" http://$CONFSUBDOMAIN/$PHPMYADMINFOLDER "${COLOR_NC}"
		echo -e "\n${COLOR_YELLOW}Пользователь MySQL:${COLOR_NC}"
		if [ -f $HOMEPATHWEBUSERS/$1/.my.cnf ] ;  then
            cat $HOMEPATHWEBUSERS/$1/.my.cnf
            return 0
		else
		    echo -e "${COLOR_RED}Файл $HOMEPATHWEBUSERS/$1/.my.cnf не существует${COLOR_NC}"
		    return 2
        fi
		echo $LINE

	else
		echo -e "${COLOR_RED}Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"viewMysqlAccess\"${COLOR_RED} ${COLOR_NC}"
		return 1
	fi
}






#Добавление записи в базу о добавлении пользователя
###input
#$1-user ;
#$2-homedir ;
#$3-created_by ;
#$4-userType (1-system, 2-ftp)
###return
#0 - выполнено успешно
#1 - не переданы параметры в функцию
dbRecordAdd_addUser() {
	#Проверка на существование параметров запуска скрипта
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]  && [ -n "$4" ]
	then
	#Параметры запуска существуют

		#mysql-добавление информации о пользователе
    datetime=`date +%Y-%m-%d\ %H:%M:%S`
    dbAddRecordToDb $WEBSERVER_DB users username $1 insert
    dbUpdateRecordToDb $WEBSERVER_DB users username $1 homedir $2 update
    dbUpdateRecordToDb $WEBSERVER_DB users username $1 created "$datetime" update
    dbUpdateRecordToDb $WEBSERVER_DB users username $1 created_by "$3" update
    dbUpdateRecordToDb $WEBSERVER_DB users username $1 isAdminAccess 0 update
    dbUpdateRecordToDb $WEBSERVER_DB users username $1 isFtpAccess 1 update
    dbUpdateRecordToDb $WEBSERVER_DB users username $1 userType $4 update

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbRecordAdd_addUser\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}



#добавление записи в таблицу
###!ПОЛНОСТЬЮ ГОТОВО. 02.04.2019
###input:
#$1-dbname ;
#$2-table;
#$3 - столбец для вставки;
#$4 - текст вставки;
#$5-подтверждение "insert"
###return
#0 - выполнено успешно
#1 - отсутствуют параметры запуска
#2 - не существует база данных $2
#3 - таблица не существует
#4 - столбец не существует для поиска
#5  - отсутствует подтверждение
dbAddRecordToDb() {
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

                                				 case "$5" in
                                                        insert)
                                                            mysql -e "INSERT INTO $1.$2 ($3) VALUES ('$4');"
                                                            return 0
                                                            ;;
                                                        *)
                                                            echo -e "${COLOR_RED}Ошибка передачи подтверждения в функцию ${COLOR_GREEN}\"dbAddRecordToDb\"${COLOR_NC}"
                                                            return 5
                                                            ;;
                                                    esac


                        	#столбец $2 существует (конец)
                        	else
                        	#столбец $2 не существует

                        	    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$2\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$3\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbAddRecordToDb\" ${COLOR_NC}"
                        	    return 4
                        	#столбец $2 не существует (конец)
                        fi
                        #Проверка существования столбца $3 в таблице $2 (конец)
					#таблица $2 существует (конец)
					else
					#таблица $2 не существует
					     echo -e "${COLOR_RED}Таблица ${COLOR_GREEN}\"$2\"${COLOR_RED} в базе данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbAddRecordToDb\" ${COLOR_NC}"
					     return 3
					#таблица $2 не существует (конец)
				fi
				#Проверка существования таблицы в базе денных $1 (конец)
			#база $1 - существует (конец)
			else
			#база $1 - не существует
			     echo -e "${COLOR_RED}База данных ${COLOR_GREEN}\"$1\"${COLOR_RED} не существует. Ошибка выполнения функции ${COLOR_GREEN}\"dbAddRecordToDb\" ${COLOR_NC}"
			     return 2
			#база $1 - не существует (конец)
		fi
		#конец проверки существования базы данных $1


	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbAddRecordToDb\"${COLOR_RED} ${COLOR_NC}"
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
    #dbAddRecordToDb $WEBSERVER_DB db_users username $1 insert
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



declare -x -f dbUpdateRecordToDb
#обновление записи в таблице
###input:
#$1-dbname ;
#$2-table;
#$3 - столбец для поиска;
#$4 - текст для поиска;
#$5 - обновляемый столбец,
#$6 - вставляемый текст,
#$7-подтверждение "update"
###return
#0 - выполнено успешно
#1 - отсутствуют параметры запуска
#2 - не существует база данных $2
#3 - таблица не существует
#4 - столбец не существует для поиска
#5 - запись отсутствует
#6  - отсутствует подтверждение
#7 - отсутствует столбец для вставки текста
dbUpdateRecordToDb() {
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
                                		#Проверка существования столбца $5 в таблице $2
                                		if [[ ! -z "`mysql -qfsBe "SELECT '$5' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$2'" 2>&1`" ]];
                                			then
                                			#столбец $5 существует
                                				 case "$7" in
                                                        update)
                                                            mysql -e "UPDATE $1.$2 SET $5='$6' where $3='$4';"
                                                            return 0
                                                            ;;
                                                        *)
                                                            echo -e "${COLOR_RED}Ошибка передачи подтверждения в функцию ${COLOR_GREEN}\"dbUpdateRecordToDb\"${COLOR_NC}"
                                                            return 6
                                                            ;;
                                                    esac
                                			#столбец $5 существует (конец)
                                			else
                                			#столбец $5 не существует
                                			    echo -e "${COLOR_RED}Столбец ${COLOR_GREEN}\"$5\"${COLOR_RED} в таблице ${COLOR_GREEN}\"$2\"${COLOR_RED} не существует.Ошибка выполнения функции ${COLOR_GREEN}\"dbUpdateRecordToDb\" ${COLOR_NC}"
                                			    return 7
                                			#столбец $5 не существует (конец)
                                		fi
                                		#Проверка существования столбца $5 в таблице $2 (конец)

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

	#Параметры запуска существуют (конец)
	else
	#Параметры запуска отсутствуют
		echo -e "${COLOR_RED} Отсутствуют необходимые параметры в функции ${COLOR_GREEN}\"dbRecordAdd_addBase\"${COLOR_RED} ${COLOR_NC}"
		return 1
	#Параметры запуска отсутствуют (конец)
	fi
	#Конец проверки существования параметров запуска скрипта
}
