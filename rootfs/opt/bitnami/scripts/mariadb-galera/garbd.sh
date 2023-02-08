#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/libldapclient.sh
. /opt/bitnami/scripts/libmariadbgalera.sh

# Load MariaDB environment variables
. /opt/bitnami/scripts/mariadb-env.sh

EXEC="${DB_BIN_DIR}/garbd"

flags=("--group=${MARIADB_GALERA_CLUSTER_NAME}" "--address=${MARIADB_GALERA_CLUSTER_ADDRESS}")

if is_boolean_yes "$DB_ENABLE_TLS" && ! grep -q "socket.ssl_cert=" "$DB_TLS_CERT_FILE"; then
    info "Setting ENABLE_TLS"
    flags+=("--option=socket.ssl_cert=${DB_TLS_CERT_FILE};socket.ssl_key=${DB_TLS_KEY_FILE};socket.ssl_ca=${DB_TLS_CA_FILE}'")
fi

# Add flags passed to this script
flags+=("$@")

# Fix for MDEV-16183 - mysqld_safe already does this, but we are using mysqld
LD_PRELOAD="$(find_jemalloc_lib)${LD_PRELOAD:+ "$LD_PRELOAD"}"
export LD_PRELOAD

info "** Starting MariaDB **"

set_previous_boot

if am_i_root; then
    exec gosu "$DB_DAEMON_USER" "$EXEC" "${flags[@]}"
else
    exec "$EXEC" "${flags[@]}"
fi
