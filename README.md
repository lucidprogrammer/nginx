Nginx
=====

Nginx with letsencrypt

## Supported Docker versions

This image is supported on Docker version `1.13` and newest.

## Configuration
Expecting the following environment variables

```
WEB_HOST
WEB_SSL

```
## Usage

This is expected to be used along with parent projects which has compose files. However, if you want to use this on its own,

```
// getting a certificate manually
// replace yourdomain with the correct domain name
// replace myemail@site.com with your email address to get certificate notification from letsencrypt.
docker run --name nginx --rm -d -p 80:80 -e WEB_HOST=yourdomain -e EMAIL_NOTIFY=myemail@site.com lucidprogrammer/nginx

//you should be able to see  http://yourdomain now.
// you should be able to do the following command to create the certificates.
docker exec -t nginx bash -c 'cd /opt/letsencrypt/ && ./letsencrypt-auto --config ./www/site.conf certonly --agree-tos -n'
docker exec -t nginx bash -c 'cp /etc/letsencrypt/archive/$WEB_HOST/privkey1.pem /etc/nginx/ssl/'
docker exec -t nginx bash -c 'cp /etc/letsencrypt/archive/$WEB_HOST/fullchain1.pem /etc/nginx/ssl/'

//now move to the appropriate directory
docker exec -t nginx bash -c 'cat /etc/letsencrypt/archive/$WEB_HOST/fullchain1.pem /etc/letsencrypt/archive/$WEB_HOST/privkey1.pem > /etc/nginx/ssl/certificate.pem'

//get the conf as per ssl
docker exec -t nginx bash -c 'cp -rf /etc/nginx/conf.d/default-ssl.template /etc/nginx/conf.d/default.conf'

docker restart nginx  

//if you go to your domain, it should redirect to https which uses the brand new certificate !!      

```

## Credits
https://www.linode.com/docs/security/ssl/install-lets-encrypt-to-create-ssl-certificates
