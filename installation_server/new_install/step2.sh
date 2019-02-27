#fix phpmyadmin error
sed -i "s/|\s*\((count(\$analyzed_sql_results\['select_expr'\]\)/| (\1)/g" /usr/share/phpmyadmin/libraries/sql.lib.php


#sed -i '$ a source $SCRIPTS/functions/mysql.sh'  /root/.bashrc
#sed -i '$ a source $SCRIPTS/functions/archive.sh'  /root/.bashrc
sed -i '$ a source $SCRIPTS/include/include.sh'  /root/.bashrc
sed -i '$ a source $SCRIPTS/external_scripts/dev-shell-essentials-master/dev-shell-essentials.sh'  /root/.bashrc
#sed -i '$ a source $SCRIPTS/external_scripts/dev-shell-essentials-master/dev-shell-essentials.sh'  /etc/profile
sed -i '$ a export LINE=\"----------------------------------------------------------------------------------------------"'  /etc/profile

source ~/.bashrc
source /etc/profile

groupadd admin-access
usermod -G admin-access -a root
dbUpdateRecordToDb $WEBSERVER_DB users username $username isAdminAccess 1 update





apt-get -y install quota
#fstab usrquota
sed -i -e "s/=remount-ro /=remount-ro,usrquota /" /etc/fstab
mount -o remount /
quotacheck -cum /
quotaon /

apt-get install p7zip-rar p7zip-full


sed -i '$ a export sshAdminKeyFilePath=\"\/my\/scripts\/.config\/settings\/ssh\/keys\/lamer\"'  /etc/profile
sed -i "$ a source $SCRIPTS/include/include.sh"  /etc/profile

sed -i '$ a export DATEFORMAT=`date +%Y.%m.%d`'  /etc/profile
sed -i '$ a export DATETIMEFORMAT=`date +%Y.%m.%d-%H.%M.%S`'  /etc/profile
sed -i '$ a export DATETIMESQLFORMAT=`date +%Y-%m-%d\ %H:%M:%S`'  /etc/profile
sed -i '$ a export WEBSERVER_DB=lamer_webserver'  /etc/profile
#sed -i -e "s/bind-address\t\t= 127.0.0.1/bind-address\t\t= 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
source /etc/profile
sed -i '/bind-address/s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart


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


mysql -e "CREATE DATABASE IF NOT EXISTS lamer_webserver CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql lamer_webserver < $SCRIPTS/.config/templates/db/webserver/webserver.sql

usermod -G admin-access -a $USERLAMER