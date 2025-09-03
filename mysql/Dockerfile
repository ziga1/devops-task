FROM registry.access.redhat.com/ubi9/ubi

# Keep base up to date and install minimal tools
RUN dnf -y upgrade --refresh \
 && dnf -y install gnupg2 ca-certificates \
 && dnf clean all

# Add MariaDB 10.11 (LTS) repo for RHEL9/UBI9
# Ref: https://mariadb.org/download/
RUN printf '%s\n' \
  '[mariadb]' \
  'name = MariaDB' \
  'baseurl = https://rpm.mariadb.org/10.11/rhel/$releasever/$basearch' \
  'gpgkey = https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB' \
  'gpgcheck = 1' \
  'repo_gpgcheck = 1' \
  'enabled = 1' \
  > /etc/yum.repos.d/MariaDB.repo

# Install server + client
RUN dnf -y install MariaDB-server MariaDB-client \
 && dnf clean all

# Runtime dirs for mysqld and init scripts
RUN mkdir -p /var/lib/mysql /run/mysqld /docker-entrypoint-initdb.d \
 && chown -R mysql:mysql /var/lib/mysql /run/mysqld /docker-entrypoint-initdb.d

# Minimal container-friendly mysqld config
RUN mkdir -p /etc/my.cnf.d
COPY conf/zz-container.cnf /etc/my.cnf.d/zz-container.cnf

# Entrypoint (sanitize CRLF just in case) and make executable
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3306

# Healthcheck (active if built with --format docker)
HEALTHCHECK --interval=30s --timeout=3s --retries=5 \
  CMD mysqladmin ping -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD" || exit 1

# Run as mysql user; invoke entrypoint via bash to avoid exec-format quirks
USER mysql
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql", "--bind-address=0.0.0.0"]
