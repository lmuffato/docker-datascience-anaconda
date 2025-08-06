#!/bin/bash

# Carregar as variáveis do arquivo .env
export $(grep -v '^#' .env | xargs)

# Extrair o valor da variável APP_NAME
CONTAINER_NAME=$(grep APP_NAME .env | cut -d '=' -f2)

docker exec "$CONTAINER_NAME" jupyter notebook list | grep 'http' | awk '{print $1}' > token.txt
