FROM registry.access.redhat.com/ubi9/ubi

# Install nginx and openssl (for TLS at runtime if needed)
RUN dnf -y upgrade --refresh \
 && dnf -y install nginx openssl \
 && dnf clean all

# Configs
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/app.conf    /etc/nginx/conf.d/app.conf

# Dev TLS certs (self-signed) copied into image
COPY certs/dev.crt /etc/nginx/certs/dev.crt
COPY certs/dev.key /etc/nginx/certs/dev.key

EXPOSE 80 443

# Run nginx in foreground so container stays up
CMD ["nginx", "-g", "daemon off;"]
