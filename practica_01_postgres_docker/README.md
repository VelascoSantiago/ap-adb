# Bitácora de Comandos - Práctica 1: PostgreSQL con Docker

## 1. Validación inicial de Docker
```bash
# Verificar versión de Docker instalada
docker --version

# Correr contenedor de prueba para asegurar que el motor funciona
docker run hello-world
```

## 2. Creación de Red y Volúmenes
```bash
# Crear la red virtual para aislar la base de datos
docker network create red-postgres

# Crear volumen para los datos principales de la base de datos
docker volume create pgdata

# Crear volumen para el tablespace personalizado
docker volume create pgtablespace

# Verificar la creación exitosa
docker network ls
docker volume ls
```

## 3. Despliegue del Contenedor PostgreSQL
```bash
# Iniciar el contenedor con las variables de entorno, mapeo de puertos y volúmenes
docker run -d --name postgres-practica \
  --network red-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=Admin12345 \
  -e POSTGRES_DB=practica_db \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  -v pgtablespace:/var/lib/postgresql/tablespaces \
  postgres:16
```

## 4. Administración Básica del Contenedor
```bash
# Ver contenedores activos
docker ps

# Revisar los logs para confirmar que la BD está lista
docker logs postgres-practica

# Comandos de ciclo de vida del contenedor (Pruebas)
docker stop postgres-practica
docker start postgres-practica
docker restart postgres-practica
```

## 5. Preparación del Directorio para el Tablespace
```bash
# Entrar como root al contenedor para crear la carpeta física
docker exec -u root postgres-practica mkdir -p /var/lib/postgresql/tablespaces/ts_practica

# Asignar los permisos correctos al usuario 'postgres'
docker exec -u root postgres-practica chown -R postgres:postgres /var/lib/postgresql/tablespaces
```

## 6. Conexión y Ejecución de SQL
```bash
# Conectarse a la consola interactiva psql
docker exec -it postgres-practica psql -U admin -d practica_db
```

```sql
/* ---- DENTRO DE PSQL ---- */

-- Verificar versión y credenciales
SELECT version();
SELECT current_database(), current_user;

-- Crear el tablespace apuntando a la ruta física
CREATE TABLESPACE ts_practica LOCATION '/var/lib/postgresql/tablespaces/ts_practica';

-- Verificar que el tablespace se creó correctamente
SELECT spcname FROM pg_tablespace WHERE spcname='ts_practica';

-- Ejemplos de uso del tablespace
CREATE DATABASE db_tablespace TABLESPACE ts_practica;
CREATE TABLE ejemplo_ts(id SERIAL PRIMARY KEY, descripcion TEXT) TABLESPACE ts_practica;
CREATE INDEX idx_ejemplo_ts_descripcion ON ejemplo_ts (descripcion) TABLESPACE ts_practica;

-- Cambiar el tablespace por defecto de la base actual
ALTER DATABASE practica_db SET default_tablespace = ts_practica;

-- Validar el cambio
SHOW default_tablespace;

-- Salir de psql
\q
```

## 7. Script de Validación Final
```bash
# Crear y editar el script de validación
nano script_validacion.sh

# Dar permisos de ejecución al script
chmod +x script_validacion.sh

# Ejecutar el script
./script_validacion.sh
```