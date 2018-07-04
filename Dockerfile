FROM node:slim as builder

ARG H5AI_VERSION=0.29.0

RUN apt-get update \
 && apt-get --no-install-recommends -y install \
            git-core \
            patch \
 && git clone https://github.com/lrsjng/h5ai.git \
 && cd h5ai \
 && git checkout -b ${H5AI_VERSION} tags/v${H5AI_VERSION} \
 && npm install \
 && npm audit fix \
 && npm run build

COPY class-setup.php.patch /class-setup.php.patch
RUN patch -p1 -u -d /h5ai/build/_h5ai/private/php/core/ -i /class-setup.php.patch \
 && rm /class-setup.php.patch

FROM alpine:3.7

LABEL maintainer "benj.saiz@gmail.com"

RUN apk add --no-cache \
    nginx \
    ffmpeg \
    graphicsmagick \
    php7-fpm php7-curl php7-iconv php7-xml php7-dom php7-json php7-zip php7-session php7-gd

COPY --from=builder /h5ai/build/_h5ai /usr/share/h5ai/_h5ai

COPY slash/     /

RUN sed -i '/txt;$/ a text/plain cfg;' /etc/nginx/mime.types \ 
 && sed -i '/txt;$/ a text/plain ini;' /etc/nginx/mime.types \ 
 && chown nginx:www-data /usr/share/h5ai/_h5ai/public/cache/ \
 && chown nginx:www-data /usr/share/h5ai/_h5ai/private/cache/

EXPOSE 80

CMD ["/entrypoint.sh"]
