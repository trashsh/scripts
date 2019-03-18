
bash -c "source $SCRIPTS/include/inc.sh; input_userAddSystem root $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroupSudo $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isSudo 1 update"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroup $USERLAMER admin-access 0"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isAdminAccess 1 update"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroup $USERLAMER ssh-access 0"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isSshAccess 1 update"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroup $USERLAMER ftp-access 0"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isFtpAccess 1 update"

bash -c "source $SCRIPTS/include/inc.sh; dbUseradd $USERLAMER $USERLAMER % pass adminGrant"
bash -c "source $SCRIPTS/include/inc.sh; dbAddRecordToDb lamer_webserver db_users username $USERLAMER insert"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver db_users username $USERLAMER created_by root update"

bash -c "source $SCRIPTS/include/inc.sh; dbSetMyCnfFile $USERLAMER $USERLAMER $USERLAMER"

bash -c "source $SCRIPTS/include/inc.sh; dbSetMyCnfFile $USERLAMER $USERLAMER $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; sshKeyAddToUser $USERLAMER users $SETTINGS/ssh/keys/lamer $HOMEPATHWEBUSERS/$USERLAMER"

bash -c "source $SCRIPTS/include/inc.sh; viewUserFullInfo $USERLAMER"



sed -i '$ a alias start=\"sudo -s source \/my\/scripts\/include\/inc.sh && \/my\/scripts\/menu\"'  /etc/profile
sed -i '$ a alias inc_func=sudo bash -c \"source \/my\/scripts\/include\/inc.sh\"'  /etc/profile


#mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
#cp /my/scripts/.config/templates/nginx/nginx_default_site /etc/nginx/sites-available/default
#/etc/init.d/nginx restart


#sudo rm /etc/nginx/sites-enabled/default
#nano /etc/nginx/sites-available/test1.alixi.ru.conf
#userAddSystem $USERLAMER


echo "ufw settings"
ufw enable
ufw default allow outgoing
ufw default deny incoming
ufw allow 6666/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP-Nginx'
ufw allow 443/tcp comment 'HTTPS-Nginx'
ufw allow 10081/tcp comment 'ProFTPd'
ufw allow 8080/tcp comment 'HTTP-Apache'
ufw allow 8443/tcp comment 'HTTPS-Apacne'
ufw allow 7000/tcp comment 'Webmin from Home'
ufw allow 3306/tcp comment 'Mysql server'

mkdir -p /var/backups/vds/removed/

