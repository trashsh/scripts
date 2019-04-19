#!/bin/bash
declare -x -f input_ufwAddPort
#Добавление порта с исключением в firewall ufw
input_ufwAddPort() {
	echo -e "${COLOR_GREEN}Добавление исключения в правила ufw. Открытие порта ${COLOR_NC}"
	echo -n -e "${COLOR_BLUE}Введите номер порта: ${COLOR_NC}"
	read number
	echo -n -e "${COLOR_BLUE}Введите протокол: tcp или udp: ${COLOR_NC}"
	while read
	do
	    case "$REPLY" in
	        tcp)
	            protocol=tcp;
	            break
	            ;;
	        udp)
	           protocol=udp;
	            break
	            ;;
	        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
	           ;;
	    esac
	done

	echo -n -e "${COLOR_BLUE}Введите комментарий: ${COLOR_NC}"
	read comment

	ufwAddPort $number $protocol $comment
}

declare -x -f input_ufwAddPortFromIP
#Добавление порта с исключением в firewall ufw с указанием IP адреса
input_ufwAddPortFromIP() {
	echo -e "${COLOR_GREEN}Добавление исключения в правила ufw. Открытие порта с указанием IP-адреса${COLOR_NC}"
	echo -n -e "${COLOR_BLUE}Введите номер порта: ${COLOR_NC}"
	read number
	echo -n -e "${COLOR_BLUE}Введите протокол: tcp или udp: ${COLOR_NC}"
	while read
	do
	    case "$REPLY" in
	        tcp)
	            protocol="tcp";
	            break
	            ;;
	        udp)
	           protocol="udp";
	            break
	            ;;
	        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
	           ;;
	    esac
	done

    echo -n -e "${COLOR_BLUE}Введите ip-адрес: ${COLOR_NC}"
    read ipAddress
	echo -n -e "${COLOR_BLUE}Введите комментарий: ${COLOR_NC}"
	read comment

	ufwAddPortFromIP $number $protocol $ipAddress $comment
}

declare -x -f input_ufwAddPortRange
#Добавление диапазона с исключением в firewall ufw
input_ufwAddPortRange() {
	echo -e "${COLOR_GREEN}Добавление исключения в правила ufw. Открытие диапазона портов ${COLOR_NC}"
	echo -n -e "${COLOR_BLUE}Введите номер первого порта диапазона: ${COLOR_NC}"
	read number1
	echo -n -e "${COLOR_BLUE}Введите номер последнего порта диапазона: ${COLOR_NC}"
	read number2
	echo -n -e "${COLOR_BLUE}Введите протокол: tcp или udp: ${COLOR_NC}"
	while read
	do
	    case "$REPLY" in
	        tcp)
	            protocol=tcp;
	            break
	            ;;
	        udp)
	           protocol=udp;
	            break
	            ;;
	        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
	           ;;
	    esac
	done

	echo -n -e "${COLOR_BLUE}Введите комментарий: ${COLOR_NC}"
	read comment

	ufwAddPortRange $number1 $number2 $protocol $comment
}


declare -x -f input_ufwAddPortRangeFromIP
#Добавление диапазона с исключением в firewall ufw с указанием IP
input_ufwAddPortRangeFromIP() {
echo -e "${COLOR_GREEN}Добавление исключения в правила ufw. Открытие диапазона портов с указанием IP-адреса${COLOR_NC}"
	echo -n -e "${COLOR_BLUE}Введите номер первого порта диапазона: ${COLOR_NC}"
	read number1
	echo -n -e "${COLOR_BLUE}Введите номер последнего порта диапазона: ${COLOR_NC}"
	read number2
	echo -n -e "${COLOR_BLUE}Введите протокол: tcp или udp: ${COLOR_NC}"
	while read
	do
	    case "$REPLY" in
	        tcp)
	            protocol=tcp;
	            break
	            ;;
	        udp)
	           protocol=udp;
	            break
	            ;;
	        *) echo -n "Команда не распознана: ('$REPLY'). Повторите ввод:" >&2
	           ;;
	    esac
	done

    echo -n -e "${COLOR_BLUE}Введите ip-адрес: ${COLOR_NC}"
    read ipAddress
	echo -n -e "${COLOR_BLUE}Введите комментарий: ${COLOR_NC}"
	read comment

	ufwAddPortRangeFromIP $number1 $number2 $protocol $ipAddress $comment
}



declare -x -f input_ufwDeleteRuleByNumber
#Запрос номер удаляемого правила ufw и его последующее удаление
input_ufwDeleteRuleByNumber() {
echo -e "${COLOR_GREEN}Удаление правила ufw${COLOR_NC}"
    input_ufwSearchRuleByComment
	echo -n -e "${COLOR_BLUE}Введите номер правила для его удаления: ${COLOR_NC}"
	read number

	sudo ufw status numbered | grep "\[$number]"
	echo -n -e "${COLOR_YELLOW}Введите ${COLOR_BLUE}\"y\"${COLOR_NC}${COLOR_YELLOW} для удаления правила ufw  ${COLOR_GREEN}\"$number\"${COLOR_NC}${COLOR_YELLOW}, для отмены операции - введите ${COLOR_BLUE}\"n\"${COLOR_NC}: "
		while read
		do
	    	echo -n ": "
	    	case "$REPLY" in
		    	y|Y)
                    ufwDeleteRuleByNumber $number
			    	break;;
			    n|N)

				    break;;
		    esac
		done

}



declare -x -f input_ufwSearchRuleByComment
#Поиск правила ufw по комментарию
input_ufwSearchRuleByComment() {
echo -e "${COLOR_GREEN}Поиск правила${COLOR_NC}"
    sudo ufw status numbered
	echo -n -e "${COLOR_BLUE}Введите фразу для поиска: ${COLOR_NC}"
	read phrase
    ufwSearchRuleByComment $phrase
#   sudo ufw status numbered | grep "$phrase"
}

