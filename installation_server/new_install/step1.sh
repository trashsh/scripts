apt update
apt -y upgrade
apt -y install mc git

echo 'Git script'
mkdir -p /my
cd /my
git clone https://github.com/trashsh/scritps.git
cd /my/scripts
git init
find /my/scripts -type d -exec chmod 777 {} \;
find /my/scripts -type f -exec chmod 777 {} \;
find /my/scripts -type d -exec chown root:root {} \;
find /my/scripts -type f -exec chown root:root {} \;

echo "set vars"
sed -i '$ a \\nexport USERLAMER=\"lamer\"'  /etc/profile
sed -i '$ a export MYSERVER=\"alixi.ru\"'  /etc/profile
sed -i '$ a export SSHPORT=\"6666\"'  /etc/profile
sed -i '$ a export FTPPORT=\"10081\"'  /etc/profile
sed -i '$ a export NGINXHTTPPORT=\"80\"'  /etc/profile
sed -i '$ a export NGINXHTTPSPORT=\"443\"'  /etc/profile
sed -i '$ a export APACHEHTTPPORT=\"8080\"'  /etc/profile
sed -i '$ a export APACHEHTTPSPORT=\"8443\"'  /etc/profile
sed -i '$ a export WWWFOLDER=\"public_html\"'  /etc/profile
sed -i '$ a export PHPMYADMINFOLDER=\"dbase\"'  /etc/profile
sed -i '$ a export MYFOLDER=\"\/my\"'  /etc/profile
sed -i '$ a export BACKUPFOLDER=\"\/var\/backups\"'  /etc/profile
sed -i '$ a export BACKUPFOLDER_EMPTY=\"$BACKUPFOLDER\/vds\/empty\"'  /etc/profile
sed -i '$ a export BACKUPFOLDER_INSTALLED=\"$BACKUPFOLDER\/vds\/empty\/_installed\"'  /etc/profile
sed -i '$ a export BACKUPFOLDER_DAYS=\"$BACKUPFOLDER\/vds\/days\"'  /etc/profile
sed -i '$ a export BACKUPFOLDER_IMPORTANT=\"$BACKUPFOLDER\/vds\/important\"'  /etc/profile
sed -i '$ a export BACKUPFOLDER_REMOVED=\"$BACKUPFOLDER\/vds\/removed\"'  /etc/profile
sed -i '$ a export HOMEPATHSYSUSERS=\"\/home\/system\"'  /etc/profile
sed -i '$ a export HOMEPATHWEBUSERS=\"\/home\/webusers\"'  /etc/profile
sed -i '$ a export NGINXAVAILABLE=\"\/etc\/nginx\/sites-available\"'  /etc/profile
sed -i '$ a export NGINXENABLED="\/etc\/nginx\/sites-enabled\"'  /etc/profile
sed -i '$ a export APACHEAVAILABLE=\"\/etc\/apache2\/sites-available\"'  /etc/profile
sed -i '$ a export APACHEENABLED="\/etc\/apache2\/sites-enabled\"'  /etc/profile
sed -i '$ a export HTTPNGINXPORT=80'  /etc/profile
sed -i '$ a export HTTPSNGINXPORT=443'  /etc/profile
sed -i '$ a export HTTPAPACHEPORT=8080'  /etc/profile
sed -i '$ a export HTTPSAPACHEPORT=8081'  /etc/profile

