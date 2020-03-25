FROM php:7.3-fpm-alpine
WORKDIR /tmp

# Install php exts and their dependencies
ENV MAGICK_HOME=/usr
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN apk upgrade --update \
    && apk add curl curl-dev autoconf git gmp gmp-dev gettext gettext-dev \
    && docker-php-ext-install gettext gmp opcache json curl \
    && apk add freetype-dev libjpeg-turbo-dev libpng-dev freetype libjpeg libpng \
    && docker-php-ext-install gd \
    && apk del freetype-dev libjpeg-turbo-dev libpng-dev \
    && apk add oniguruma-dev oniguruma \
    && docker-php-ext-install mbstring \
    && apk del oniguruma-dev \
    && apk add libxml2-dev libxml2 \
    && docker-php-ext-install xml \
    && apk del libxml2-dev \
    && docker-php-ext-install mysqli pdo_mysql \
    && apk add libzip-dev libzip \
    && docker-php-ext-install zip \
    && apk del libzip-dev

# Install pecl modules
RUN apk add gcc g++ libmcrypt-dev dpkg-dev imagemagick-dev libc-dev dpkg make yaml-dev yaml libmcrypt file imagemagick libmemcached libmemcached-dev \
    && pecl install imagick-beta redis yaml mcrypt memcached apcu \
    && docker-php-ext-enable imagick redis yaml mcrypt memcached apcu \
    && apk del gcc g++ libmcrypt-dev dpkg-dev imagemagick-dev libc-dev dpkg make yaml-dev

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && composer global require hirak/prestissimo 2>&1

# Fix upload size
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && sed -i 's/post_max_size = 8M/post_max_size = 108M/g' /usr/local/etc/php/php.ini \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /usr/local/etc/php/php.ini

# Install Nginx
RUN apk add nginx
COPY nginx-site.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx

# Run it!
COPY docker-entrypoint.sh /
EXPOSE 80
CMD [ "sh", "/docker-entrypoint.sh" ]
