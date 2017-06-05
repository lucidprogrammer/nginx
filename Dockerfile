FROM nginx
LABEL maintainer "Lucid Programmer<lucidprogrammer@hotmail.com>"

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y -q ca-certificates wget git \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 https://github.com/letsencrypt/letsencrypt /opt/letsencrypt && mkdir /opt/letsencrypt/www

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY default-ssl.conf /etc/nginx/conf.d/default-ssl.template
# keep an ssl folder already created
RUN mkdir -p /etc/nginx/ssl/
COPY site.conf /opt/letsencrypt/www/site.conf
COPY enterpoint.sh /enterpoint.sh

ENTRYPOINT ["/enterpoint.sh"]
