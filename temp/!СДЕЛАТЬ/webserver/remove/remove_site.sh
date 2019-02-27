#!/bin/bash
#ввод параметров удаляемого сайта
#$1-$USERNAME process
source /etc/profile
source ~/.bashrc
#Ввод параметров сайта для удаления
    echo "--------------------------------------"
    echo "Удаление виртуального хоста:"
    echo "Список имеющихся доменов для пользователя $1:"
    ls $HOMEPATHWEBUSERS/$1
	echo ''
    echo -n "Введите домен для удаления: "
    read domain
	path=$HOMEPATHWEBUSERS/$1/$domain
	echo ''
#    echo "Список имеющихся пользователей:"
#    getent group www-data
#	echo ''
    
    sudo $SCRIPTS/webserver/remove/make/remove_site_make.sh $1 $domain $path $1

