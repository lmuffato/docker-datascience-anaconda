# #!/bin/bash

# Carregar as variáveis do arquivo .env
export $(grep -v '^#' .env | xargs)

# Extrair o valor da variável APP_NAME
CONTAINER_NAME=$(grep APP_NAME .env | cut -d '=' -f2)

# Executar o Spyder dentro do container em segundo plano
docker exec -d "$CONTAINER_NAME" spyder

# Loop para esperar o usuário digitar 'y'
while true; do
    read -p "Press 'y' and Enter to quit: " confirm
    if [ "$confirm" = "y" ]; then
        echo "Encerrando o Spyder..."
        docker exec "$CONTAINER_NAME" pkill -f spyder
        echo "Spyder encerrado com sucesso."
        break  # Sai do loop
    else
        echo "Entrada inválida. Por favor, pressione 'y' para encerrar o Spyder."
    fi
done
