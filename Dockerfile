FROM alpine:latest as downloader

ARG H5AI_VERSION=0.29.0

RUN apk update && apk add --no-cache nginx zip unzip wget patch

RUN wget --no-check-certificate https://release.larsjung.de/h5ai/h5ai-${H5AI_VERSION}.zip && \
    unzip h5ai-${H5AI_VERSION}.zip -d /usr/share/h5ai

COPY class-setup.php.patch class-setup.php.patch
RUN patch -p1 -u -d /usr/share/h5ai/_h5ai/private/php/core/ -i /class-setup.php.patch && rm class-setup.php.patch

FROM alpine:latest

LABEL maintainer "benj.saiz@gmail.com"

RUN apk add --no-cache \
    nginx ffmpeg graphicsmagick \
    php7-fpm php7-curl php7-iconv php7-xml php7-dom php7-json php7-zlib php7-session php7-gd

COPY --from=downloader /usr/share/h5ai /usr/share/h5ai

COPY php-fpm.conf     /etc/php7/php-fpm.conf
COPY nginx.conf       /etc/nginx/nginx.conf
COPY entrypoint.sh    /entrypoint.sh

RUN chown nginx:www-data /usr/share/h5ai/_h5ai/public/cache/ && \
    chown nginx:www-data /usr/share/h5ai/_h5ai/private/cache/

EXPOSE 80

CMD ["/entrypoint.sh"]
