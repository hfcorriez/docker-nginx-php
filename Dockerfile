FROM alpine:edge

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    sed -i.bak s/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g /etc/apk/repositories && \
    apk --update add \
        php7 \
        php7-bcmath \
        php7-dom \
        php7-ctype \
        php7-curl \
        php7-fileinfo \
        php7-fpm \
        php7-gd \
        php7-iconv \
        php7-intl \
        php7-json \
        php7-mbstring \
        php7-mcrypt \
        php7-mysqlnd \
        php7-opcache \
        php7-openssl \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-phar \
        php7-posix \
        php7-session \
        php7-soap \
        php7-xml \
        php7-xmlreader \
        php7-xmlwriter \
        php7-zip \
        php7-redis \
        php7-mongodb \
        nginx \
    && rm -rf /var/cache/apk/*

COPY ./manifest /manifest

RUN mkdir -p /etc/supervisor.d/ && mkdir /run/nginx && \
    rm -rf /etc/nginx/conf.d /etc/php7/php-fpm.d /etc/conf.d && \
    mv -f /manifest/etc/nginx/* /etc/nginx/ && \
    mv -f /manifest/etc/php/* /etc/php7/ && \
    mv -f /manifest/etc/supervisor.d /etc/supervisor.d && \
    mv -f /manifest/web /web && chmod -R 777 /web && \
    mv -f /manifest/entrypoint.sh /entrypoint.sh && chmod +x /entrypoint.sh && \
    rm -rf /manifest

EXPOSE 9000 80 443

CMD ["/bin/bash", "/entrypoint.sh"]
