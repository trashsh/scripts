#!/bin/bash
#$1-$USERNAME process; $2- путь к файлу(папке), подлежащего архивации; $3-путь к создаваемому архиву
#Архивация файлов с полными абсолютными путями
source /etc/profile
source ~/.bashrc

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
then

		if [ -f $2 ] ; then
			case "$4" in
			#архивация файла со структурой каталогов
				file_structure)
					tar cfz $3 $2;;
			#архивация файла со структурой каталогов и удаление оригинала
				file_structure_remove)
					tar cfz $3 $2 --remove-files;;
			#архивация файла без структуры каталогов
				file_without_structure)
					cd `dirname $2` && tar -czf $3 `basename $2`;;
			#архивация файла без структуры каталогов и удаление оригинала
				file_without_structure_remove)
					cd `dirname $2` && tar -czf $3 $2 --remove-files;;
				untar_with_structure)
					tar -xzf $2 -C $3;;
				untar_without_structure)
					tar -xf $2 -C $3;;
					
			esac
		
		else
			if [ -d $2 ] ; then
			case "$4" in
			#архивация папки со структурой каталогов
				folder_structure)
					tar -czf $3 $2;;
			#архивация папки со структурой каталогов и удаление оригинала
				folder_with_structure_remove)
					tar -czf $3 $2 --remove-files;;
			#архивация папки без структуры каталогов и удаление оригинала
				folder_without_structure)
					tar -cf - -C $2 . | gzip -c > $3;;
			#архивация папки без структуры каталогов и удаление оригинала
				folder_without_structure_remove)
					tar -cf - -C $2 . --remove-files | gzip -c > $3;;
			esac
		
			else
				echo -e "${COLOR_RED}Ошибка архивации \"$2\" ${COLOR_NC}"										
			fi											
        fi


else
    echo -e "\n${COLOR_YELLOW}Параметры запуска не найдены${COLOR_NC}. Необходимы параметры: 1-USERNAME process; 2- путь к файлу, подлежащего архивации; 3-путь к создаваемому архиву"
    fileParamsNotFound "$1" "Для запуска главного меню введите" "$SCRIPTS/menu"
fi

exit 0
