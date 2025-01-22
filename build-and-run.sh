#!/bin/bash

PORT=${1:-5000}

function check_mono() {
    if ! command -v mono &> /dev/null; then
        echo "Mono não encontrado"
        return 1
    fi
    return 0
}

function check_xsp4() {
    if ! command -v xsp4 &> /dev/null; then
        echo "XSP4 não encontrado. Instalando..."
        sudo apt-get update
        sudo apt-get install -y mono-xsp4
    fi
}

# Configura o ambiente para UTF-8
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8
export MONO_IOMAP=all

# Verifica requisitos
if ! check_mono; then
    echo "Instalando Mono..."
    sudo apt-get update
    sudo apt-get install -y mono-complete language-pack-pt
fi
check_xsp4

echo "Building and running with Mono..."

# Limpa os arquivos anteriores
rm -rf bin/Debug/net472
rm -rf /tmp/*-temp-aspnet-*

# Compila e prepara o ambiente
dotnet build -f net472
./prepare-mono.sh

# Move para o diretório correto e executa
cd bin/Debug/net472
xsp4 --port $PORT --applications /:. --verbose --nonstop