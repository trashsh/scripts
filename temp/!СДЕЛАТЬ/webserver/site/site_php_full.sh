#!/bin/bash
#ввод параметров добавления сайта php/html
source /etc/profile
source ~/.bashrc
#$1-$USERNAME process

#Ввод параметров сайта для добавления виртуального хоста
	
    echo "--------------------------------------"
    echo "Добавление виртуального хоста."
	if ! [ -d $HOMEPATHWEBUSERS/$1/ ]; then
		sudo mkdir -p $HOMEPATHWEBUSERS/$1
	fi
	
    echo -e "${COLOR_YELLOW}Список имеющихся доменов:${COLOR_NC}"	

    ls $HOMEPATHWEBUSERS/$1
    echo -n -e "${COLOR_BLUE} Введите домен для добавления ${COLOR_NC}: "
    read domain
	site_path=$HOMEPATHWEBUSERS/$1/$domain
	echo ''
    echo -e "${COLOR_YELLOW}Возможные варианты шаблонов apache:${COLOR_NC}"

    ls $TEMPLATES/apache2/
    echo -e "${COLOR_BLUE}Введите название конфигурации apache (включая расширение):${COLOR_NC}"
	echo -n ": "
    read apache_config
    echo ''
    echo -e "${COLOR_YELLOW}Возможные варианты шаблонов nginx:${COLOR_NC}"
    ls $TEMPLATES/nginx/
    echo -e "${COLOR_BLUE}Введите название конфигурации nginx (включая расширение):${COLOR_NC}"
	echo -n ": "
    read nginx_config
    echo ''
	echo -e "Для создания домена ${COLOR_YELLOW}\"$domain\"${COLOR_NC}, пользователя ftp ${COLOR_YELLOW}\"$1_$domain\"${COLOR_NC} в каталоге ${COLOR_YELLOW}\"$site_path\"${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW}\"$apache_config\"\033[0;39m и конфирурацией nginx ${COLOR_YELLOW}\"$nginx_config\"${COLOR_NC} введите ${COLOR_BLUE}\"y\" ${COLOR_NC}, для выхода - любой символ: "
    echo -n ": "
    read item
    case "$item" in
        y|Y) echo
            sudo $SCRIPTS/webserver/site/make/site_php_make.sh $1 $domain $1 $site_path $apache_config $nginx_config
            exit 0
            ;;
        *) echo "Выход..."
            exit 0
            ;;
    esac
