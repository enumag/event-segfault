ARG PHP_VERSION=7.4


FROM composer AS composer


FROM wodby/base-php:${PHP_VERSION}-debug AS extensions

RUN apk add --no-cache autoconf libevent-dev postgresql-dev ${PHPIZE_DEPS} && \
    docker-php-ext-install sockets pgsql && \
    pecl install event-2.5.5 && \
    docker-php-ext-enable --ini-name extensions.ini event


FROM wodby/base-php:${PHP_VERSION}-debug

WORKDIR /usr/app

ENV COMPOSER_NO_INTERACTION=1 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HTACCESS_PROTECT=0 \
    COMPOSER_MEMORY_LIMIT=-1

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=extensions /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=extensions /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

RUN apk add --no-cache libevent gdb dumb-init postgresql postgresql-client

COPY composer.* ./

RUN composer install --no-progress --no-suggest --no-scripts --no-dev

COPY . .

RUN composer dump-autoload --optimize

ENTRYPOINT ["dumb-init", "--"]
