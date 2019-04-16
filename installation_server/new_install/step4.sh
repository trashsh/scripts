



mysql -e "CREATE DATABASE IF NOT EXISTS lamer_webserver CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql lamer_webserver < $SCRIPTS/.config/templates/db/webserver/webserver.sql

password=123
bash -c "source $SCRIPTS/include/inc.sh; userAddSystem $USERLAMER $HOMEPATHWEBUSERS/$USERLAMER "/bin/bash" users $password root"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroupSudo $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; input_sshSettings $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; dbUseradd $USERLAMER $password % pass adminGrant"
bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb $WEBSERVER_DB users username $USERLAMER isAdminAccess 1 update"


bash -c "source $SCRIPTS/include/inc.sh; dbUserChangeAccess 2 % $USERLAMER"




#ssh
sed -i -e "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
#sed -i -e "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
#sed -i '$ a \\nAuthenticationMethods publickey,password publickey,keyboard-interactive'  /etc/ssh/sshd_config
#sed -i -e "s/@include common-auth/#@include common-auth/" /etc/pam.d/sshd

sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i '$ a \\nAuthenticationMethods publickey'  /etc/ssh/sshd_config
sed -i -e "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
sed -i -e "s/#AuthorizedKeysFile/AuthorizedKeysFile/" /etc/ssh/sshd_config
sed -i '$ a \\nAllowGroups ssh-access'  /etc/ssh/sshd_config
sed -i '$ a \\n#Banner /etc/banner'  /etc/ssh/sshd_config
cp $TEMPLATES/ssh/banner/banner /etc/banner
chown root:root /etc/banner
chmod 644 /etc/banner
service sshd restart




###Еще не сделал
echo "webmin settings"
sed -i -e "s/ssl=1/ssl=0/" /etc/webmin/miniserv.conf
sed -i '$ a referers=wm.mmgx.ru'  /etc/webmin/config
#cp /my/scripts/.config/settings/webmin/apache/wm.mmgx.ru.conf $APACHEAVAILABLE/wm.mmgx.ru.conf
systemctl restart webmin

#a2ensite wm.mmgx.ru
systemctl restart apache2


#apt-get install automysqlbackup
#info
##wm.mmgx.ru:7000



echo "create user"
source /etc/profile
$SCRIPTS/users/useradd_system.sh $USERLAMER
mkdir -p $HOMEPATHWEBUSERS/$USERLAMER/.ssh
touch $HOMEPATHWEBUSERS/$USERLAMER/.ssh/authorized_keys
#usermod -G ssh-access -a $USERLAMER

#sed -i '$ a \\nssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAp2FS7uz8Y5lo+022MmRgwiFEmlZfK9WKdamw2DH3blowO0736Z7H4PPcx8PGSxOfeBcl6iZ+G+ukNKrDLBY0EPqc6jNE9966zvdE9N2ws9NfNZD+7+26JARRlkYnqIuUIqCiO0bz1eICyDV+1TwZ7anKxUgG+dfbFIjSdfeodSVHMeNaT8NCcYho1lWXgwy6q7h3k8EikS0qLqQmWOAPRrKUPXpsIzQTS8ll5B27U+w0OV0E222W4NOWHIbWDTorFxhqV7B4L+Z8+eao2en3i75Qng9YEe5l09HN33oQe2SsU6CfpeN0+FqwWaUT/hsYU2qS80U2oK5DGKA6vgk8rQ== myvds_lamer'  $HOMEPATHWEBUSERS/$USERLAMER/.ssh/authorized_keys
cp $SETTINGS/ssh/keys/lamer $HOMEPATHWEBUSERS/$USERLAMER/.ssh/authorized_keys

chmod 700 $HOMEPATHWEBUSERS/$USERLAMER/.ssh
chmod 600 $HOMEPATHWEBUSERS/$USERLAMER/.ssh/authorized_keys
chown $USERLAMER:users $HOMEPATHWEBUSERS/$USERLAMER/.ssh
chown $USERLAMER:users $HOMEPATHWEBUSERS/$USERLAMER/.ssh/authorized_keys
  service ssh restart



  usermod -G ftp-access -a $USERLAMER



