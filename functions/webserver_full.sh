#!/bin/bash
declare -x -f webserverRestart      #Перезапуск Веб-сервера
declare -x -f webserverReload       #обновление конфигураций веб-серверов
declare -x -f viewPHPVersion        #вывод информации о версии PHP


#Перезапуск Веб-сервера
###!Полностью готово. Не трогать больше
webserverRestart() {
    /etc/init.d/apache2 restart
    /etc/init.d/nginx restart
}


#обновление конфигураций веб-серверов
###!Полностью готово. Не трогать больше
webserverReload() {
    sudo systemctl reload nginx
    sudo systemctl reload apache2
}

#вывод информации о версии PHP
###!Полностью готово. Не трогать больше
viewPHPVersion(){
	echo ""
	echo "Версия PHP:"
	php -v
	echo ""
}

