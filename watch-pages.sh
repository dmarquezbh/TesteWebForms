#!/bin/bash
# watch-pages.sh

# Configurações
WATCH_DIR="."
EXTENSIONS=".aspx .aspx.cs"

# Função para compilar uma página
compile_modified_page() {
    local file=$1
    local base_name=$(basename "$file")
    local page_name="${base_name%.*}"
    
    # Remove extensão .aspx ou .aspx.cs
    page_name=$(echo "$page_name" | sed 's/\.aspx$//')
    
    echo "Alteração detectada em $file"
    ./compile-page.sh "$page_name"
}

# Verifica se inotifywait está instalado
if ! command -v inotifywait &> /dev/null; then
    echo "Instalando inotify-tools..."
    sudo apt-get update
    sudo apt-get install -y inotify-tools
fi

echo "Monitorando alterações em arquivos .aspx e .aspx.cs..."

# Monitora alterações
inotifywait -m -r -e modify,create,delete --format '%w%f' "$WATCH_DIR" | while read file
do
    # Verifica se o arquivo modificado é .aspx ou .aspx.cs
    for ext in $EXTENSIONS; do
        if [[ "$file" == *"$ext" ]]; then
            compile_modified_page "$file"
            break
        fi
    done
done