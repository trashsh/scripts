#!/bin/bash
#$1-$USERNAME process; $2- путь к файлу, подлежащего архивации; $3-путь к создаваемому архиву
#Архивация файлов с полными абсолютными путями
source /etc/profile
source ~/.bashrc


if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
then
if [ -f $2 ] ; then
					tar cfz $3 $2
				else
					echo -e "${COLOR_RED}Файл \"$2\" для архивации не найден${COLOR_NC}"
                fi

else
    echo -e "\n${COLOR_YELLOW}Параметры запуска не найдены${COLOR_NC}. Необходимы параметры: 1-USERNAME process; 2- путь к файлу, подлежащего архивации; 3-путь к создаваемому архиву"
    fileParamsNotFound "$1" "Для запуска главного меню введите" "$SCRIPTS/menu"
fi

exit 0
