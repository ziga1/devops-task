FROM registry.access.redhat.com/ubi9/ubi

# Keeps base up to date and install minimal tools
RUN dnf -y upgrade --refresh \
 && dnf -y install gnupg2 ca-certificates tzdata shadow-utils \
 && dnf clean all

# Adds mariadb 10.11 (LTS) repo for rhel9/ubi9
# Refference: https://mariadb.org/download/
RUN printf '%s\n' \
  '[mariadb]' \
  'name = MariaDB' \
  'baseurl = https://rpm.mariadb.org/10.11/rhel/$releasever/$basearch' \
  'gpgkey = https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB' \
  'gpgcheck = 1' \
  'repo_gpgcheck = 1' \
  > /etc/yum.repos.d/MariaDB.repo

# Installs server and client
RUN dnf -y module disable mysql || true \
 && dnf -y install MariaDB-server MariaDB-client \
 && dnf clean all

# Config and initialiyation scripts
COPY conf/zz-container.cnf /etc/my.cnf.d/zz-container.cnf
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Runtime directories
RUN mkdir -p /var/lib/mysql /run/mysqld \
 && chown -R mysql:mysql /var/lib/mysql /run/mysqld \
 && chmod 750 /var/lib/mysql

# Entrypoint and permissions
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3306

# Healthcheck!
HEALTHCHECK --interval=30s --timeout=3s --retries=5 \
  CMD mysqladmin ping -h 127.0.0.1 -u root -p"$MYSQL_ROOT_PASSWORD" || exit 1

USER mysql
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql", "--bind-address=0.0.0.0"]
