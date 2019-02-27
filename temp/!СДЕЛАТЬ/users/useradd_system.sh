#!/bin/bash
# $1-username process;
source /etc/profile
source ~/.bashrc
source $SCRIPTS/info/users_info/users_info.sh


viewGroupUsersAccessAll
echo ''
echo -e "$COLOR_YELLOW"Создание системного пользователя " $COLOR_NC"
read -p "Введите имя пользователя: " username

echo -n -e "Для добавления системного пользователя $COLOR_YELLOW" $username "$COLOR_NC введите $COLOR_BLUE\"y\"$COLOR_NC, для выхода - любой символ: "
    read item
    case "$item" in
        y|Y) 		
		$SCRIPTS/users/make/useradd_system.sh $1 $username
		$SCRIPTS/users/make/useradd_sudo.sh $1 $username
		$SCRIPTS/users/make/keyssh_user_new_add.sh $1 $username
		cat $SETTINGS/ssh/keys/lamer >> $HOMEPATHWEBUSERS/$username/.ssh/authorized_keys
		$SCRIPTS/users/make/useradd_mysql.sh $1 $username
		
		$SCRIPTS/info/site_info/show_ssh.sh $1 $username
		$SCRIPTS/info/site_info/show_ftp.sh $1 $username
		$SCRIPTS/info/site_info/show_mysql.sh $1 $username
		$MENU/user.sh $1
		break
            ;;
        *) echo 'Отмена операции добавления пользователя'
			echo ''
            ;;
    esac



