#!/bin/sh

db_password=$(cat /run/secrets/db_password)
db_root_password=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing database..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	mysqld_safe --datadir=/var/lib/mysql &

	echo "waiting for mariadb to start..."
	while ! mysqladmin ping -h localhost --silent; do
	    sleep 1
	done
	echo "mariadb is ready!"

	echo "setting database n' user..."
	mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	mysqladmin -u root -p${db_root_password} shutdown
	echo "Initialization complete. Database is ready."
fi

echo "Starting MariaDB server in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql