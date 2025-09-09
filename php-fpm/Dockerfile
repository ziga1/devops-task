# ubi9 + php-fpm; logs go to stdout/stderr; listen on 0.0.0.0:9000
FROM registry.access.redhat.com/ubi9/ubi:9.4

# php 8.2 stream (adjust only if your current stream differs)
RUN microdnf -y module enable php:8.2 \
 && microdnf -y install php php-fpm php-mysqlnd php-pdo php-cli php-gd php-json php-mbstring php-xml unzip \
 && microdnf clean all

# Configs
COPY conf/php-fpm.conf        /etc/php-fpm.conf
COPY conf/www.conf            /etc/php-fpm.d/www.conf
COPY conf/99-custom.ini       /etc/php.d/99-custom.ini

# Validating config at build time
RUN php-fpm -t

EXPOSE 9000
# Foreground so container stays up
CMD ["php-fpm","-F","-O"]
