#!/bin/sh

set -e
SSL="on"

if [ "$WEB_SSL" = "$SSL" ]; then
    echo "Start HTTPS"
    cp -rf /etc/nginx/conf.d/default-ssl.template /etc/nginx/conf.d/default.conf
fi

if [ "$WEB_HOST" ]; then
    sed -i "s/lucidprogrammer.info/${WEB_HOST}/" /etc/nginx/conf.d/default.conf
fi

if [ "$METEOR_APP" ]; then
  echo "Adding Meteor Proxy Support"
  # comment out the default location
  toChangeDefault="location / { root /usr/share/nginx/html; }"
  changeDefault="# location / { root /usr/share/nginx/html; }"
  sed -i "s|$toChangeDefault|$changeDefault|" /etc/nginx/conf.d/default.conf
  # uncomment the default location which points to meteor_app
  if grep -q 443 /etc/nginx/conf.d/default.conf; then
    toChangeUpstream=$(sed -n 12p /etc/nginx/conf.d/default.conf)
    toChangeLocation=$(sed -n 32p /etc/nginx/conf.d/default.conf)
  else
    toChangeUpstream=$(sed -n 6p /etc/nginx/conf.d/default.conf)
    toChangeLocation=$(sed -n 23p /etc/nginx/conf.d/default.conf)
  fi
  defaultAppName="webapp"
  toReplaceComment="#"
  replace=""
  changeLocation=$(echo $toChangeLocation | sed "s|$toReplaceComment|${replace}|")

  sed -i "s|$toChangeLocation|$changeLocation|" /etc/nginx/conf.d/default.conf

  # uncomment upstream and change name of app
  changeUpstream=$(echo $toChangeUpstream | sed "s|$toReplaceComment|${replace}|" | sed "s|$defaultAppName|${METEOR_APP}|")
  sed -i "s|$toChangeUpstream|$changeUpstream|" /etc/nginx/conf.d/default.conf

fi


echo "Starting nginx daemon"
nginx -g "daemon off;"
