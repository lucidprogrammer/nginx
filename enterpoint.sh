#!/bin/bash
set -e
SSL="on"

if [ "$WEB_SSL" == "$SSL" ]; then
    echo "Start HTTPS"
    cp -rf /etc/nginx/conf.d/default-ssl.template /etc/nginx/conf.d/default.conf
fi

if [ "$WEB_HOST" ]; then
    sed -i "s/lucidprogrammer.info/${WEB_HOST}/" /etc/nginx/conf.d/default.conf
    sed -i "s/lucidprogrammer.info/${WEB_HOST}/" /opt/letsencrypt/www/site.conf
fi

if [ "$EMAIL_NOTIFY" ]; then
  sed -i "s/lucidprogrammer@gmail.com/${EMAIL_NOTIFY}/" /opt/letsencrypt/www/site.conf
fi

nginx -g "daemon off;"