source /etc/profile
sed -i '$ a export SCRIPTS=\'$MYFOLDER'\/scripts'  /etc/profile
sed -i '$ a export MENU=\'$MYFOLDER'\/scripts\/.menu'  /etc/profile
sed -i '$ a PATH=$PATH:'$HOMEPATHSYSUSERS\/$USERLAMER'\/.composer\/vendor\/bin'  /etc/profile
sed -i '$ a export TEMPLATES="\/my'$MYFOlDER'\/scripts\/.config\/templates"'  /etc/profile
sed -i '$ a export SETTINGS="\/my'$MYFOlDER'\/scripts\/.config\/settings"'  /etc/profile
sed -i '$ a alias start=\"sudo -s source \/my\/scripts\/include\/inc.sh && \/my\/scripts\/menu\"'  /etc/profile
source /etc/profile
sed -i "$ a export COLOR_NC='\\\e[0m'"  /etc/profile
sed -i "$ a export COLOR_WHITE='\\\e[1;37m'"  /etc/profile
sed -i "$ a export COLOR_BLACK='\\\e[0;30m'"  /etc/profile
sed -i "$ a export COLOR_BLUE='\\\e[1;34m'"  /etc/profile
sed -i "$ a export COLOR_LIGHT_BLUE='\\\e[0;32m'"  /etc/profile
sed -i "$ a export COLOR_LIGHT_GREEN='\\\e[0;36m'"  /etc/profile
sed -i "$ a export COLOR_LIGHT_CYAN='\\\e[1;36m'"  /etc/profile
sed -i "$ a export COLOR_RED='\\\e[0;31m'"  /etc/profile
sed -i "$ a export COLOR_LIGHT_RED='\\\e[1;31m'"  /etc/profile
sed -i "$ a export COLOR_PURPLE='\\\e[0;35m'"  /etc/profile
sed -i "$ a export COLOR_LIGHT_PURPLE='\\\e[1;35m'"  /etc/profile
sed -i "$ a export COLOR_BROWN='\\\e[0;33m'"  /etc/profile
sed -i "$ a export COLOR_YELLOW='\\\e[1;33m'"  /etc/profile
sed -i "$ a export COLOR_GRAY='\\\e[0;30m'"  /etc/profile
sed -i "$ a export COLOR_LIGHT_GRAY='\\\e[0;37m'"  /etc/profile
sed -i "$ a export COLOR_GREEN='\\\e[0;32m'"  /etc/profile
source /etc/profile

echo "make dirs"
mkdir -p $BACKUPFOLDER_EMPTY
mkdir -p $BACKUPFOLDER_INSTALLED
mkdir -p $BACKUPFOLDER_DAYS
mkdir -p $BACKUPFOLDER_IMPORTANT
mkdir -p $BACKUPFOLDER_IMPORTANT/ssh
mkdir -p $BACKUPFOLDER_REMOVED
mkdir -p $MYFOLDER
mkdir -p $HOMEPATHSYSUSERS
mkdir -p $HOMEPATHWEBUSERS
mkdir -p $TEMPLATES
mkdir -p $SETTINGS

mkdir /etc/skel/logs
mkdir /etc/skel/tmp
mkdir /etc/skel/$WWWFOLDER
mkdir /etc/skel/.ssh

echo "make backups"
#cp -R /etc/ $BACKUPFOLDER_EMPTY/
mkdir -p $BACKUPFOLDER_EMPTY/_null
tar -czvf $BACKUPFOLDER_EMPTY/_null/etc_null.tar.gz /etc
#mv $BACKUPFOLDER_EMPTY/etc $BACKUPFOLDER_EMPTY/_etc
#cp -R /etc/default/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/cron.d/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/cron.daily/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/cron.hourly/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/cron.monthly/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/cron.weekly/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/network/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/pam.d/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/skel/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/ssl/ $BACKUPFOLDER_EMPTY/
#cp /etc/hosts $BACKUPFOLDER_EMPTY/hosts
#cp /etc/bash.bashrc $BACKUPFOLDER_EMPTY/bash.bashrc
#cp /etc/profile $BACKUPFOLDER_EMPTY/profile
#cp /etc/sudoers $BACKUPFOLDER_EMPTY/sudoers

echo "set locale"
sudo locale-gen "ru_RU.UTF-8"
dpkg-reconfigure locales

echo "set default"
sed -i -e "s/LANG=en_US.UTF-8/LANG=ru_RU.UTF-8/" /etc/default/locale
sed -i -e "s/# GROUP=100/GROUP=100/" /etc/default/useradd
###вернуться к этому позже
#sed -i -e 's/'# HOME=\/home'/'HOME=$HOMEPATHSYSUSERS'/' /etc/default/useradd
#sed -i -e 's/"# HOME=\/home"/"HOME=$HOMEPATHSYSUSERS"/' /etc/default/useradd
#sed -i 's|'# HOME=\/home'|HOME=$HOMEPATHSYSUSERS|g' /etc/default/useradd

echo "install soft"
apt -y install mc git git-core composer  wget zip unzip unrar arj putty-tools nano ufw proftpd

groupadd admin-access
groupadd ftp-access

echo "ssh settings"
groupadd ssh-access
usermod -G ssh-access -a root
#cp -R /etc/ssh/ $BACKUPFOLDER_EMPTY/
tar -czvf $BACKUPFOLDER_INSTALLED/ssh.tar.gz /etc/ssh/
sed -i -e "s/#Port 22/Port "$SSHPORT"/" /etc/ssh/sshd_config

