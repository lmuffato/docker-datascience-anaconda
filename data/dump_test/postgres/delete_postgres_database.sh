#!/bin/bash

# # fornecer autorização
# # chmod +x import_sql_to_postgres.sh

# Define o caminho base para o arquivo .env
ENV_PATH="../../../"

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


DB_POSTGRES_USERNAME=$POSTGRES_USER

APP_NAME=$APP_NAME
CONTAINER_NAME="${APP_NAME}-postgres"

# Nome do banco de dados a ser deletado
DBNAME="stolen_vehicles_db"

# Comando para revogar conexões
revoke_conn="REVOKE CONNECT ON DATABASE $DBNAME FROM PUBLIC; SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$DBNAME';"

# Executar o comando de revogação de conexões
docker exec $CONTAINER_NAME psql -U $DB_POSTGRES_USERNAME -d postgres -c "$revoke_conn"

# Deleta o banco de dados
docker exec $CONTAINER_NAME psql -U $DB_POSTGRES_USERNAME -d postgres -c "DROP DATABASE $DBNAME;"

echo "Banco de dados $DBNAME deletado com sucesso."
