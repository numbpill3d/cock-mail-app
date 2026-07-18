FROM local.local/alpine:mini

RUN apk update
RUN apk add nginx
RUN apk cache purge

STOPSIGNAL SIGQUIT

COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/http.d/* /etc/nginx/http.d/

COPY public /code/public
RUN gzip -k /code/public/*.html

USER nginx

CMD ["nginx", "-g", "daemon off;"]
