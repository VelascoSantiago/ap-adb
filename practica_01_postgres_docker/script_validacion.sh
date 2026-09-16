#!/bin/bash
set -e

CONTAINER="postgres-practica"
DB="practica_db"
USER="admin"
TS="ts_practica"
TS_PATH="/var/lib/postgresql/tablespaces/ts_practica"

echo "1. Verificando que el contenedor esté activo..."
docker ps --filter "name=$CONTAINER" --filter "status=running" | grep $CONTAINER

echo "2. Confirmando conexión a PostgreSQL..."
docker exec -i $CONTAINER psql -U $USER -d $DB -c "SELECT current_database(), current_user;"

echo "3. Preparando directorio para el tablespace..."
docker exec -u root $CONTAINER mkdir -p $TS_PATH
docker exec -u root $CONTAINER chown -R postgres:postgres /var/lib/postgresql/tablespaces

echo "4. Creando tablespace si no existe..."
docker exec -i $CONTAINER psql -U $USER -d $DB <<'SQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tablespace WHERE spcname = 'ts_practica') THEN
    CREATE TABLESPACE ts_practica LOCATION '/var/lib/postgresql/tablespaces/ts_practica';
  END IF;
END $$;
SQL

echo "5. Confirmando tablespace..."
docker exec -i $CONTAINER psql -U $USER -d $DB -c "SELECT spcname FROM pg_tablespace WHERE spcname='ts_practica';"

echo "Validación finalizada correctamente."
