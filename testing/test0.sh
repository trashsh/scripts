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
#tarFolder $1 $2 $3 $4 $5 $6 $7 $8
#echo $?

#dbBackupAllBases  $1 $2 $3 $4 $5 $6 $7 $8
#echo $?


#echo input - $1
#lamer_alixi.ru
#lamer_alixi.ru_dop2


#s1=${1%_*}
#echo s1 - $s1
#s2=${1#${s1}_}
#echo s2 - $s2


#s3=${1#$s2}
#echo s3 - $s3

                                #user_fcut=${db%_*}
                                #user=${user_fcut%_*}

                                #domain_fcut=${db##$user_}

                                #domain=${domain_fcut%_*}
dbBackupBasesOneUser $1 $2 $3 $4 $5 $6 $7 $8