echo "install mysql"
apt -y install mysql-server
#apt -y install mariadb-server mariadb-client
tar -czvf $BACKUPFOLDER_INSTALLED/mysql.tar.gz /etc/mysql
mysql_secure_installation
service mysql restart



echo "install apache2"
apt -y install apache2
tar -czvf $BACKUPFOLDER_INSTALLED/apache2.tar.gz /etc/apache2

echo "install php"
apt update
apt -y install php libapache2-mod-php php-mysql php-fpm
apt -y install php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml
apt -y install libapache2-mod-php7.2 php7.2-cli php7.2-pgsql php7.2-imagick php7.2-intl

apt -y install php php-zip php-gd php-mysql php-memcache php-memcached
a2enmod proxy_fcgi setenvif
a2enconf php7.2-fpm
a2enmod proxy_http

echo "apache conf"
sed -i -e "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
sed -i -e "s/Listen 443/Listen 8443/" /etc/apache2/ports.conf
#sed -i -e "s/Listen 443/Listen 8443/" /etc/php/7.2/fpm/php.ini
#sed -i -e "s/Listen 443/Listen 8443/" /etc/php/7.3/fpm/php.ini
a2enmod rewrite
service apache2 restart


tar -czvf $BACKUPFOLDER_INSTALLED/proftpd.tar.gz /etc/proftpd/
tar -czvf $BACKUPFOLDER_INSTALLED/ufw.tar.gz /etc/ufw/
apt -y install curl build-essential software-properties-common net-tools


echo "letsencrypt"
add-apt-repository -y ppa:nilarimogard/webupd8
apt update
apt -y upgrade
apt -y install launchpad-getkeys
apt -y install letsencrypt
tar -czvf $BACKUPFOLDER_INSTALLED/letsencrypt.tar.gz /etc/letsencrypt/
launchpad-getkeys

echo "php repository"
add-apt-repository -y ppa:ondrej/php
apt update
apt -y upgrade
echo "php"
apt -y install php-pear php5.6-curl php5.6-dev php5.6-gd php5.6-mbstring php5.6-zip php5.6-mysql php5.6-xml libapache2-mod-php5.6 php5.6-mcrypt
apt -y install php-pear php7.0-curl php7.0-dev php7.0-zip  php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-xml libapache2-mod-php7.0
apt -y install php-pear php7.1-curl php7.1-dev php7.1-gd php7.1-mbstring php7.1-zip php7.1-mysql php7.1-xml libapache2-mod-php7.1 php7.1-mcrypt
#apt -y install php-pear php7.3-curl php7.3-dev php7.3-gd php7.3-mbstring php7.3-zip php7.3-mysql php7.3-xml libapache2-mod-php7.3
#update-alternatives --set php /usr/bin/php7.2
tar -czvf $BACKUPFOLDER_INSTALLED/php_01.tar.gz /etc/php/

#echo "install mcrypt"
#apt -y install php-dev libmcrypt-dev php-pear
#pecl install mcrypt-1.0.1
#sed -i '$ a extension=mcrypt.so'  /etc/php/7.2/apache2/php.ini
#tar -czvf $BACKUPFOLDER_INSTALLED/php_02_after_mcrypt.tar.gz /etc/php/
#apt -y install php7.2-mcrypt
#apt -y install php7.3-mcrypt


echo "install nginx"
apt -y install nginx

echo "make backups"
#cp -R /etc/mc/ $BACKUPFOLDER_EMPTY/

#cp -R /etc/ufw $BACKUPFOLDER_EMPTY/
#cp -R /etc/proftpd/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/apache2/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/nginx/ $BACKUPFOLDER_EMPTY/
#cp -R /etc/php/ $BACKUPFOLDER_EMPTY/
tar -czvf $BACKUPFOLDER_INSTALLED/mc.tar.gz /etc/mc/
tar -czvf $BACKUPFOLDER_INSTALLED/nginx.tar.gz /etc/nginx/

echo "nginx settings"
#sed -i -e "s/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf
cp -R $SCRIPTS/.config/settings/nginx/nginx.conf /etc/nginx/nginx.conf
cp -R $SCRIPTS/.config/settings/nginx/nginxconfig.io/ /etc/nginx/
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
service nginx restart
php -v

echo "fail2ban"
apt -y install fail2ban
tar -czvf $BACKUPFOLDER_INSTALLED/fail2ban.tar.gz /etc/fail2ban/

