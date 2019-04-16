#16.04.2019-1

apt-get update
apt-get install software-properties-common
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install certbot
certbot register --email r@gothundead.ru
apt-get install python-certbot-nginx python-certbot-apache
certbot --nginx -d alixi.ru -d www.alixi.ru
cp -R $SCRIPTS/.config/settings/proftpd/myssl.conf /etc/proftpd/conf.d/myssl.conf
tar -czvf $BACKUPFOLDER_INSTALLED/letsencrypt.tar.gz /etc/letsencrypt
/etc/init.d/proftpd restart


в файле /etc/webmin/miniserv.conf добавить(отредактировать)
certfile=/etc/letsencrypt/live/alixi.ru/cert.pem
keyfile=/etc/letsencrypt/live/alixi.ru/privkey.pem

apt install members
sudo a2enmod actions



#---------------------


sudo nano /etc/phpmyadmin/apache.conf
Under the line that reads "DirectoryIndex index.php", insert a line that reads "AllowOverride All":

<Directory /usr/share/phpmyadmin>
	Options FollowSymLinks
	DirectoryIndex index.php
	AllowOverride All - вставить и сохранить

sudo nano /usr/share/phpmyadmin/.htaccess

Вставить и сохранить:
AuthType Basic
AuthName "Restricted Files"
AuthUserFile /etc/phpmyadmin/.htpasswd
Require valid-user

sudo htpasswd -c /etc/phpmyadmin/.htpasswd lamer
sudo service apache2 restart


отредактировать /etc/apache2/ports.conf
Listen 127.0.0.1:8080
Listen 127.0.0.1:8443

отредактировать /etc/mysql/mysql.conf.d/mysqld.cnf
раскомментировать #bind-address		= 127.0.0.1



sudo apt-get install php7.3-xml
composer update
composer require cviebrock/eloquent-sluggable


ln -s /usr/share/phpmyadmin /home/webusers/lamer/conf.alixi.ru/public_html/dbase

sed -i '$ a export CONFSUBDOMAIN=\"conf.alixi.ru\"'  /etc/profile

#ssl
sudo a2enmod ssl
sudo service apache2 restart