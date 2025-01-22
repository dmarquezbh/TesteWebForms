#!/bin/bash

# Diretório do projeto
PROJECT_DIR=$(pwd)
DEPLOY_DIR="$PROJECT_DIR/bin/Debug/net472"

# Limpa e recria o diretório de deploy
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/bin"

# Compila o projeto
dotnet build -f net472

# Copia os arquivos necessários
cp -r "$PROJECT_DIR/Default.aspx" "$DEPLOY_DIR/"
cp -r "$PROJECT_DIR/web.config" "$DEPLOY_DIR/"

# Copia os assemblies compilados
if [ -f "$DEPLOY_DIR/TesteWebForms.dll" ]; then
    mkdir -p "$DEPLOY_DIR/bin"
    cp "$DEPLOY_DIR/TesteWebForms.dll" "$DEPLOY_DIR/bin/"
    cp "$DEPLOY_DIR/TesteWebForms.pdb" "$DEPLOY_DIR/bin/"
fi

# Define permissões
chmod -R 755 "$DEPLOY_DIR"

echo "Ambiente preparado em $DEPLOY_DIR"