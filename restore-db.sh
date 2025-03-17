#!/bin/bash

# Función para generar nombre aleatorio para la base de datos
generate_db_name() {
    echo "db_$(date +%s)_$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"
}

# Función para mostrar mensaje de error y salir
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Configuración de PostgreSQL
DB_USER="devdev"  # Cambia esto según tu configuración
DB_PASSWORD="admin0000"  # Cambia esto según tu configuración
DB_HOST="localhost"

# Solicitar la ruta del archivo dump
echo "Por favor, ingresa la ruta completa del archivo .dump:"
read DUMP_PATH

# Verificar que el archivo existe
if [ ! -f "$DUMP_PATH" ]; then
    error_exit "El archivo $DUMP_PATH no existe"
fi

# Verificar que el archivo tiene extensión .dump
if [[ "$DUMP_PATH" != *.dump ]]; then
    error_exit "El archivo debe tener extensión .dump"
fi

# Generar nombre aleatorio para la base de datos
DB_NAME=$(generate_db_name)

# Crear la base de datos
echo "Creando base de datos $DB_NAME..."
PGPASSWORD=$DB_PASSWORD createdb -h $DB_HOST -U $DB_USER $DB_NAME || error_exit "No se pudo crear la base de datos"

# Restaurar el dump ignorando propiedades y ACLs
echo "Restaurando dump en la base de datos..."
PGPASSWORD=$DB_PASSWORD pg_restore -h $DB_HOST -U $DB_USER -O -x -d $DB_NAME "$DUMP_PATH"

# Verificar si hubo errores críticos durante la restauración
if [ $? -ne 0 ]; then
    echo "Advertencia: Se encontraron algunos errores durante la restauración, pero la base de datos podría estar funcional."
fi

# Asignar todos los objetos al usuario actual
echo "Ajustando propiedades de los objetos..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
DO \$\$
DECLARE
    r record;
BEGIN
    -- Cambiar propiedad de todas las tablas
    FOR r IN SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ALTER TABLE %I.%I OWNER TO $DB_USER', r.schemaname, r.tablename);
    END LOOP;
    
    -- Cambiar propiedad de todas las secuencias
    FOR r IN SELECT schemaname, sequencename FROM pg_sequences WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ALTER SEQUENCE %I.%I OWNER TO $DB_USER', r.schemaname, r.sequencename);
    END LOOP;
END;
\$\$;"

# Imprimir la información de conexión
echo -e "\n=== Información de la base de datos ==="
echo "Nombre de la base de datos: $DB_NAME"
echo "Usuario: $DB_USER"
echo "Contraseña: $DB_PASSWORD"
echo "Host: $DB_HOST"
echo "================================="
