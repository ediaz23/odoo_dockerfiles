#!/bin/bash

set -e

# Set default values for PostgreSQL connection
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()

function check_config() {
    param="$1"
    value="$2"
    if [ -f "$ODOO_RC" ] && grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC"; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" | cut -d " " -f3 | sed 's/["\n\r]//g')
    fi
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}

check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo --config=/etc/odoo/odoo.conf "$@"
        else
            echo "🔎 Esperando a PostgreSQL..."
            wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
            echo "🚀 Iniciando Odoo..."
            exec odoo --config=/etc/odoo/odoo.conf "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        echo "🔎 Esperando a PostgreSQL..."
        wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
        echo "🚀 Iniciando Odoo..."
        exec odoo --config=/etc/odoo/odoo.conf "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
        ;;
esac

exit 1
