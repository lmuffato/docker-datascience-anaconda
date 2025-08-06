#!/bin/bash
# Construi o container a partir das variáveis de ambiente

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env criado e preenchido com o conteúdo de .env.example."
else
    echo "O arquivo .env já existe."
fi

# Carregar todas as variáveis do arquivo .env
export $(cat .env | sed 's/#.*//g' | xargs)

echo "APP_NAME: $APP_NAME"

# Monta o container com o nome do app passado como parâmetro
docker-compose -p $APP_NAME up -d --build
