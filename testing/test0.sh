#!/bin/bash
source /etc/profile
source $SCRIPTS/include/include.sh
#source $SCRIPTS/functions/users.sh

#userAddSystem
#dbViewUserInfo $1 $2
#echo $?

#createSite $1 $2 $3 $4 $5
#viewUserInGroupUsersByPartName $1 $2
#echo $?


#inputSite_Laravel $1
#dbBackupBasesOneUser $1 $2 $3
#mysql -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME like 'lamer_%'" | tr -d "| " | grep -v SCHEMA_NAME
#mysql -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='lamer'" | tr -d "| " | grep -v SCHEMA_NAME
#backupSiteFiles $1 $2 $3
#backupUserSitesFiles $1 $2 $3
#dbBackupBasesOneUser $1 $2 $3
#dbBackupBase $1 $2 $3 $4
#userAddSystem $1 $2 $3 $4 $5 $6 $7
userAddSystem $1 $2 $3 $4 $5 $6 $7
echo $?