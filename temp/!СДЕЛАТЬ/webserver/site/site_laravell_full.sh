#!/bin/bash
#ввод параметров добавления сайта на laravel
source /etc/profile
source ~/.bashrc
#$1-$USERNAME process

clear
echo -e "\n${COLOR_GREEN}Добавление сайта на фреймворке Laravel ${COLOR_NC}"
echo -e "${COLOR_YELLOW}Список имеющихся доменов на сервере: ${COLOR_NC}"
ls $HOMEPATHWEBUSERS/$1
echo ""
echo -n -e "${COLOR_BLUE}Введите домен${COLOR_NC}"
read -p ": " domain
echo ''
	site_path=$HOMEPATHWEBUSERS/$1/$domain    
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
    echo -n -e "Для создания домена ${COLOR_YELLOW} $domain ${COLOR_NC}, пользователя ${COLOR_YELLOW} $1 ${COLOR_NC} в каталоге ${COLOR_YELLOW} $site_path ${COLOR_NC} с конфигурацией apache ${COLOR_YELLOW} \"$apache_config\" ${COLOR_NC} и конфирурацией nginx ${COLOR_YELLOW} \"$nginx_config\" ${COLOR_NC} введите ${COLOR_BLUE}\"y\"${COLOR_NC}, для выхода - любой символ: "
    read item
    case "$item" in
        y|Y) echo
            sudo $SCRIPTS/webserver/site/make/site_laravel_make.sh $1 $domain $1 $site_path $apache_config $nginx_config
            exit 0
            ;;
        *) echo "Выход..."
            exit 0
            ;;
    esac
