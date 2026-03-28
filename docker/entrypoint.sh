#!/bin/sh
set -e

echo "Starting application..."

# Ensure storage directories exist with correct permissions
mkdir -p /var/www/html/storage/logs
mkdir -p /var/www/html/storage/framework/cache
mkdir -p /var/www/html/storage/framework/sessions
mkdir -p /var/www/html/storage/framework/views
mkdir -p /var/www/html/bootstrap/cache

chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache

# Ensure SQLite database exists in persistent data directory (separate from database/ code)
mkdir -p /var/www/html/data
if [ ! -f /var/www/html/data/database.sqlite ]; then
    echo "Creating SQLite database..."
    touch /var/www/html/data/database.sqlite
fi
chown -R www-data:www-data /var/www/html/data
export DB_DATABASE=/var/www/html/data/database.sqlite

# Clear and cache config
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
echo "Running migrations..."
php artisan migrate --force

echo "Ready!"

# Execute the main command
exec "$@"
