#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
fi
chown -R mysql:mysql /var/lib/mysql
echo 'Initializing database'
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null
tfile=`mktemp`
if [ ! -f "$tfile" ]; then
return 1
fi
# save sql
echo "[i] Create temp file: $tfile"
cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
EOF
echo "[i] Creating database: magento"
echo "CREATE DATABASE IF NOT EXISTS magento CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
echo "GRANT ALL ON magento.* to 'magento'@'%' IDENTIFIED BY 'magento';" >> $tfile
echo 'FLUSH PRIVILEGES;' >> $tfile
echo 'SET GLOBAL log_bin_trust_function_creators = 1;' >> $tfile
echo "[i] run tempfile: $tfile"
/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
rm -f $tfile
echo "[i] Sleeping 5 sec"
sleep 5
echo "Starting all process"
exec /usr/bin/mysqld --user=mysql --console --log-bin-trust-function-creators=1 &
