FROM nginx:1.12.0-alpine
LABEL maintainer "Lucid Programmer<lucidprogrammer@hotmail.com>"

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY default-ssl.conf /etc/nginx/conf.d/default-ssl.template
# keep an ssl folder already created
RUN mkdir -p /etc/nginx/ssl/

COPY entrypoint.sh /entrypoint.sh

RUN addgroup -g 1000 -S www-data \
 && adduser -u 1000 -D -S -G www-data www-data

ENTRYPOINT ["/entrypoint.sh"]
