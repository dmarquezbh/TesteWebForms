#!/bin/bash

MODE=$1
PORT=${2:-5000}

function check_dotnet_version() {
    local version=$1
    if ! dotnet --list-sdks | grep -q "$version"; then
        echo ".NET SDK $version não encontrado"
        return 1
    fi
    return 0
}

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

case "$MODE" in
    "8")
        echo "Building and running with .NET 8..."
        if check_dotnet_version "8.0"; then
            dotnet build -f net8.0
            dotnet run -f net8.0 --urls="http://0.0.0.0:$PORT"
        fi
        ;;
    "3.1")
        echo "Building and running with .NET Core 3.1..."
        if check_dotnet_version "3.1"; then
            dotnet build -f netcoreapp3.1
            dotnet run -f netcoreapp3.1 --urls="http://0.0.0.0:$PORT"
        fi
        ;;
    "mono")
        echo "Building and running with Mono..."
        # Prepara o ambiente
        ./prepare-mono.sh
        
        # Executa o XSP4 no diretório correto
        cd bin/Debug/net472
        xsp4 --port ${2:-5000} --applications /:. --verbose
        ;;
    *)
        echo "Uso: ./build-and-run.sh mono [port]"
        echo "  mono - Compila e executa usando Mono"
        echo "  port - Porta opcional (padrão: 5000)"
        exit 1
        ;;


        # echo "Building and running with Mono..."
        # if check_mono; then
        #     check_xsp4
        #     dotnet build -f net472
        #     xsp4 --port $PORT --applications /:/bin/Debug/net472
        # fi
        # ;;
    *)
        echo "Uso: ./build-and-run.sh [8|3.1|mono] [port]"
        echo "  8    - Compila e executa usando .NET 8"
        echo "  3.1  - Compila e executa usando .NET Core 3.1"
        echo "  mono - Compila e executa usando Mono"
        echo "  port - Porta opcional (padrão: 5000)"
        exit 1
        ;;
esac