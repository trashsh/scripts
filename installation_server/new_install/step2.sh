mysql -e "CREATE DATABASE IF NOT EXISTS lamer_webserver CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql lamer_webserver < $SCRIPTS/.config/templates/db/webserver/webserver.sql

password=123
bash -c "source $SCRIPTS/include/inc.sh; userAddSystem $USERLAMER $HOMEPATHWEBUSERS/$USERLAMER "/bin/bash" users $password root"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroupSudo $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; input_sshSettings $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; dbUseradd $USERLAMER $password % pass adminGrant"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb $WEBSERVER_DB users username $USERLAMER isAdminAccess 1 update"


bash -c "source $SCRIPTS/include/inc.sh; dbUserChangeAccess 2 % $USERLAMER"