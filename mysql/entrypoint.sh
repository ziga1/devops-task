#!/usr/bin/env bash
set -euo pipefail

DATADIR="/var/lib/mysql"

# Default ENV (can be overridden at runtime) - kept this from 1st attempt
: "${MYSQL_ROOT_PASSWORD:=rootpass}"
: "${MYSQL_DATABASE:=appdb}"
: "${MYSQL_USER:=appuser}"
: "${MYSQL_PASSWORD:=apppass}"

first_run=0
if [ ! -d "${DATADIR}/mysql" ]; then
  first_run=1
  echo "[entrypoint] Initializing database..."
  mariadb-install-db --user=mysql --datadir="${DATADIR}" --basedir=/usr
fi

if [ "${first_run}" -eq 1 ]; then
  echo "[entrypoint] Running bootstrap SQL..."
  tmp_bootstrap="$(mktemp)"
  cat > "${tmp_bootstrap}" <<SQL
-- secure root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
ALTER USER 'root'@'127.0.0.1' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;

-- app DB + user
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  # Append any *.sql in docker-entrypoint-initdb.d
  if [ -f "/docker-entrypoint-initdb.d/init.sql" ]; then
    echo "[entrypoint] Applying /docker-entrypoint-initdb.d/init.sql"
    echo "USE \`${MYSQL_DATABASE}\`;" >> "${tmp_bootstrap}"
    cat /docker-entrypoint-initdb.d/init.sql >> "${tmp_bootstrap}"
  fi

  # Apply bootstrap SQL
  mysqld --user=mysql --datadir="${DATADIR}" --bootstrap < "${tmp_bootstrap}"
  rm -f "${tmp_bootstrap}"
fi

# Start the server in foreground
exec "$@"
