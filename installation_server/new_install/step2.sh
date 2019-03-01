
sed -i '$ a source /my/scripts/include/include.sh'  /root/.bashrc
userAddSystem $USERLAMER

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