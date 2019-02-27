#!/bin/bash
source /etc/profile
source ~/.bashrc
#Вывод информации о пользователях

declare -x -f viewMysqlDb_all 			#отобразить список всех баз данных mysql
declare -x -f viewMysqlDbByUser 		#отобразить список всех баз данных, владельцем которой является пользователь mysql $1_*		 	($1-user)
declare -x -f viewMysqlDbByName 		#отобразить список всех баз данных mysql с названием, содержащим переменную $1		 			($1-user)
declare -x -f viewMysqlUsers			#отобразить список всех пользователей баз данных mysql
declare -x -f viewMysqlUsersByName		#отобразить список всех пользователей баз данных mysql, содержащих в названии переменную $1		($1-user)
declare -x -f viewMysqlAllInfo			#отобразить всю информацию по mysql-базам