echo "install policykit"
apt -y install policykit-1

echo "phpmyadmin"
apt -y install phpmyadmin php-mbstring php-gettext
a2enmod proxy_fcgi setenvif
a2enconf php7.2-fpm
tar -czvf $BACKUPFOLDER_INSTALLED/phpmyadmin.tar.gz /etc/phpmyadmin/
#cp -R /etc/phpmyadmin/ $BACKUPFOLDER_EMPTY/
sed -i -e "s/Alias \/phpmyadmin/Alias \/$PHPMYADMINFOLDER/" /etc/phpmyadmin/apache.conf
service apache2 restart

echo "install webmin"
apt update
apt -y install software-properties-common apt-transport-https wget
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
add-apt-repository "deb [arch=amd64] http://download.webmin.com/download/repository sarge contrib"
apt -y install webmin
#cp -R /etc/webmin/ $BACKUPFOLDER_EMPTY/
tar -czvf $BACKUPFOLDER_INSTALLED/webmin.tar.gz /etc/webmin/
sed -i -e "s/port=10000/port=7000/" /etc/webmin/miniserv.conf
sed -i -e "s/listen=10000/listen=7000/" /etc/webmin/miniserv.conf
service webmin restart

a2enmod proxy
a2enmod ssl
a2enmod cache

service webmin restart

echo "git-etc"
cd /etc
git config --global user.email "r@gothundead.ru"
git config --global user.name "Gothundead"
git init
git add .
git commit -m "initial commit etc"

apt install net-tools


#fix phpmyadmin error
sed -i "s/|\s*\((count(\$analyzed_sql_results\['select_expr'\]\)/| (\1)/g" /usr/share/phpmyadmin/libraries/sql.lib.php



sed -i '$ a export LINE=\"----------------------------------------------------------------------------------------------"'  /etc/profile


groupadd admin-access
usermod -G admin-access -a root

apt-get -y install quota
#fstab usrquota
sed -i -e "s/=remount-ro /=remount-ro,usrquota /" /etc/fstab
mount -o remount /
quotacheck -cum /
quotaon /


sed -i '$ a export sshAdminKeyFilePath=\"\/my\/scripts\/.config\/settings\/ssh\/keys\/lamer\"'  /etc/profile
sed -i '$ a export DATEFORMAT=`date +%Y.%m.%d`'  /etc/profile
sed -i '$ a export DATETIMEFORMAT=`date +%Y.%m.%d-%H.%M.%S`'  /etc/profile
sed -i '$ a export DATETIMESQLFORMAT=`date +%Y-%m-%d\\ %H:%M:%S`'  /etc/profile
sed -i '$ a export WEBSERVER_DB=lamer_webserver'  /etc/profile


apt -y install p7zip-rar p7zip-full

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


apt -y install proftpd
tar -czvf $BACKUPFOLDER_INSTALLED/proftpd.tar.gz /etc/proftpd/
echo "proftpd settings"
sed -i -e "s/# DefaultRoot/DefaultRoot/" /etc/proftpd/proftpd.conf
sed -i -e "s/Port\t\t\t\t21/Port\t\t\t\t10081/" /etc/proftpd/proftpd.conf
echo '/bin/false' >> /etc/shells
#AuthUserFile /etc/proftpd/ftpd.passwd
sed -i -e "s/# PassivePorts                  49152 65534/PassivePorts                  50000 50050/" /etc/proftpd/proftpd.conf
ufw allow 50000:50500/tcp comment 'ProFTPd PassivePorts'
service proftpd restart


tar -czvf $BACKUPFOLDER_INSTALLED/phpmydmin_usr_share.tar.gz /usr/share/phpmyadmin
#################вручную
phpmyadmin’s library try to count some parameter. At this line 532, I found this code in this path
file name : $ /usr/share/phpmyadmin/libraries/plugin_interface.lib.php
Find this line :
if ($options != null && count($options) > 0) {
Replace with :
if ($options != null && count((array)$options) > 0) {
It can’t use count() or sizeof() with un array type. Force parameter to array is easy way to solve this bug
#################вручную (конец)

/etc/nginx/sites-available/default
заменить в
	index index.html index.htm index.nginx-debian.html;
на
    index index.php index.html index.htm index.nginx-debian.html;


sed -i -e "s/#Port 22/Port 6666/" /etc/ssh/sshd_config
service ssh restart



