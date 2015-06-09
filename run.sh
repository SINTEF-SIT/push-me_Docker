#!/bin/bash


MYSQL_VOLUME_HOME="/var/lib/mysql"
if [[ ! -d $MYSQL_VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $MYSQL_VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /config_mysql.sh
else
    echo "=> Using an existing volume of MySQL"
fi

APP_DB_PASSWORD=`cat /var/lib/mysql/mysql-app-pw.txt`

sed -i '/db.default.pass=""/s/""/"'${APP_DB_PASSWORD}'"/'  /opt/Sintef-PushMe/PushMe/conf/application.conf
sed -i '/db.default.user=root/s/root/app/'  /opt/Sintef-PushMe/PushMe/conf/application.conf
sed -i '/evolutionplugin=disabled/s/^#//g' /opt/Sintef-PushMe/PushMe/conf/application.conf

cd /opt/Sintef-PushMe/PushMe
play clean stage

chown -R mysql:mysql $MYSQL_VOLUME_HOME


exec supervisord -n
#mysqld_safe &
#/etc/init.d/lighttpd start
#/usr/bin/redis-server 
