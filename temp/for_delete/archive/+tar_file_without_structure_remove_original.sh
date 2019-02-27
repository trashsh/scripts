#!/bin/bash
#$1-$USERNAME process; $2- путь к файлу, подлежащего архивации, $3-путь к создаваемому архиву
#Архивация файла с относительными путями (без структуры) и удаление оригинала
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






















#!/bin/bash
#$1-$USERNAME process; $2- путь к каталогу, файлы в котором подлежат архивации; $3-имя файла, подлежащего архивации, $4-каталог размещения архива; $5 - имя архива
#Архивация файла с относительными путями (без структуры) и удаление оригинала
source /etc/profile
source ~/.bashrc

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]  && [ -n "$4" ] && [ -n "$5" ] 
then
if [ -f $2/$3 ] ; then
					cd $2 && tar -czf $4/$5 $3 --remove-files
				else
					echo -e "${COLOR_RED}Файл \"$2\/$3\" для архивации не найден${COLOR_NC}"
                fi
else
    echo -e "\n${COLOR_YELLOW}Параметры запуска не найдены${COLOR_NC}. Необходимы параметры: 1-USERNAME process; 2- путь к каталогу, файлы в котором подлежат архивации; 3-имя файла, подлежащего архивации, 4-каталог размещения архива; 5 - имя архива"
    echo -n -e "${COLOR_YELLOW}Для запуска основного меню напишите ${COLOR_BLUE}\"y\"${COLOR_YELLOW}, для выхода - ${COLOR_BLUE}\"n\"${COLOR_NC}:"
	while read
		do
			echo -n ": "
			case "$REPLY" in
			y|Y) $SCRIPTS/menu $1;
					break;;
			n|N)  break;;
			esac
		done
fi

exit 0
