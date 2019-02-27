#!/bin/bash

#Ask user to enter database name and save input to dbname variable
read -p "Please Enter Database Name:" dbname

#Create database
Q1="CREATE DATABASE IF NOT EXISTS $dbname;"

#if database exist:
if [ $? -eq 0 ]; then

#ask user about username
read -p "Please enter the username you wish to create : " username

#ask user about allowed hostname
read -p "Please Enter Host To Allow Access Eg: %,ip or hostname : " host

#ask user about password
read -p "Please Enter the Password for New User ($username) : " password

#mysql query that will create new user, grant privileges on database with entered password
Q2="GRANT ALL PRIVILEGES ON $dbname.* TO $username@'$host' IDENTIFIED BY '$password';"

# Flush privileges
Q3="FLUSH PRIVILEGES;"

QUERY="${Q1} ${Q2} ${Q3}"

#ask user to confirm all entered data
read -p "Executing Query : $QUERY , Please Confirm (y/n) : " confirm

#if user confims then
if [ "$confirm" == 'y' ]; then

#run query
mysql -u root -p -e "$QUERY"

else

#if user didn't confirm entered data
read -p "Aborted, Press any key to continue.."

#just exit
fi

else

#If database not exit – warn user and exit
echo "The Database: $dbname does not exist, please specify a database that exists";

fi
