#!/bin/bash
#создать веб-пользователя
source /etc/profile
source ~/.bashrc
#$1-$USERNAME

read -p "Введите домен: " DOMAIN
read -p "Введите имя пользователя: " MYUSER
site_path=$HOMEPATHWEBUSERS/$MYUSER/$DOMAIN


    echo "Добавление веб пользователя $MYUSER с домашним каталогом: $site_path для домена $DOMAIN"	
	mkdir -p $site_path
    useradd $MYUSER -N -d $site_path -m -s /bin/false
	passwd $MYUSER
    adduser $MYUSER www-data
    cp -R /etc/skel/* $site_path

    find $site_path -type d -exec chmod 755 {} \;
    find $site_path/public_html -type d -exec chmod 755 {} \;
    find $site_path -type f -exec chmod 644 {} \;
    find $site_path/public_html -type f -exec chmod 644 {} \;
	
	sudo chown -R $MYUSER:users $site_path			
    sudo chown -R $MYUSER:www-data $site_path/public_html
	sudo $SCRIPTS/users/make/mysql.sh $1 $MYUSER

    
	$SCRIPTS/users/make/showinfo_ssh.sh $1 $MYUSER
	$SCRIPTS/users/make/showinfo_ftp.sh $1 $MYUSER
	$SCRIPTS/users/make/showinfo_mysql.sh $1 $MYUSER