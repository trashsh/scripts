#!/bin/bash
#просмотр удаленных репозиториев
#$1-$USERNAME process
source /etc/profile
source ~/.bashrc

        echo $1
		cd $SCRIPTS
		echo -e "\n${COLOR_YELLOW}Список удаленных репозиториев:${COLOR_NC}"
		git remote -v
		$MENU/git.sh $1
		exit 0