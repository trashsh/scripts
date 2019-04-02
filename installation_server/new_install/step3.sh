

sed -i '$ a source /my/scripts/include/inc.sh'  /root/.bashrc

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







