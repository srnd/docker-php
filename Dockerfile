FROM ubuntu:bionic

ENV TERM=linux


# Install PHP command-line
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        unzip \
        php-apcu \
        php-apcu-bc \
        php7.3-fpm \
        php7.3-cli \
        php7.3-curl \
        php7.3-json \
        php7.3-mbstring \
        php7.3-opcache \
        php7.3-readline \
        php7.3-xml \
        php7.3-zip \
        php-memcached \
        php7.3-mysql \
        php-redis \
        php7.3-gd \
        php7.3-gmp \
        php-imagick \
        php7.3-ldap \
        php-yaml \
        cron \
        git \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo \
    && composer clear-cache

COPY overrides.conf /etc/php/7.3/fpm/pool.d/z-overrides.conf
COPY php-fpm-startup /usr/bin/php-fpm

RUN mkdir -p /run/php && touch /run/php/php-fpm.sock && chown www-data:www-data /run/php/php-fpm.sock

RUN sed -i 's/post_max_size = 8M/post_max_size = 108M/g' /etc/php/7.3/fpm/php.ini
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /etc/php/7.3/fpm/php.ini

# Install Nginx
RUN apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/cache/apk/* && \
    chown -R www-data:www-data /var/lib/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf

RUN cat /etc/php/7.3/fpm/php.ini

# Run it!
CMD /usr/bin/php-fpm & /usr/sbin/nginx
EXPOSE 80 443
