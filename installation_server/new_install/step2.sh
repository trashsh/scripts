
sed -i '$ a source /my/scripts/include/include.sh'  /root/.bashrc
userAddSystem $USERLAMER

sed -i -e "s/#Port 22/Port 6666/" /etc/ssh/sshd_config
service ssh restart






