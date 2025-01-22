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
mkdir -p "$DEPLOY_DIR/Teste"  # Garante que a pasta Teste existe

# Compila o projeto
dotnet build -f net472

# Função para copiar arquivos ASPX e seus code-behind mantendo a estrutura de diretórios
copy_aspx_files() {
    local src_dir="$1"
    local dest_dir="$2"
    
    # Encontra todos os arquivos .aspx e copia mantendo a estrutura
    find "$src_dir" -name "*.aspx" -type f | while read aspx_file; do
        # Obtém o caminho relativo
        rel_path=${aspx_file#$src_dir/}
        dir_path=$(dirname "$rel_path")
        
        echo "Processando $aspx_file"
        echo "Caminho relativo: $rel_path"
        echo "Diretório: $dir_path"
        
        # Cria o diretório de destino se necessário
        mkdir -p "$dest_dir/$dir_path"
        
        # Copia o arquivo .aspx e seu code-behind
        cp -p "$aspx_file" "$dest_dir/$rel_path"
        if [ -f "${aspx_file}.cs" ]; then
            cp -p "${aspx_file}.cs" "$dest_dir/${rel_path}.cs"
            echo "Copiado ${aspx_file}.cs para $dest_dir/${rel_path}.cs"
        fi
        
        echo "Copiado $aspx_file para $dest_dir/$rel_path"
        
        # Cria link simbólico para versão lowercase no diretório correto
        cd "$dest_dir/$dir_path"
        base_name=$(basename "$rel_path")
        lower_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]')
        if [ "$base_name" != "$lower_name" ]; then
            ln -sf "$base_name" "$lower_name"
            echo "Criado link simbólico $lower_name -> $base_name em $dir_path"
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
echo "Arquivos na pasta Teste:"
ls -la "$DEPLOY_DIR/Teste"

# Lista todos os arquivos recursivamente
echo "Lista completa de arquivos:"
find "$DEPLOY_DIR" -type f -o -type l | sort