#!/bin/bash
#добавление сайта на laravel
source /etc/profile
source ~/.bashrc
# $1-$USERNAME process $2 - домен ($DOMAIN), $3 - имя пользователя, $4 - путь к папке с сайтом,  $5 - шаблон виртуального хоста apache, $6 - шаблон виртуального хоста nginx

#проверка на наличие параметров запуска
if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ] && [ -n "$5" ] && [ -n "$6" ]
then

        cd $HOMEPATHWEBUSERS/$3
        composer create-project --prefer-dist laravel/laravel $2

        #make user
        echo "Добавление веб пользователя $3_$2 с домашним каталогом: $4 для домена $2"
        sudo mkdir -p $4
        sudo useradd $3_$2 -N -d $4 -m -s /bin/false
        sudo adduser $3_$2 www-data
        sudo passwd $3_$2
        sudo R /etc/skel/* $4
        sudo rm -rf $4/public_html
		
		sudo cd $4
		sudo cp -a $4/.env.example $4/.env
		sudo php artisan key:generate
		sudo php artisan config:cache


       #nginx
       sudo cp -rf $TEMPLATES/nginx/$6 /etc/nginx/sites-available/$3_$2.conf
       sudo echo "Замена переменных в файле /etc/nginx/sites-available/$3_$2.conf"
       sudo grep '#__DOMAIN' -P -R -I -l  /etc/nginx/sites-available/$3_$2.conf | xargs sed -i 's/#__DOMAIN/'$2'/g' /etc/nginx/sites-available/$3_$2.conf
	   sudo grep '#__USER' -P -R -I -l  /etc/nginx/sites-available/$3_$2.conf | xargs sed -i 's/#__USER/'$3'/g' /etc/nginx/sites-available/$3_$2.conf
       sudo grep '#__PORT' -P -R -I -l  /etc/nginx/sites-available/$3_$2.conf | xargs sed -i 's/#__PORT/'$HTTPNGINXPORT'/g' /etc/nginx/sites-available/$3_$2.conf
       sudo grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/nginx/sites-available/$3_$2.conf | xargs sed -i 's/'#__HOMEPATHWEBUSERS'/\/home\/webusers/g' /etc/nginx/sites-available/$3_$2.conf

       sudo ln -s /etc/nginx/sites-available/$3_$2.conf /etc/nginx/sites-enabled/$3_$2.conf
       sudo  systemctl reload nginx

        #apache2 
       sudo  cp -rf $TEMPLATES/apache2/$5 /etc/apache2/sites-available/$3_$2.conf
       sudo  grep '#__DOMAIN' -P -R -I -l  /etc/apache2/sites-available/$3_$2.conf | xargs sed -i 's/#__DOMAIN/'$2'/g' /etc/apache2/sites-available/$3_$2.conf
	   sudo grep '#__USER' -P -R -I -l  /etc/apache2/sites-available/$3_$2.conf | xargs sed -i 's/#__USER/'$3'/g' /etc/apache2/sites-available/$3_$2.conf
       sudo  grep '#__HOMEPATHWEBUSERS' -P -R -I -l  /etc/apache2/sites-available/$3_$2.conf | xargs sed -i 's/#__HOMEPATHWEBUSERS/\/home\/webusers/g' /etc/apache2/sites-available/$3_$2.conf
       sudo  grep '#__PORT' -P -R -I -l  /etc/apache2/sites-available/$3_$2.conf | xargs sed -i 's/#__PORT/'$HTTPAPACHEPORT'/g' /etc/apache2/sites-available/$3_$2.conf

       sudo  a2ensite $3_$2.conf
       sudo  systemctl reload apache2
		
	   sudo cp -rf $TEMPLATES/laravel/.gitignore $4/.gitignore

       sudo  echo -e "\033[32m" Применение прав к папкам и каталогам. Немного подождите "\033[0;39m"

        #chmod
       sudo  find $4 -type d -exec chmod 755 {} \;
       sudo  find $4/public -type d -exec chmod 755 {} \;
       sudo  find $4 -type f -exec chmod 644 {} \;
       sudo  find $4/public -type f -exec chmod 644 {} \;
       sudo  find $4/logs -type f -exec chmod 644 {} \;
	   sudo find $4 -type d -exec chown $3:www-data {} \;
	   sudo find $4 -type f -exec chown $3:www-data {} \;

       sudo  chown -R $3:www-data $4/logs
       sudo  chown -R $3:www-data $4/public
       sudo  chown -R $3:www-data $4/tmp
		

       sudo  chmod 777 $4/bootstrap/cache -R
       sudo  chmod 777 $4/storage -R

	   sudo cd $4
		echo -e "\033[32m" Инициализация Git "\033[0;39m"
	    git init
		git add .
		git commit -m "initial commit"
		$SCRIPTS/menu $1


else
    echo "Возможные варианты шаблонов apache:"
    ls $TEMPLATES/apache2/
    echo "Возможные варианты шаблонов nginx:"
    ls $TEMPLATES/nginx/
    echo "--------------------------------------"
    echo "Параметры запуска не найдены. Необходимы параметры: домен, имя пользователя,путь к папке с сайтом,название шаблона apache,название шаблона nginx."
    echo "Например $0 domain.ru user /home/webusers/domain.ru php.conf php.conf"
    fileParamsNotFound "$1" "Для запуска главного введите" "$SCRIPTS/menu"
fi


