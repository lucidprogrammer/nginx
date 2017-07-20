# Nginx
=====

Minimal nginx docker on alpine with environment configurable domain name and proxies.

## Supported Docker versions

This image is supported on Docker version `1.13` and newest.

## Configuration
Expecting the following environment variables

```
WEB_HOST
WEB_SSL


```

### How to setup a new PROXY
Use proxies.sample.json to create the proxy entries. Then -v thejsonfile::/etc/nginx/conf.d/proxies/proxies.json

#### Required keys
-   appName
-   port
-   location
-   location.path
-   location.regex

```

"appName": "app1",
"port": "4000",
"location": {"path": "/", "regex":""},

```
#### Optional keys

-   websockets(yes)
-   port(comma separated list)

```
//by default websockets and keep alive connections are disabled, for enabling websockets, you need to give the following entry
//if the entry is not available, that specific location does not support websockets
"websockets": "yes",
//if you don't provide the following entry, all connections are allowed by default, otherwise only the ip`s in the list are allowed.
"allow": "127.0.0.1, 200.200.200.200"

```
#### Override nginx location params

You can override the default nginx params for (with sockets and without sockets) by creating your own file in the format as provided in location.proxy.basic and location.proxy.websockets and mapping as follows.

```
-v mylocation.proxy.basic.conf:/etc/nginx/conf.d/locations/proxy.basic:ro
-v mylocation.proxy.websockets.conf:/etc/nginx/conf.d/locations/proxy.websockets:ro


```


#### Custom locations
If you want to add custom locations, you can map a conf file to the locations folder. For example

```
-v mylocation.conf:/etc/nginx/conf.d/locations/mylocation.conf:ro


```
#### Use Case

//for meteor , if you wish to serve static files faster and let the browser to cache them instead of going to proxy
```

location ~* "^/[a-z0-9]{40}\.(css|js)$" {
  root /home/ubuntu/app/bundle/programs/web.browser;
  access_log off;
  expires max;
}
```


## Configuring certificates for ssl


```
export domain=yourdomain


//create a site.conf in a manner like follows
----------------------------------------
# the domains we want to get the cert
# CHANGE FOR YOUR DOMAIN
domains = domain.com

# increase key size
rsa-key-size = 4096

# the current production version https://letsencrypt.org/docs/acme-protocol-updates/
server = https://acme-v01.api.letsencrypt.org/directory

# this address will receive renewal reminders
# CHANGE TO YOUR EMAIL
email = me@somewhere.com

# turn off the ncurses UI, to run as a cronjob
text = True

# authenticate by placing a file in the webroot (under .well-known/acme-challenge/) # and then letting LE fetch it
authenticator = webroot
webroot-path = /opt/letsencrypt/www

------------------------------------------------

//first time running
docker run -p 80:80 -d -e WEB_HOST=$domain -v $(pwd)/acme:/opt/letsencrypt/www lucidprogrammer/nginx:latest
//create certs for first time.
docker run -v $(pwd)/acme:/opt/letsencrypt/www -v $(pwd)/certs:/etc/letsencrypt/ -v $(pwd)/site.conf:/opt/letsencrypt/www/site.conf -v $(pwd)/log:/var/log/ certbot/certbot:v0.14.2 --config /opt/letsencrypt/www/site.conf certonly --agree-tos -n

docker run -v $(pwd)/certs:/etc/letsencrypt/ -v $(pwd)/log:/var/log/ certbot/certbot:v0.14.2 certificates


//you are ssl enabled.
docker run -p 80:80 -p 443:443 -d -e WEB_HOST=$domain -e WEB_SSL=on -v $(pwd)/certs/live/$domain:/etc/nginx/ssl/ -v $(pwd)/acme:/opt/letsencrypt/www lucidprogrammer/nginx:latest

//now you can set the same above for cron to renew certs

```
