#!/bin/bash

# Verifica se o número de argumentos é correto
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <nome_agente> <diretorio_destino>"
    exit 1
fi

# Atribui os argumentos a variáveis
NOME_AGENTE=$1
DIRETORIO_DESTINO=$2

# Define o diretório de origem
DIRETORIO_ORIGEM="./"

# Verifica se o diretório de origem existe
if [ ! -d "$DIRETORIO_ORIGEM" ]; then
    echo "Erro: O diretório de origem '$DIRETORIO_ORIGEM' não existe."
    exit 1
fi

# Cria o diretório de destino se não existir
mkdir -p "$DIRETORIO_DESTINO"

# Copia os arquivos no formato (NOME_AGENTE).privateKey e (NOME_AGENTE).publicKey
find "$DIRETORIO_ORIGEM" -type f \( -name "${NOME_AGENTE}.privateKey" -o -name "${NOME_AGENTE}.publicKey" \) -exec cp {} "$DIRETORIO_DESTINO" \;

# Verifica se a operação foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Arquivos '${NOME_AGENTE}.privateKey' e '${NOME_AGENTE}.publicKey' copiados com sucesso para '$DIRETORIO_DESTINO'."
else
    echo "Erro ao copiar os arquivos."
    exit 1
fi
