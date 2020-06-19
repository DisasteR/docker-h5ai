#!/bin/sh

HTPASSWD=$(/usr/bin/htpasswd -cb /etc/nginx/.htpasswd ${ENV_U} ${ENV_P} 2>/dev/null 1>&2 )

if [ $? -eq 0 ]; then
    sed -i 's/#auth_/auth_/g' /etc/nginx/nginx.conf
fi


/usr/sbin/nginx
