FROM alpine:3.22

# Instalar cliente MySQL, cron y herramientas
RUN apk add --no-cache \
    mariadb-client \
    dcron \
    tzdata

# Crear directorio de respaldos
RUN mkdir -p /backups /scripts

# Copiar archivos de configuración
COPY backup.sh /scripts/backup.sh
COPY crontab /etc/crontabs/root

# Permisos de ejecución
RUN chmod +x /scripts/backup.sh

# Ejecutar cron en primer plano
CMD ["crond", "-f", "-l", "2"]
