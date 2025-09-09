# ubi9 + nginx - logs handled via. nginx conf. (stdout/stderr)
FROM registry.access.redhat.com/ubi9/ubi:9.4

RUN microdnf -y install nginx curl && microdnf clean all

# Core configs
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/app.conf   /etc/nginx/conf.d/app.conf

# Certs are mounted at trigger (not committed)
RUN mkdir -p /etc/nginx/certs

# Ensure runtime directories exist
RUN mkdir -p /var/cache/nginx /var/run && \
    chown -R root:root /var/cache/nginx /var/run

EXPOSE 443
STOPSIGNAL SIGQUIT
CMD ["nginx","-g","daemon off;"]
