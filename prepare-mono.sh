#!/bin/bash

# Configura o ambiente para UTF-8
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Diretório do projeto
PROJECT_DIR=$(pwd)
DEPLOY_DIR="$PROJECT_DIR/bin/Debug/net472"

# Limpa e recria o diretório de deploy
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/bin"
mkdir -p "$DEPLOY_DIR/App_Code/Models"

# Compila o projeto
dotnet build -f net472

# Copia os arquivos necessários preservando a codificação
cp -p "$PROJECT_DIR/Default.aspx" "$DEPLOY_DIR/"
cp -p "$PROJECT_DIR/Default.aspx.cs" "$DEPLOY_DIR/"
cp -p "$PROJECT_DIR/Default.aspx.designer.cs" "$DEPLOY_DIR/"
cp -p "$PROJECT_DIR/web.config" "$DEPLOY_DIR/"
cp -r "$PROJECT_DIR/App_Code" "$DEPLOY_DIR/"

# Copia os assemblies compilados
if [ -f "$DEPLOY_DIR/TesteWebForms.dll" ]; then
    mkdir -p "$DEPLOY_DIR/bin"
    cp "$DEPLOY_DIR/TesteWebForms.dll" "$DEPLOY_DIR/bin/"
    cp "$DEPLOY_DIR/TesteWebForms.pdb" "$DEPLOY_DIR/bin/"
fi

# Cria link simbólico para versão lowercase
ln -sf "$DEPLOY_DIR/Default.aspx" "$DEPLOY_DIR/default.aspx"

# Define permissões
chmod -R 755 "$DEPLOY_DIR"

# Lista os arquivos copiados para verificação
echo "Arquivos no diretório de deploy:"
ls -la "$DEPLOY_DIR"
echo "Arquivos na pasta bin:"
ls -la "$DEPLOY_DIR/bin"
echo "Arquivos na pasta App_Code:"
ls -la "$DEPLOY_DIR/App_Code"