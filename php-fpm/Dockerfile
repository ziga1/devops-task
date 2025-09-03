FROM registry.access.redhat.com/ubi9/ubi

RUN dnf -y upgrade --refresh \
 && dnf -y module enable php:8.2 \
 && dnf -y install \
      php-fpm php-cli php-common php-mysqlnd php-opcache \
      php-json php-xml php-mbstring php-gd \
 && dnf clean all

# copy configs
COPY conf/99-custom.ini /etc/php.d/99-custom.ini
COPY conf/php-fpm.conf /etc/php-fpm.conf
COPY conf/www.conf /etc/php-fpm.d/www.conf

EXPOSE 9000

# create runtime dirs (still as root)
RUN mkdir -p /run/php-fpm && chown -R 1001:0 /run/php-fpm /var/log \
 && chmod -R g=u /run/php-fpm /var/log

# **validate config BEFORE switching user**
RUN php-fpm -t

# drop privileges for runtime
USER 1001

CMD ["php-fpm", "-F"]
