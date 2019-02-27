#!/bin/bash
#$1-$USERNAME process; $2- путь к каталогу для разархивации $3-путь к архиву; 
#Разрхивация файлов с относительными путями
source /etc/profile
source ~/.bashrc

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] 
then
if [ -d $2 ] ; then

		if [ -f $3 ] ; then
							tar -xf $3 -C $2
						else
							echo -e "${COLOR_RED}Архив \"$3\" для разархивации не найден${COLOR_NC}"
						fi

					
		else
			echo -e "${COLOR_RED}Каталог \"$2\" для разархивации не найден${COLOR_NC}"
		fi

else
    echo -e "\n${COLOR_YELLOW}Параметры запуска не найдены${COLOR_NC}. Необходимы параметры: путь к каталогу для разархиваци, путь к архиву"
    fileParamsNotFound "$1" "Для запуска главного меню введите" "$SCRIPTS/menu"
fi

exit 0