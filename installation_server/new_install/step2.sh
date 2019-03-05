
sed -i '$ a source /my/scripts/include/include.sh'  /root/.bashrc

sed -i -e "s/#Port 22/Port 6666/" /etc/ssh/sshd_config
service ssh restart





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



заменить в
	index index.html index.htm index.nginx-debian.html;
на
    index index.php index.html index.htm index.nginx-debian.html;

apt -y install proftpd
tar -czvf $BACKUPFOLDER_INSTALLED/proftpd.tar.gz /etc/proftpd/
echo "proftpd settings"
sed -i -e "s/# DefaultRoot/DefaultRoot/" /etc/proftpd/proftpd.conf
sed -i -e "s/Port\t\t\t\t21/Port\t\t\t\t10081/" /etc/proftpd/proftpd.conf
echo '/bin/false' >> /etc/shells
#AuthUserFile /etc/proftpd/ftpd.passwd
service proftpd restart



