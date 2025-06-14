#!/bin/bash

# ============================================================================
# NOMBRE DEL SCRIPT: [NOMBRE_AQUI]
# DESCRIPCIÓN: [DESCRIPCIÓN_BREVE]
# AUTOR: dreamcoder08
# FECHA: $(date '+%Y-%m-%d')
# VERSIÓN: 1.0
# ============================================================================

# Configuración estricta para evitar errores
set -euo pipefail

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Variables del script
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")" 

# ============================================================================
# FUNCIONES DE UTILIDAD
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

show_usage() {
    cat << EOF
${BOLD}Uso:${NC}
  $SCRIPT_NAME [opciones]

${BOLD}Opciones:${NC}
  -h, --help     Mostrar esta ayuda
  -v, --version  Mostrar versión
  
${BOLD}Ejemplos:${NC}
  $SCRIPT_NAME
  $SCRIPT_NAME --help
EOF
}

show_version() {
    echo "$SCRIPT_NAME versión 1.0"
}

# ============================================================================
# FUNCIONES PRINCIPALES
# ============================================================================

main_function() {
    log_info "Iniciando $SCRIPT_NAME..."
    
    # Tu código principal aquí
    echo "¡Hola desde el template básico!"
    
    log_success "Proceso completado exitosamente"
}

# ============================================================================
# MANEJO DE ARGUMENTOS
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            *)
                log_error "Opción desconocida: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

main() {
    parse_arguments "$@"
    main_function
}

# ============================================================================
# PUNTO DE ENTRADA
# ============================================================================

# Ejecutar solo si el script se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

