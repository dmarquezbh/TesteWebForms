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

# Compila o projeto
dotnet build -f net472

# Função para detectar e criar diretórios automaticamente
detect_directories() {
    local base_dir="$1"
    echo "Detectando diretórios..."
    
    # Encontra todos os diretórios que contêm arquivos .aspx
    find "$base_dir" -name "*.aspx" -type f -exec dirname {} \; | sort -u | while read dir; do
        # Ignora diretórios bin e obj
        if [[ "$dir" != *"/bin/"* && "$dir" != *"/obj/"* ]]; then
            rel_path=${dir#$base_dir/}
            echo "Encontrado diretório: $rel_path"
            mkdir -p "$DEPLOY_DIR/$rel_path"
            
            # Cria links simbólicos para versões em minúsculas dos diretórios
            if [ "$rel_path" != "$(echo $rel_path | tr '[:upper:]' '[:lower:]')" ]; then
                lower_path="$DEPLOY_DIR/$(echo $rel_path | tr '[:upper:]' '[:lower:]')"
                mkdir -p "$(dirname "$lower_path")"
                ln -sf "$DEPLOY_DIR/$rel_path" "$lower_path"
                echo "Criado link simbólico: $lower_path -> $DEPLOY_DIR/$rel_path"
            fi
        fi
    done
}

# Função para copiar arquivos mantendo a estrutura
copy_files() {
    local src_dir="$1"
    local dest_dir="$2"
    local pattern="$3"
    
    find "$src_dir" -name "$pattern" -type f | while read file; do
        # Ignora arquivos em bin e obj
        if [[ "$file" != *"/bin/"* && "$file" != *"/obj/"* ]]; then
            rel_path=${file#$src_dir/}
            dir_path=$(dirname "$rel_path")
            
            echo "Processando $file"
            echo "Caminho relativo: $rel_path"
            echo "Diretório: $dir_path"
            
            # Cria o diretório de destino
            mkdir -p "$dest_dir/$dir_path"
            
            # Copia o arquivo mantendo as permissões
            cp -p "$file" "$dest_dir/$rel_path"
            
            # Se for um .aspx, copia também o .cs
            if [[ "$pattern" == "*.aspx" && -f "${file}.cs" ]]; then
                cp -p "${file}.cs" "$dest_dir/${rel_path}.cs"
                echo "Copiado ${file}.cs para $dest_dir/${rel_path}.cs"
            fi
            
            # Cria links simbólicos para versões em minúsculas
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
        fi
    done
}

# Detecta e cria diretórios
detect_directories "$PROJECT_DIR"

# Copia os arquivos necessários
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

# Lista todos os arquivos
echo "Lista completa de arquivos:"
find "$DEPLOY_DIR" -type f -o -type l | sort