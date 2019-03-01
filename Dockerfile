FROM alpine:3.9
RUN apk --update add nginx
RUN mkdir /run/nginx && touch /run/nginx/nginx.pid
COPY nginx.conf /etc/nginx/nginx.conf
ADD www /www
CMD [ "nginx" ]