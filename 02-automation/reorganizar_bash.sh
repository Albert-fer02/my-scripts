#!/bin/bash

# =============================================================================
# Script de Reorganización - Carpeta Bash en Obsidian
# =============================================================================
# Descripción: Reorganiza archivos de Bash eliminando números largos
# Autor: Assistant
# Uso: ./reorganizar_bash.sh
# Ejecutar desde la carpeta padre de "00 - Bash"
# =============================================================================

set -euo pipefail  # Configuración estricta para evitar errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables de configuración
OLD_DIR="00 - Bash"
NEW_DIR="Bash"
BACKUP_DIR="backup_bash_$(date +%Y%m%d_%H%M%S)"

# Función para logging
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar prerrequisitos
check_prerequisites() {
    log "Verificando prerrequisitos..."
    
    if [[ ! -d "$OLD_DIR" ]]; then
        error "No se encontró la carpeta '$OLD_DIR' en el directorio actual"
        error "Directorio actual: $(pwd)"
        error "Asegúrate de ejecutar el script desde la carpeta correcta"
        exit 1
    fi
    
    if [[ -d "$NEW_DIR" ]]; then
        warning "La carpeta '$NEW_DIR' ya existe"
        read -p "¿Deseas continuar? Esto puede sobrescribir archivos (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Operación cancelada por el usuario"
            exit 0
        fi
    fi
    
    success "Prerrequisitos verificados"
}

# Función para crear backup
create_backup() {
    log "Creando backup de la carpeta original..."
    cp -r "$OLD_DIR" "$BACKUP_DIR"
    success "Backup creado: $BACKUP_DIR"
}

# Función para crear estructura de carpetas
create_directory_structure() {
    log "Creando nueva estructura de carpetas..."
    
    mkdir -p "$NEW_DIR"/{01-Fundamentos,02-Entrada-Salida,03-Control-Flujo,04-Datos-Variables,05-Funciones-Avanzado,Templates,Ejemplos,Referencias}
    
    success "Estructura de carpetas creada"
}

