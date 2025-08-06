#!/bin/bash
# Autorizar a execução (necessário só uma vez)
# chmod +x juptyer-run.sh

# Carregar as variáveis do arquivo .env
export $(grep -v '^#' .env | xargs)

# Extrair o valor da variável APP_NAME
CONTAINER_NAME=$(grep APP_NAME .env | cut -d '=' -f2)


# Verifica se tem autenticação
if [ "$JUPYTER_REQUIRES_AUTHENTICATION" = "True" ]; then
    echo "Starting Jupyter Notebook..."
    echo -e " Authentication is \033[32mEnabled\033[0m"

    docker exec -it "$CONTAINER_NAME" jupyter notebook --ip='*' --port=${JUPYTER_PORT} --no-browser --allow-root

    # Se tiver autenticação, o link do jupyter com o token será gravado no arquivo token.txt
    docker exec "$CONTAINER_NAME" jupyter notebook list | grep 'http' | awk '{print $1}' > token.txt
else
    echo "Starting Jupyter Notebook..."
    echo -e " Authentication is \033[31mDisabled\033[0m"
    
    docker exec -it "$CONTAINER_NAME" jupyter notebook --ip='*' --port=${JUPYTER_PORT} --no-browser --allow-root --NotebookApp.token=''
fi