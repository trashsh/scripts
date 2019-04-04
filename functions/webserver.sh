#!/bin/bash
declare -x -f webserverRestart
declare -x -f webserverReload
declare -x -f viewPHPVersion


#Перезапуск Веб-сервера
#Полностью готово. 13.03.2019
webserverRestart() {
    /etc/init.d/apache2 restart
    /etc/init.d/nginx restart
}


#обновление конфигураций веб-серверов
webserverReload() {
    sudo systemctl reload nginx
    sudo systemctl reload apache2
}

#вывод информации о версии PHP
viewPHPVersion(){
	echo ""
	echo "Версия PHP:"
	php -v
	echo ""
}

