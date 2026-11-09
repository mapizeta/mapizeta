
En el compose.yml en la secció db:

   secrets:
      - db-password
      - db-backup-password //agregar

    environment:
      - MYSQL_DATABASE=example
      - MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db-password
      - MARIADB_USER=backup_user //agregar
      - MARIADB_PASSWORD_FILE=/run/secrets/db-backup-password //agregar


Sección general

secrets:
  db-password:
    file: db/password.txt

//agregar
  db-backup-password:
    file: db/backup-password.txt


  # NUEVO SERVICIO DE RESPALDO
  backup:
    build:
      context: ./backup

    restart: unless-stopped

    environment:
      - TZ=America/Santiago

    secrets:
      - db-backup-password

    volumes:
      - ./backups:/backups

    depends_on:
      db:
        condition: service_healthy


# Ejecutar y comprobar

Construir los servicios:
docker compose up -d --build


Comprobar que están funcionando:
docker compose ps


Ejecutar un respaldo manual:
docker compose exec backup /scripts/backup.sh


Ver los archivos generados desde el host:
ls -lh backups/


Revisar los logs:
docker compose logs backup