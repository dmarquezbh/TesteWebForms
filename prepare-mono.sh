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

# Função para copiar arquivos ASPX e seus code-behind mantendo a estrutura de diretórios
copy_aspx_files() {
    local src_dir="\$1"
    local dest_dir="\$2"
    
    # Encontra todos os arquivos .aspx e copia mantendo a estrutura
    find "$src_dir" -name "*.aspx" | while read aspx_file; do
        # Obtém o caminho relativo
        rel_path=${aspx_file#$src_dir/}
        dir_path=$(dirname "$rel_path")
        
        # Cria o diretório de destino se necessário
        mkdir -p "$dest_dir/$dir_path"
        
        # Copia o arquivo .aspx e seu code-behind
        cp -p "$aspx_file" "$dest_dir/$rel_path"
        cp -p "${aspx_file}.cs" "$dest_dir/${rel_path}.cs"
        
        # Cria link simbólico para versão lowercase
        cd "$dest_dir/$dir_path"
        base_name=$(basename "$rel_path")
        lower_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]')
        if [ "$base_name" != "$lower_name" ]; then
            ln -sf "$base_name" "$lower_name"
        fi
        cd - > /dev/null
    done
}

# Copia os arquivos necessários preservando a codificação
copy_aspx_files "$PROJECT_DIR" "$DEPLOY_DIR"
cp -p "$PROJECT_DIR/web.config" "$DEPLOY_DIR/"
cp -r "$PROJECT_DIR/App_Code" "$DEPLOY_DIR/"

# Copia os assemblies compilados
if [ -f "$DEPLOY_DIR/TesteWebForms.dll" ]; then
    mkdir -p "$DEPLOY_DIR/bin"
    cp "$DEPLOY_DIR/TesteWebForms.dll" "$DEPLOY_DIR/bin/"
    cp "$DEPLOY_DIR/TesteWebForms.pdb" "$DEPLOY_DIR/bin/"
fi

# Define permissões
chmod -R 755 "$DEPLOY_DIR"

# Lista os arquivos copiados para verificação
echo "Arquivos no diretório de deploy:"
ls -la "$DEPLOY_DIR"
echo "Arquivos na pasta bin:"
ls -la "$DEPLOY_DIR/bin"
echo "Arquivos na pasta App_Code:"
ls -la "$DEPLOY_DIR/App_Code"

# Lista todos os arquivos recursivamente
echo "Lista completa de arquivos:"
find "$DEPLOY_DIR" -type f -o -type l | sort