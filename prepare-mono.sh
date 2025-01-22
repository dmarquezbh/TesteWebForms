#!/bin/bash

# Configura o ambiente para UTF-8
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Função para verificar se o Mono está instalado
check_mono() {
    if ! command -v mono &> /dev/null; then
        echo "Mono não está instalado. Por favor, instale o Mono primeiro."
        echo "sudo apt-get install mono-complete"
        exit 1
    fi
}

# Verifica as dependências
check_mono

# Diretório do projeto
PROJECT_DIR=$(pwd)
DEPLOY_DIR="$PROJECT_DIR/bin/Debug/net472"

# Limpa e recria o diretório de deploy
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/bin"

# Compila o projeto
dotnet build -f net472

# Função para copiar arquivos mantendo a estrutura de diretórios
copy_files() {
    local src_dir="$1"
    local dest_dir="$2"
    local pattern="$3"
    
    find "$src_dir" -name "$pattern" -type f | while read file; do
        # Ignora arquivos já no diretório de deploy
        if [[ $file == *"/bin/Debug/net472/"* ]]; then
            continue
        fi
        
        # Obtém o caminho relativo
        rel_path=${file#$src_dir/}
        dir_path=$(dirname "$rel_path")
        
        echo "Processando $file"
        echo "Caminho relativo: $rel_path"
        echo "Diretório: $dir_path"
        
        # Cria o diretório de destino se necessário
        mkdir -p "$dest_dir/$dir_path"
        
        # Copia o arquivo
        cp -p "$file" "$dest_dir/$rel_path"
        
        # Se for um .aspx, copia também o .cs correspondente
        if [[ "$pattern" == "*.aspx" && -f "${file}.cs" ]]; then
            cp -p "${file}.cs" "$dest_dir/${rel_path}.cs"
            echo "Copiado ${file}.cs para $dest_dir/${rel_path}.cs"
        fi
        
        echo "Copiado $file para $dest_dir/$rel_path"
        
        # Cria link simbólico para versão lowercase
        if [[ "$pattern" == "*.aspx" ]]; then
            cd "$dest_dir/$dir_path"
            base_name=$(basename "$rel_path")
            lower_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]')
            if [ "$base_name" != "$lower_name" ]; then
                ln -sf "$base_name" "$lower_name"
                echo "Criado link simbólico $lower_name -> $base_name em $dir_path"
            fi
            cd - > /dev/null
        fi
    done
}

# Copia os arquivos necessários preservando a estrutura
copy_files "$PROJECT_DIR" "$DEPLOY_DIR" "*.aspx"
copy_files "$PROJECT_DIR" "$DEPLOY_DIR" "*.config"

# Copia a pasta App_Code
if [ -d "$PROJECT_DIR/App_Code" ]; then
    cp -r "$PROJECT_DIR/App_Code" "$DEPLOY_DIR/"
fi

# Copia os assemblies compilados
if [ -f "$DEPLOY_DIR/TesteWebForms.dll" ]; then
    cp "$DEPLOY_DIR/TesteWebForms.dll" "$DEPLOY_DIR/bin/"
    cp "$DEPLOY_DIR/TesteWebForms.pdb" "$DEPLOY_DIR/bin/"
fi

# Define permissões
chmod -R 755 "$DEPLOY_DIR"

# Lista todos os arquivos recursivamente
echo "Lista completa de arquivos:"
find "$DEPLOY_DIR" -type f -o -type l | sort