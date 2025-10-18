#!/bin/sh

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf

nginx -g 'daemon off;'
