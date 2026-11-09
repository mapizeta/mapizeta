
#!/bin/sh

set -eu

DB_HOST="db"
DB_NAME="example"
DB_USER="backup_user"

FECHA=$(date +"%Y%m%d_%H%M%S")
ARCHIVO="/backups/${DB_NAME}_${FECHA}.sql"

# Leer la contraseña desde Docker Secret
DB_PASSWORD=$(cat /run/secrets/db-backup-password)

# Crear configuración temporal protegida
cat > /tmp/client.cnf <<EOF
[client]
host=${DB_HOST}
user=${DB_USER}
password=${DB_PASSWORD}
EOF

chmod 600 /tmp/client.cnf

echo "[$(date)] Iniciando respaldo de ${DB_NAME}..."

if mariadb-dump \
    --defaults-extra-file=/tmp/client.cnf \
    --single-transaction \
    --quick \
    --routines \
    --triggers \
    --events \
    "$DB_NAME" > "$ARCHIVO"; then

    gzip "$ARCHIVO"
    echo "[$(date)] Respaldo exitoso: ${ARCHIVO}.gz"

else
    echo "[$(date)] ERROR: No se pudo generar el respaldo"
    rm -f "$ARCHIVO"
    rm -f /tmp/client.cnf
    exit 1
fi

# Eliminar archivos temporales
rm -f /tmp/client.cnf

# Política de retención: 7 días
find /backups \
    -type f \
    -name "*.sql.gz" \
    -mtime +7 \
    -delete

echo "[$(date)] Respaldo finalizado."
