#!/bin/bash

# Configura o ambiente para UTF-8
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export MONO_IOMAP=all
export MONO_ENCODING=utf-8

# Função para verificar se o Mono está instalado
check_mono() {
    if ! command -v mono &> /dev/null; then
        echo "Mono não está instalado. Por favor, instale o Mono primeiro."
        echo "sudo apt-get install mono-complete"
        exit 1
    fi
}

# Função para verificar se o XSP4 está instalado
check_xsp4() {
    if ! command -v xsp4 &> /dev/null; then
        echo "XSP4 não está instalado. Por favor, instale o XSP4 primeiro."
        echo "sudo apt-get install mono-xsp4"
        exit 1
    fi
}

# Verifica as dependências
check_mono
check_xsp4

# Executa o script prepare-mono.sh
./prepare-mono.sh

# Diretório do projeto
PROJECT_DIR=$(pwd)
DEPLOY_DIR="$PROJECT_DIR/bin/Debug/net472"

echo "Iniciando XSP4..."
cd "$DEPLOY_DIR"

# Configura o XSP4 para usar UTF-8
MONO_OPTIONS="--debug" xsp4 \
     --port 5000 \
     --address 0.0.0.0 \
     --root "$DEPLOY_DIR" \
     --applications /:"$DEPLOY_DIR" \
     --appconfigdir "$DEPLOY_DIR" \
     --nonstop \
     --verbose