# Función para mover archivos
move_files() {
    log "Reorganizando archivos..."
    
    # Array asociativo con mapeo de archivos
    declare -A file_mapping=(
        # 01-Fundamentos
        ["00_00_00_Introduccion_al_curso_de_Bash_Scripting.md"]="01-Fundamentos/introduccion-bash-scripting.md"
        ["01_00_56_Herramientas.md"]="01-Fundamentos/herramientas-desarrollo.md"
        ["02_03_17_Hello_World.md"]="01-Fundamentos/hello-world.md"
        ["04_14_01_Comentarios.md"]="01-Fundamentos/comentarios.md"
        
        # 02-Entrada-Salida
        ["03_10_01_Guardar_Salida.md"]="02-Entrada-Salida/guardar-salida.md"
        ["05_16_40_Delimitador_cat.md"]="02-Entrada-Salida/delimitador-cat.md"
        ["06_19_28_read.md"]="02-Entrada-Salida/lectura-input.md"
        ["13_01_00_53_stdin.md"]="02-Entrada-Salida/stdin-manejo.md"
        ["14_01_04_21_sterr_y_stdout.md"]="02-Entrada-Salida/stderr-stdout.md"
        ["15_01_10_29_pipes.md"]="02-Entrada-Salida/pipes-redirecciones.md"
        
        # 03-Control-Flujo
        ["07_23_01_condicionales.md"]="03-Control-Flujo/condicionales.md"
        ["08_32_04_operadores.md"]="03-Control-Flujo/operadores.md"
        ["09_38_31_case.md"]="03-Control-Flujo/case-switch.md"
        ["10_42_16_Loops.md"]="03-Control-Flujo/loops-bucles.md"
        ["11_51_23_break_y_continue.md"]="03-Control-Flujo/break-continue.md"
        
        # 04-Datos-Variables
        ["12_55_30_Argumentos.md"]="04-Datos-Variables/argumentos-parametros.md"
        ["16_01_18_00_strings.md"]="04-Datos-Variables/strings-cadenas.md"
        ["17_01_28_02_numbers.md"]="04-Datos-Variables/numbers-numeros.md"
        ["18_01_34_25_declare.md"]="04-Datos-Variables/declare-variables.md"
        ["19_01_36_48_arrays.md"]="04-Datos-Variables/arrays-listas.md"
        
        # 05-Funciones-Avanzado
        ["20_01_51_55_functions.md"]="05-Funciones-Avanzado/functions-funciones.md"
        ["21_02_00_42_directories.md"]="05-Funciones-Avanzado/directories-directorios.md"
        ["22_02_10_17_curl.md"]="05-Funciones-Avanzado/curl-web-requests.md"
        ["23_02_18_29_debugging_Bash_Scripts.md"]="05-Funciones-Avanzado/debugging-scripts.md"
    )
    
    # Mover archivos según el mapeo
    local moved_count=0
    local total_files=${#file_mapping[@]}
    
    for old_file in "${!file_mapping[@]}"; do
        local old_path="$OLD_DIR/$old_file"
        local new_path="$NEW_DIR/${file_mapping[$old_file]}"
        
        if [[ -f "$old_path" ]]; then
            mv "$old_path" "$new_path"
            success "Movido: $old_file → ${file_mapping[$old_file]}"
            ((moved_count++))
        else
            warning "Archivo no encontrado: $old_file"
        fi
    done
    
    log "Archivos procesados: $moved_count/$total_files"
    
    # Mover archivos restantes (como index.md o carpeta A - Basic Concepts)
    if [[ -f "$OLD_DIR/index.md" ]]; then
        mv "$OLD_DIR/index.md" "$NEW_DIR/index-old.md"
        success "Movido: index.md → index-old.md"
    fi
    
    if [[ -d "$OLD_DIR/A - Basic Concepts" ]]; then
        mv "$OLD_DIR/A - Basic Concepts" "$NEW_DIR/Referencias/conceptos-basicos-antiguos"
        success "Movida carpeta: A - Basic Concepts → Referencias/conceptos-basicos-antiguos"
    fi
}

# Función para crear MOC (Map of Content) nuevo
create_moc() {
    log "Creando nuevo Map of Content (index.md)..."
    
    cat > "$NEW_DIR/index.md" << 'EOF'
# 🐚 Bash Scripting - Mapa de Contenido

## 🎯 Ruta de Aprendizaje Recomendada

### 🏁 Nivel Principiante
1. [[introduccion-bash-scripting]] - Introducción al curso
2. [[herramientas-desarrollo]] - Herramientas necesarias
3. [[hello-world]] - Tu primer script
4. [[comentarios]] - Documentando tu código

### 📊 Nivel Intermedio
5. [[guardar-salida]] - Redirección de output
6. [[lectura-input]] - Lectura de datos del usuario
7. [[condicionales]] - Estructuras if/else
8. [[operadores]] - Operadores lógicos y aritméticos
9. [[loops-bucles]] - Bucles for/while

### 🚀 Nivel Avanzado
10. [[functions-funciones]] - Creación de funciones
11. [[arrays-listas]] - Manejo de arrays
12. [[debugging-scripts]] - Depuración de scripts
13. [[curl-web-requests]] - Peticiones web

## 📚 Organización por Categorías

### [[01-Fundamentos]]
- [[introduccion-bash-scripting]]
- [[herramientas-desarrollo]]
- [[hello-world]]
- [[comentarios]]

### [[02-Entrada-Salida]]
- [[guardar-salida]]
- [[delimitador-cat]]
- [[lectura-input]]
- [[stdin-manejo]]
- [[stderr-stdout]]
- [[pipes-redirecciones]]

### [[03-Control-Flujo]]
- [[condicionales]]
- [[operadores]]
- [[case-switch]]
- [[loops-bucles]]
- [[break-continue]]

### [[04-Datos-Variables]]
- [[argumentos-parametros]]
- [[strings-cadenas]]
- [[numbers-numeros]]
- [[declare-variables]]
- [[arrays-listas]]

### [[05-Funciones-Avanzado]]
- [[functions-funciones]]
- [[directories-directorios]]
- [[curl-web-requests]]
- [[debugging-scripts]]

## 🛠️ Recursos Rápidos
- [[Templates/template-script-basico]]
- [[Templates/template-script-avanzado]]
- [[Referencias/comandos-esenciales]]
- [[Referencias/buenas-practicas]]

## 📊 Estado de Reorganización
- ✅ Archivos reorganizados
- ✅ Estructura nueva creada
- ✅ MOC actualizado
- 🔄 Pendiente: Actualizar enlaces internos

## 🏷️ Tags Principales
`#bash` `#scripting` `#linux` `#automation` `#shell` `#reorganizado`

---
*Última reorganización: $(date '+%Y-%m-%d %H:%M:%S')*
EOF
    
    success "MOC creado: $NEW_DIR/index.md"
}

# Función para crear templates
create_templates() {
    log "Creando plantillas..."
    
    # Template básico
    cat > "$NEW_DIR/Templates/template-script-basico.md" << 'EOF'
# Template - Script Básico

```bash
#!/bin/bash

# Título: [NOMBRE_DEL_SCRIPT]
# Descripción: [DESCRIPCIÓN_BREVE]
# Autor: [TU_NOMBRE]
# Fecha: $(date +%Y-%m-%d)

# Configuración estricta
set -euo pipefail

# Variables principales
readonly SCRIPT_NAME="$(basename "$0")"

# Función principal
main() {
    echo "Hola desde $SCRIPT_NAME"
    # Tu código aquí
}

# Ejecutar función principal
main "$@"
```

## Elementos incluidos:
- Shebang correcto
- Metadatos del script
- Configuración estricta
- Estructura básica
- Función principal

#bash #template #básico
EOF

    success "Template básico creado"
}

# Función para mostrar resumen final
show_summary() {
    echo
    echo "============================================="
    success "🎉 REORGANIZACIÓN COMPLETADA 🎉"
    echo "============================================="
    echo
    log "📁 Nueva estructura creada en: $NEW_DIR"
    log "💾 Backup disponible en: $BACKUP_DIR"
    log "📋 MOC creado: $NEW_DIR/index.md"
    log "📝 Templates creados en: $NEW_DIR/Templates/"
    echo
    warning "📌 PRÓXIMOS PASOS:"
    echo "   1. Revisar archivos movidos"
    echo "   2. Actualizar enlaces internos en Obsidian"  
    echo "   3. Eliminar carpeta antigua si todo está correcto"
    echo "   4. Actualizar tags en archivos individuales"
    echo
    log "🗂️ Para ver la estructura completa:"
    echo "   tree $NEW_DIR"
    echo
}

# Función principal
main() {
    echo "============================================="
    log "🚀 INICIANDO REORGANIZACIÓN DE BASH VAULT"
    echo "============================================="
    echo
    
    check_prerequisites
    create_backup
    create_directory_structure
    move_files
    create_moc
    create_templates
    show_summary
}

# Ejecutar solo si se ejecuta directamente (no si se hace source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi