#!/bin/sh

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
  sed -i "s#/web/root#${WEBROOT}#g" /etc/nginx/conf.d/default.conf
else
  WEBROOT=/web/root
fi

# Try auto install for composer
composer.phar config -g repo.packagist composer https://packagist.phpcomposer.com

if [ -f "/web/root/composer.json" ]; then
 composer.phar install --working-dir=/web/root
fi

if [ -f "$WEBROOT/composer.json" ]; then
 composer.phar install --working-dir=$WEBROOT
fi

# Display PHP error's or not
if [[ "$PHP_ENV" != "production" ]] ; then
  echo "php_flag[display_errors] = on" >> /etc/php7/php-fpm.d/www.conf
else
  echo "php_flag[display_errors] = off" >> /etc/php7/php-fpm.d/www.conf
fi

# Always chown webroot for better mounting
chown -Rf nginx.nginx $WEBROOT

# Tweak nginx to match the workers to cpu's
procs=$(cat /proc/cpuinfo | grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Run custom scripts
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
  if [ -d "/web/scripts/" ]; then
    # make scripts executable incase they aren't
    chmod -Rf 750 /web/scripts/*
    # run scripts in number order
    for i in `ls /web/scripts/`; do /www/scripts/$i ; done
  else
    echo "Can't find script directory"
  fi
fi

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
