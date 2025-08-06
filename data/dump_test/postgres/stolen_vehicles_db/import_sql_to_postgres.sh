#!/bin/bash
# fornecer autorização
# chmod +x import_sql_to_postgres.sh

# Define o caminho base para o arquivo .env
ENV_PATH="../../../../"

# Concatena o caminho base com o nome do arquivo .env para formar o caminho completo
ENV_FILE="${ENV_PATH}.env"

# Verifica se o arquivo .env existe no caminho especificado
if [ -f "$ENV_FILE" ]; then
    # Carrega as variáveis de ambiente do arquivo
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    echo "APP_NAME: $APP_NAME"
else 
    echo ".env file not found"
    exit 1
fi

# Set container config
APP_NAME=$APP_NAME
CONTAINER_NAME="${APP_NAME}-postgres"
CONTAINER_TEMP_PATH="/tmp"

# Set postgres config
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Set database name
CURRENT_DIR=$(pwd)
FOLDER_NAME=$(basename "$CURRENT_DIR")
# DATABASE_NAME=$FOLDER_NAME
DATABASE_NAME=$POSTGRES_DB

# DATABASE_EXISTS=$(docker exec "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_database WHERE datname='$DATABASE_NAME'")

# Se o banco de dados não existir, cria o banco de dados
# if [ "$DATABASE_EXISTS" != '1' ]; then
#     echo "Criando o banco de dados '$DATABASE_NAME'..."
#     docker exec -it "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -c "CREATE DATABASE \"$DATABASE_NAME\""
# fi

# Aqui criamos o esquema public, se ele não existir
# echo "Criando o esquema 'public', se não existir..."
docker exec -it "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$DATABASE_NAME" -c "CREATE SCHEMA IF NOT EXISTS public"

# Configura o search_path para public antes de iniciar a importação
# echo "Configurando o search_path para public..."
docker exec -it "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$DATABASE_NAME" -c "SET search_path TO public"

FILE_EXTENSION=".sql"
for file in ./*$FILE_EXTENSION; do
    # Verifica se o file é um arquivo antes de imprimi-lo
    if [ -f "$file" ]; then
        FILE="$(basename "$file")"
        docker cp "$FILE" "$CONTAINER_NAME":"$CONTAINER_TEMP_PATH"
        
        FULL_FILE_PATH="$CONTAINER_TEMP_PATH/$FILE"
        docker exec -it "$CONTAINER_NAME" bash -c "psql -U $POSTGRES_USER -d "$DATABASE_NAME" -f $FULL_FILE_PATH"

        docker exec $CONTAINER_NAME rm "$FULL_FILE_PATH"
    fi
done

echo "Importação concluída."