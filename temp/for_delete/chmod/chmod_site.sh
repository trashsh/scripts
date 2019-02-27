#!/bin/bash
#ввод параметров добавления сайта на laravel
#$1-username process
source /etc/profile
source ~/.bashrc

echo -e "\033[33m" 'Изменения прав доступа на файлы и папки для сайта.' "\033[0;39m"
echo -e 'Список имеющихся доменов на сервере:'

site_path=$HOMEPATHWEBUSERS/$USER
ls $site_path
	
#ls $HOMEPATHWEBUSERS/$USER
echo ""
read -p "Введите домен: " domain


    
    echo -n -e "Для изменения прав доступа домена \033[32m $domain \033[0;39m в каталоге \033[32m $path \033[0;39m новым владельцем \033[32m $USER \033[0;39m введите \033[32m \"y\"\033[0;39m, для выхода - любой символ: "
	while read
		do
			echo -n ": "
			case "$REPLY" in
			y|Y) echo -e "\033[32m" "Применение списка прав \033[0;39m..."
			#chmod
					sudo find $site_path/$domain -type d -exec chmod 755 {} \;
					sudo find $site_path/$domain -type f -exec chmod 644 {} \;
					sudo find $site_path/$domain -type d -exec chown $USER:www-data {} \;
					sudo find $site_path/$domain -type f -exec chown $USER:www-data {} \;
					break;;
			n|N)  break;;
			esac
		done

fi
	