#sed -i '$ a source $SCRIPTS/functions/mysql.sh'  /root/.bashrc
#sed -i '$ a source $SCRIPTS/functions/archive.sh'  /root/.bashrc
sed -i '$ a source $SCRIPTS/include/inc.sh'  /root/.bashrc
#sed -i '$ a source $SCRIPTS/external_scripts/dev-shell-essentials-master/dev-shell-essentials.sh'  /root/.bashrc
#sed -i '$ a source $SCRIPTS/external_scripts/dev-shell-essentials-master/dev-shell-essentials.sh'  /etc/profile

source ~/.bashrc
source /etc/profile

sed -i "$ a source $SCRIPTS/include/inc.sh"  /etc/profile


usermod -G admin-access -a $USERLAMER

#dbUpdateRecordToDb $WEBSERVER_DB users username $username isAdminAccess 1 update



#bash -c "source $SCRIPTS/include/inc.sh; dbChangeUserPassword lamer_user2 % lamer_user2 mysql_native_password lamer2" ; echo $?;







sed -i '$ a source /my/scripts/include/inc.sh'  /root/.bashrc

bash -c "source $SCRIPTS/include/inc.sh; input_userAddSystem root $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroupSudo $USERLAMER"
#bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isSudo 1 update"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroup $USERLAMER admin-access 0"
#bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isAdminAccess 1 update"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroup $USERLAMER ssh-access 0"
#bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isSshAccess 1 update"
bash -c "source $SCRIPTS/include/inc.sh; userAddToGroup $USERLAMER ftp-access 0"
#bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver users username $USERLAMER isFtpAccess 1 update"

bash -c "source $SCRIPTS/include/inc.sh; dbUseradd $USERLAMER $USERLAMER % pass adminGrant"
#bash -c "source $SCRIPTS/include/inc.sh; dbAddRecordToDb lamer_webserver db_users username $USERLAMER insert"
#bash -c "source $SCRIPTS/include/inc.sh; dbUpdateRecordToDb lamer_webserver db_users username $USERLAMER created_by root update"

bash -c "source $SCRIPTS/include/inc.sh; dbSetMyCnfFile $USERLAMER $USERLAMER $USERLAMER"

bash -c "source $SCRIPTS/include/inc.sh; dbSetMyCnfFile $USERLAMER $USERLAMER $USERLAMER"
bash -c "source $SCRIPTS/include/inc.sh; sshKeyAddToUser $USERLAMER users $SETTINGS/ssh/keys/lamer $HOMEPATHWEBUSERS/$USERLAMER"

bash -c "source $SCRIPTS/include/inc.sh; viewUserFullInfo $USERLAMER"


#ssh
sed -i -e "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
#sed -i -e "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
#sed -i '$ a \\nAuthenticationMethods publickey,password publickey,keyboard-interactive'  /etc/ssh/sshd_config
#sed -i -e "s/@include common-auth/#@include common-auth/" /etc/pam.d/sshd

sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i '$ a \\nAuthenticationMethods publickey'  /etc/ssh/sshd_config
sed -i -e "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
sed -i -e "s/#AuthorizedKeysFile/AuthorizedKeysFile/" /etc/ssh/sshd_config
sed -i '$ a \\nAllowGroups ssh-access'  /etc/ssh/sshd_config
sed -i '$ a \\n#Banner /etc/banner'  /etc/ssh/sshd_config
cp $TEMPLATES/ssh/banner/banner /etc/banner
chown root:root /etc/banner
chmod 644 /etc/banner
service sshd restart



###Еще не сделал
echo "webmin settings"
sed -i -e "s/ssl=1/ssl=0/" /etc/webmin/miniserv.conf
sed -i '$ a referers=wm.mmgx.ru'  /etc/webmin/config
#cp /my/scripts/.config/settings/webmin/apache/wm.mmgx.ru.conf $APACHEAVAILABLE/wm.mmgx.ru.conf
systemctl restart webmin

#a2ensite wm.mmgx.ru
systemctl restart apache2


#apt-get install automysqlbackup
#info
##wm.mmgx.ru:7000



############

apt install members

