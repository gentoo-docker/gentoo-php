FROM euskadi31/gentoo-portage:latest

MAINTAINER Axel Etcheverry <axel@etcheverry.biz>

RUN mkdir -p /var/www
RUN mkdir -p /etc/php/fpm.d/
RUN echo "PHP_INI_VERSION=\"production\"" >> /etc/portage/make.conf
RUN echo "dev-lang/php ~amd64" >> /etc/portage/package.keywords
RUN echo "app-admin/eselect-php fpm" >> /etc/portage/package.use
RUN echo "media-libs/gd jpeg png" >> /etc/portage/package.use
RUN echo "dev-lang/php cli crypt ctype curl fileinfo filter fpm gd hash iconv intl ipv6 json mhash mysqli mysqlnd opcache pdo phar posix readline session simplexml sockets ssl tokenizer unicode xml xmlreader xmlwriter zip zlib" >> /etc/portage/package.use
RUN echo "PHP_TARGETS=\"php5-6\"" >> /etc/portage/make.conf
RUN emerge dev-lang/php
RUN echo "export PHP_VERSION=$(eselect php show fpm)" > /etc/profile.d/php.sh && \
    env-update && \
    source /etc/profile
RUN sed -i '/\[www\]/,$d' "/etc/php/fpm-$PHP_VERSION/php-fpm.conf"
RUN echo "include=/etc/php/fpm.d/*.conf" >> "/etc/php/fpm-$PHP_VERSION/php-fpm.conf"
RUN sed -i 's/;date.timezone =/date.timezone = UTC/' "/etc/php/fpm-$PHP_VERSION/php.ini" \
    sed -i 's/;date.timezone =/date.timezone = UTC/' "/etc/php/cli-$PHP_VERSION/php.ini"

# forward logs to docker log collector
RUN ln -sf /dev/stdout /var/log/php-fpm.log
RUN ln -sf /dev/stderr /var/log/fpm-php.www.log

COPY www.conf /etc/php/fpm.d/www.conf

VOLUME /var/www

WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm", "-y", "/etc/php/fpm-$PHP_VERSION/php-fpm.conf", "--nodaemonize"]
