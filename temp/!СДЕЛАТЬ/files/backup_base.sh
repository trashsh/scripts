#!/bin/bash
source /etc/profile
source ~/.bashrc
# $1-username process;
#создание резервной копии конкретной базы данных

d=`date +%Y.%m.%d`;
dt=`date +%Y%m%d_%H%M`;
BACKUPPATH=$BACKUPFOLDER_DAYS/$d/mysql/

if ! [ -d "BACKUPPATH" ] ; then
    mkdir -p $BACKUPPATH
fi

echo -e "\n${COLOR_GREEN}Резервирование базы данных ${COLOR_NC}"
echo -n -e "От какого пользователя базы данных mysql выполнить операцию ${COLOR_YELLOW} создания резервных копий базы данных mysql ${COLOR_NC}?\nВведите ${COLOR_YELLOW} 1 ${COLOR_NC} - если от имени текущего пользователя или ${COLOR_YELLOW} 2 ${COLOR_NC} - если от имени иного пользователя, либо ${COLOR_YELLOW} любой другой символ ${COLOR_NC}-для отмены операции: "
    read item
    case "$item" in
        1) echo
            $SCRIPTS/mysql/make/backup_base.sh $1 $BACKUPPATH $item
            exit 0
            ;;
		2) echo
				echo -n -e "${COLOR_BLUE}Введите имя пользователя mysql: ${COLOR_NC}"
				read -p ": " USER

				echo -n -e "${COLOR_BLUE}Введите пароль пользователя mysql: ${COLOR_NC}"
				read -p ": " PASSWORD
		
            $SCRIPTS/mysql/make/backup_base.sh $1 $BACKUPPATH $item $USER $PASSWORD
            exit 0
            ;;
        *) echo "Выход..."
            exit 0
            ;;
    esac
