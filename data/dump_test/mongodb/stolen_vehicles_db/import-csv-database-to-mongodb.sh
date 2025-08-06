#!/bin/bash

# fornecer autorização
# chmod +x import-csv-database-to-mongodb.sh

# Define o caminho base para o arquivo .env
ENV_PATH="../../../../"

# Concatena o caminho base com o nome do arquivo .env para formar o caminho completo
ENV_FILE="${ENV_PATH}.env"

# Verifica se o arquivo .env existe no caminho especificado
if [ -f "$ENV_FILE" ]; then
    # Carrega as variáveis de ambiente do arquivo
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    echo "Variável APP_NAME carregada: $APP_NAME"
else 
    echo ".env file not found"
    exit 1
fi

# Set container config
APP_NAME=$APP_NAME
CONTAINER_NAME="${APP_NAME}-mongo"
CONTAINER_TEMP_PATH="/tmp"

# Set mongodb config
MONGO_USERNAME=$MONGO_USERNAME
MONGO_PASSWORD=$MONGO_PASSWORD

# Set database name
CURRENT_DIR=$(pwd)
FOLDER_NAME=$(basename "$CURRENT_DIR")
DATABASE_NAME=$FOLDER_NAME

FILE_EXTENSION=".csv"
for file in ./*$FILE_EXTENSION; do
    # Verifica se o file é um arquivo antes de imprimi-lo
    if [ -f "$file" ]; then
        CSV_FILE_NAME="$(basename "$file")"
        COLLECTION_NAME=$CSV_FILE_NAME
        docker cp "$CSV_FILE_NAME" "$CONTAINER_NAME":"$CONTAINER_TEMP_PATH"

        FILE_PATH="$CONTAINER_TEMP_PATH/$CSV_FILE_NAME"
        docker exec "$CONTAINER_NAME" mongoimport --type=csv -d "$DATABASE_NAME" -c "$COLLECTION_NAME" --headerline --file "$FILE_PATH" --authenticationDatabase admin --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD"
        # docker exec "$CONTAINER_NAME" mongoimport --type=csv -d "$DATABASE_NAME" -c "$COLLECTION_NAME" --headerline --file "$CONTAINER_TEMP_PATH/$CSV_FILE_NAME" --authenticationDatabase admin --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD"

        docker exec $CONTAINER_NAME rm "$FILE_PATH"
    fi
done
