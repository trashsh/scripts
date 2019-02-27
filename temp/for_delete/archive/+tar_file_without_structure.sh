#!/bin/bash
#$1-$USERNAME process; $2- путь к файлу, подлежащего архивации, $3-путь к создаваемому архиву
#Архивация файла с относительными путями (без структуры)
source /etc/profile
source ~/.bashrc


if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
then
if [ -f $2 ] ; then
					cd `dirname $2`
					#tar -czf $3 $2
					tar -czf $3 `basename $2`
				else
					echo -e "${COLOR_RED}Каталог \"$2\" для архивации не найден${COLOR_NC}"
                fi

else
    echo -e "\n${COLOR_YELLOW}Параметры запуска не найдены${COLOR_NC}. Необходимы параметры: 1-USERNAME process; 2- путь к каталогу, файлы в котором подлежат архивации; 3-имя файла, подлежащего архивации, 4-путь к создаваемому архиву"
    fileParamsNotFound "$1" "Для запуска главного меню введите" "$SCRIPTS/menu"
fi
exit 0