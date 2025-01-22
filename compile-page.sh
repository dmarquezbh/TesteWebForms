#!/bin/bash

# Configurações
MONO_PATH="/usr/lib/mono/4.7.2-api"
OUTPUT_DIR="bin/Debug/net472"
TEMP_DIR="/tmp/aspnet-temp"

# Função para compilar uma página específica
compile_page() {
    local page_name=$1
    local page_path="${page_name}.aspx"
    local cs_path="${page_name}.aspx.cs"
    local output_dll="${TEMP_DIR}/${page_name}_aspx.dll"

    echo "Compilando ${page_path}..."

    # Cria diretório temporário
    mkdir -p "${TEMP_DIR}"

    # Compila a página
    mcs -target:library \
        -debug+ \
        -nowarn:0169 \
        -out:"${output_dll}" \
        -r:System.dll \
        -r:System.Web.dll \
        -r:System.Web.Extensions.dll \
        -r:System.Data.dll \
        -r:System.Configuration.dll \
        -r:System.Drawing.dll \
        -r:System.Xml.dll \
        -r:System.Design.dll \
        -r:System.Web.Extensions.Design.dll \
        -r:"${OUTPUT_DIR}/bin/TesteWebForms.dll" \
        "${cs_path}"

    if [ $? -eq 0 ]; then
        # Copia os arquivos necessários
        mkdir -p "${OUTPUT_DIR}"
        cp -f "${output_dll}" "${OUTPUT_DIR}/"
        cp -f "${page_path}" "${OUTPUT_DIR}/"
        cp -f "${cs_path}" "${OUTPUT_DIR}/"
        
        # Cria link simbólico para versão lowercase
        cd "${OUTPUT_DIR}"
        page_lower=$(echo "${page_name}.aspx" | tr '[:upper:]' '[:lower:]')
        if [ "${page_name}.aspx" != "${page_lower}" ]; then
            ln -sf "${page_name}.aspx" "${page_lower}"
        fi
        cd - > /dev/null
        
        echo "Página compilada com sucesso!"
        echo "Arquivos gerados em ${OUTPUT_DIR}"
    else
        echo "Erro na compilação!"
        exit 1
    fi
}

# Verifica se um nome de página foi fornecido
if [ -z "$1" ]; then
    echo "Uso: ./compile-page.sh <nome-da-pagina>"
    echo "Exemplo: ./compile-page.sh Default"
    exit 1
fi

# Remove extensão .aspx se fornecida
page_name=$(echo "$1" | sed 's/\.aspx$//')

# Verifica se os arquivos existem
if [ ! -f "${page_name}.aspx" ] || [ ! -f "${page_name}.aspx.cs" ]; then
    echo "Erro: Arquivos ${page_name}.aspx e/ou ${page_name}.aspx.cs não encontrados!"
    exit 1
fi

# Compila a página
compile_page "${page_name}"