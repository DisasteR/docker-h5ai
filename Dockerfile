FROM node:slim as builder

ENV H5AI_VERSION=0.29.0

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

FROM alpine:3.8

LABEL maintainer="pad92" \
      org.label-schema.url="https://github.com/pad92/docker-h5ai/blob/master/README.md" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version=$H5AI_VERSION \
      org.label-schema.vcs-url="https://github.com/pad92/docker-h5ai.git" \
      org.label-schema.vcs-ref=$BUILD_VCSREF \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.description="h5ai on alpine docker image" \
      org.label-schema.schema-version="1.0"

RUN apk add --no-cache \
    curl \
    nginx \
    php7 \
    php7-fileinfo \
    php7-fpm \
    php7-imagick \
    php7-json \
    php7-mbstring \
    php7-openssl \
    php7-session \
    php7-simplexml \
    php7-xml \
    php7-xmlwriter \
    php7-zlib


COPY --from=builder /h5ai/build/_h5ai /usr/share/h5ai/_h5ai

COPY slash/     /

RUN ln -sf /dev/stderr /var/log/php7/error.log \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 && chown nginx:www-data /usr/share/h5ai/_h5ai/public/cache/ \
 && chown nginx:www-data /usr/share/h5ai/_h5ai/private/cache/

EXPOSE 80

CMD ["/entrypoint.sh"]
HEALTHCHECK CMD curl -I --fail http://localhost/ || exit 1
