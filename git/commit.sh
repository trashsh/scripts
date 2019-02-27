#!/bin/bash
#создание коммита
#$1-$USERNAME process;
source /etc/profile
source ~/.bashrc





echo -n -e "Для создания коммита репозитария ${COLOR_YELLOW}\""$SCRIPTS"\"${COLOR_NC} введите ${COLOR_BLUE}\"y\"${COLOR_NC}, для выхода - ${COLOR_BLUE}\"n\"${COLOR_NC}: " 
while read
    do
        case "$REPLY" in
        "y"|"Y")  
			echo -n -e "Для задания имени коммита введите ${COLOR_BLUE}\"y\"${COLOR_NC}, задания вместо имени даты-времени - введите ${COLOR_BLUE}\"любой символ\"${COLOR_NC}: " 
				while read
					do
						case "$REPLY" in
						"y"|"Y")  
							echo -n -e "${COLOR_BLUE}Введите комментарий коммита${COLOR_NC}"
							read -p ": " comment
							dt=$(date '+%d/%m/%Y %H:%M:%S')
							sudo git add .
							sudo git commit -m "$dt - $comment"			
							break 
							;;
						*)  
							dt=$(date '+%d/%m/%Y %H:%M:%S')
							sudo git add .
							sudo git commit -m "$dt"			
							$SCRIPTS/.menu/git.sh $1
							break;; 
						esac
					done			
			break
			;;
        "n"|"N")  
			echo 'Отмена создания коммита'
				$SCRIPTS/.menu/git.sh $1
			break;; 
			
        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2;;
        esac
    done

$MENU/git.sh $1
exit 0