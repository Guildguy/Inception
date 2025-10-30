#!/bin/sh
set -e

export MYSQL_PASSWORD=$(cat /run/secrets/db_password)


WORDPRESS_DB_HOST=${WP_DB_HOST:-mariadb}

echo "Waiting for database host '$WORDPRESS_DB_HOST'..."

while ! nc -z "$WORDPRESS_DB_HOST" 3306; do
  sleep 1
done
echo "Database host is ready!"

WORKDIR="/var/www/wordpress"
mkdir -p "$WORKDIR"
chown -R nobody:nobody "$WORKDIR"
cd "$WORKDIR"

if [ ! -f "wp-load.php" ]; then
    echo "WordPress core not found in volume. Copying from build..."

    cp -r /usr/src/wordpress/* .
    chown -R nobody:nobody .
else
    echo "WordPress core files already exist in volume."
fi

if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php..."

    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root \
        --skip-check || {
            echo "Failed to create wp-config.php"
            exit 1
        }
    echo "wp-config.php created successfully."
else
    echo "wp-config.php already exists."
fi

if ! wp core is-installed --allow-root --path="$WORKDIR" 2>/dev/null; then
    echo "Installing WordPress..."

    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root \
        --skip-email || {
            echo "Failed to install WordPress core"
            exit 1
        }

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root 2>/dev/null || \
        echo "Author user already exists or creation failed"

    echo "WordPress installed successfully."
else
    echo "WordPress is already installed."
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F