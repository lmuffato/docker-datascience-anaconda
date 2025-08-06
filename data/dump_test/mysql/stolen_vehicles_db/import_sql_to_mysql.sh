#!/bin/bash

# fornecer autorização
# chmod +x import_sql_to_mysql.sh

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
CONTAINER_NAME="${APP_NAME}-mysql"
CONTAINER_TEMP_PATH="/tmp"

# Set db config
MYSQL_USERNAME=root # root
MYSQL_PASSWORD=$MYSQL_ROOT_PASSWORD

# Set database name
CURRENT_DIR=$(pwd)
FOLDER_NAME=$(basename "$CURRENT_DIR")
# DATABASE_NAME=$FOLDER_NAME
DATABASE_NAME=$MYSQL_DATABASE

# Checa se o banco de dados existe
DATABASE_EXISTS=$(docker exec "$CONTAINER_NAME" mysql -u"$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES LIKE '$DATABASE_NAME';")

# Se o banco de dados não existir, cria o banco de dados
if [ -z "$DATABASE_EXISTS" ]; then
    echo "Criando o banco de dados '$DATABASE_NAME'..."
    docker exec -it "$CONTAINER_NAME" mysql -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE \`$DATABASE_NAME\`;"
fi

FILE_EXTENSION=".sql"
for file in ./*$FILE_EXTENSION; do
    if [ -f "$file" ]; then
        FILE="$(basename "$file")"
        docker cp "$file" "$CONTAINER_NAME":"$CONTAINER_TEMP_PATH"
        FULL_FILE_PATH="$CONTAINER_TEMP_PATH/$FILE"
        docker exec -it "$CONTAINER_NAME" bash -c "mysql -u'$MYSQL_USERNAME' -p'$MYSQL_PASSWORD' '$DATABASE_NAME' < '$FULL_FILE_PATH'"

        docker exec $CONTAINER_NAME rm "$FULL_FILE_PATH"
    fi
done

echo "Importação concluída."
