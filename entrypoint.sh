#!/bin/sh

set -e
SSL="on"

if [ "$WEB_SSL" = "$SSL" ]; then
    echo "Start HTTPS"
    cp -rf /etc/nginx/conf.d/default-ssl.template /etc/nginx/conf.d/default.conf
fi

if [ "$WEB_HOST" ]; then
    # -i will edit the file inplace with s/toReplace/replaceWith/
    # webhost is just the name of the server like serverName for nginx
    sed -i "s/lucidprogrammer.info/${WEB_HOST}/" /etc/nginx/conf.d/default.conf
fi

if [ -f /etc/nginx/conf.d/proxies/proxies.json ] ; then
  # lets update the upstream conf file. we just need one file here
  # >> will create the file the first time, and append to it the next loops
  jq ".proxies[]"  /etc/nginx/conf.d/proxies/proxies.json | \
  jq '"upstream \(.appName)_app { server \(.appName):\(.port); }"' >> /etc/nginx/conf.d/upstream/upstream.conf
  # now lets create the locations,
  jq ".proxies[]"  /etc/nginx/conf.d/proxies/proxies.json| \
  jq '"location \(.location.regex) \(.location.path) { proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; proxy_pass http://\(.appName)_app; }"' |
  tr -d '"' \
  >> /etc/nginx/conf.d/locations/locations.conf

else
  # so we will have the default nginx page showing up
 mv /etc/nginx/conf.d/locations/default.sample /etc/nginx/conf.d/locations/default.conf
 echo "No /etc/nginx/conf.d/proxies/proxies.json found, reverting to default nginx page"
fi


echo "Starting nginx daemon"
nginx -g "daemon off;"
