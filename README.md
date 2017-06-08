Nginx
=====

Minimal nginx docker with environment configurable domain name and proxy settings for a meteor app.

## Supported Docker versions

This image is supported on Docker version `1.13` and newest.

## Configuration
Expecting the following environment variables

```
WEB_HOST
WEB_SSL
METEOR_APP  [name of your meteor app running in 3000, if it is available, default location will go to that.]

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
docker run -p 80:80 -p 443:443 -d -e WEB_HOST=edge.tendigittext.com -e WEB_SSL=on -v $(pwd)/certs/live/$domain:/etc/nginx/ssl/ -v $(pwd)/acme:/opt/letsencrypt/www lucidprogrammer/nginx:latest

//now you can set the same above for cron to renew certs

```
