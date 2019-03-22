FROM alpine:3.9
SHELL ["/busybox/sh", "-c"]
RUN apk --update add nginx
RUN mkdir /run/nginx && touch /run/nginx/nginx.pid
COPY nginx.conf /etc/nginx/nginx.conf
ADD www /www
CMD [ "nginx" ]