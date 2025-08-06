#!/bin/bash

# fornecer autorização (só é necessário executar uma vez)
# chmod +x import-boson-database-to-mongodb.sh

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

FILE_EXTENSION=".tar.gz"
for file in ./*$FILE_EXTENSION; do
    # Verifica se o file é um arquivo antes de imprimir
    if [ -f "$file" ]; then
        FILE="$(basename "$file")"
        COLLECTION_NAME="${FILE/%$FILE_EXTENSION/}" # Remove a extenção da string
        docker cp "$FILE" "$CONTAINER_NAME":"$CONTAINER_TEMP_PATH"

        TAR_FILE_PATH="$CONTAINER_TEMP_PATH/$FILE"
        docker exec $CONTAINER_NAME tar -xzvf $TAR_FILE_PATH -C $CONTAINER_TEMP_PATH

        docker exec $CONTAINER_NAME rm "$TAR_FILE_PATH"
        
        BSON_FILE="${FILE/%.tar.gz/.bson}" # Remove a extenção .tar.gz da string e substitui por .bson
        BSON_FILE_PATH="$CONTAINER_TEMP_PATH/$BSON_FILE"

        docker exec $CONTAINER_NAME mongorestore --db $DATABASE_NAME --collection $COLLECTION_NAME $BSON_FILE_PATH --authenticationDatabase admin --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD"
        
        docker exec $CONTAINER_NAME rm "$BSON_FILE_PATH"
    fi
done

echo "Importação concluída!"