#!/bin/bash
source /etc/profile
source ~/.bashrc

# $1-username process;

echo -e "\n${COLOR_GREEN}Добавление Пользователя в базу данных MySQL:${COLOR_NC}"

echo -e "${COLOR_YELLOW}Перечень пользователей mysql ${COLOR_YELLOW}"
mysql -e "SELECT User,Host FROM mysql.user;"

echo -n -e "${COLOR_BLUE}Введите имя нового пользователя mysql: ${COLOR_NC}"
read -p  ": " user

echo -n -e "${COLOR_BLUE}Введите пароль для пользователя $user: ${COLOR_NC}"
read  pass

echo ''
    echo -n -e "Для создания пользователя ${COLOR_YELLOW} $user ${COLOR_NC} c паролем ${COLOR_YELLOW} $pass ${COLOR_NC} введите ${COLOR_BLUE}\"y\"${COLOR_NC}, для выхода - любой символ: "
    read item
    case "$item" in
        y|Y) echo
            sudo $SCRIPTS/mysql/make/useradd_make.sh $1 $USER_$user $pass
			echo -e "Пользователь mysql ${COLOR_YELLOW}$user${COLOR_NC} с паролем "${COLOR_YELLOW}$pass${COLOR_NC}" создан"
			echo ""
			$MENU/menu_sql.sh
            exit 0
            ;;
        *) echo "Отмена создания пользователя"
		$MENU/menu_sql.sh
            exit 0
            ;;
    esac




