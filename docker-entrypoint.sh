#!/bin/bash

# Run migrations and seeding
php artisan migrate --force
php artisan db:seed --force

# Start FrankenPHP
exec frankenphp run --config /etc/caddy/Caddyfile 