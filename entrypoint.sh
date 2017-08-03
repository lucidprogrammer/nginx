#!/bin/sh

set -e
SSL="on"

# define a function to reuse to calculate the location entry
get_location_entry () {
    local json=$1

    # check for websocket support, do we need it
    local websockets
    websockets="$(echo "$json" | jq ".websockets" | tr -d '"')"
    local noWebSocketsEntry
    noWebSocketsEntry="$(cat /etc/nginx/conf.d/locations/proxy.basic)"
    local onlyForWebSockets
    if [ "$websockets" = "yes" ]; then
      onlyForWebSockets="$(cat /etc/nginx/conf.d/locations/proxy.websockets)"
    else
      onlyForWebSockets="# no keep alive or websockets supported for this location"
    fi
    # have a specific appName
    local appName
    appName="http://$(echo "$json" | jq ".appName" | tr -d '"')_app"

    local appNameEntry
    appNameEntry="proxy_pass $appName;"

    # look for allow
    local allow
    allow="$(echo "$json" | jq ".allow" | tr -d '"')"
    local allowEntries

    old_IFS=$IFS

    if [ "$allow" != null ]; then
      IFS=','
      for ip in $allow
      do
        if [ $allowEntries ]; then
          allowEntries="$(printf "%s\n allow %s;" $allowEntries $ip)"
        else
          allowEntries="$(printf "allow %s;" $ip)"
        fi

      done
      allowEntries="$(printf "%s\n deny all;" $allowEntries)"
    else
      allowEntries="# we allow all traffic by default"
    fi
    IFS=${old_IFS}


    local locationRegex
    locationRegex="$(echo "$json" | jq ".location.regex" | tr -d '"' )"
    # replace " in the string
    # in json file \ is escaped with another \. So replace \\ with \
    local location
    location="$(echo "$json" | jq ".location.path" | tr -d '"' | sed 's/\\\\/\\/')"

    # formatted output
    printf "location %s %s {\n%s\n%s\n%s\n%s\n}\n" "$locationRegex" "$location" "$allowEntries" "$noWebSocketsEntry" "$onlyForWebSockets" "$appNameEntry"
}

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
  # awk '!a[$0]++' removes any duplicate upstream entries
  jq ".proxies[]"  /etc/nginx/conf.d/proxies/proxies.json | \
  jq '"upstream \(.appName)_app { server \(.appName):\(.port); }"' | \
  tr -d '"' | awk '!a[$0]++' >> /etc/nginx/conf.d/upstream/upstream.conf

  # now lets create the locations,
  itemsCount="$(jq ".proxies | length" /etc/nginx/conf.d/proxies/proxies.json)"

  for j in $(seq 0 $(($itemsCount-1))); do
   get_location_entry "$(jq ".proxies[$j]"  /etc/nginx/conf.d/proxies/proxies.json)"  >> /etc/nginx/conf.d/locations/locations.conf
  done

else
  # so we will have the default nginx page showing up
 cp /etc/nginx/conf.d/locations/default.sample /etc/nginx/conf.d/locations/default.conf
 echo "No /etc/nginx/conf.d/proxies/proxies.json found, reverting to default nginx page"
fi

echo "Starting nginx daemon"
nginx -g "daemon off;"
