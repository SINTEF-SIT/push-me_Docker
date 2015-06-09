#!/bin/bash

#do the initial setup of the db

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

MYSQL_PASSWORD=`pwgen -c -n -1 12`
APP_DB_PASSWORD=`pwgen -c -n -1 12`
#This is so the passwords show up in logs, and are stored in the volume
echo mysql root password: $MYSQL_PASSWORD
echo $MYSQL_PASSWORD > /var/lib/mysql/mysql-root-pw.txt
echo app db  password: $APP_DB_PASSWORD
echo $APP_DB_PASSWORD > /var/lib/mysql/mysql-app-pw.txt

mysql -uroot -e "CREATE USER 'app'@'%' IDENTIFIED BY '$APP_DB_PASSWORD'"
mysql -uroot -e "CREATE DATABASE pushme;" 
mysql -uroot -e "GRANT ALL PRIVILEGES ON pushme.* TO 'app'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;"


#mysql -uroot emoncms < /var/www/emoncms/Modules/driver/driver.sql

cd /opt/Sintef-PushMe/PushMe
play clean stage

sed -n '/# --- !Downs/q;p' "/opt/Sintef-PushMe/PushMe/conf/evolutions/default/1.sql" > "/opt/evolution.sql"
mysql -uroot pushme < "/opt/evolution.sql"

mysql -uroot pushme < "/opt/Sintef-PushMe/PushMe/Database stuff/physact_insert.sql"

mysqladmin -uroot password $MYSQL_PASSWORD

#install phpmmyadmin

mysqladmin -p$MYSQL_PASSWORD shutdown

