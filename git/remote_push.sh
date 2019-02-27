#!/bin/bash
#публикация удаленного репозитария
#$1-$USERNAME process;
source /etc/profile
source ~/.bashrc

clear
cd $SCRIPTS
echo -e "\n${COLOR_YELLOW}Публикация репозитария на github.com и Bitbucket.org:${COLOR_NC}"
sudo git remote add github https://trashsh@github.com/trashsh/scripts.git
sudo git remote add bitbucket https://gothundead@bitbucket.org/gothundead/scripts.git
sudo git push github master
sudo git push bitbucket master
echo ""
$MENU/git.sh $1
exit 0