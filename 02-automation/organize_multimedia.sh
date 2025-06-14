#!/bin/bash

# Script para organizar automáticamente screenshots y videos
# Autor: Configurado para dreamcoder08
# Fecha: $(date)

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
HOME_DIR="$HOME"
SCREENSHOT_DIR="$HOME/Multimedia/Screenshots"
VIDEO_DIR="$HOME/Multimedia/Videos"

# Función para crear directorios si no existen
create_dirs() {
    echo -e "${BLUE}[INFO]${NC} Verificando directorios..."
    mkdir -p "$SCREENSHOT_DIR" "$VIDEO_DIR"
    echo -e "${GREEN}[OK]${NC} Directorios listos"
}

# Función para organizar screenshots
organize_screenshots() {
    local moved_count=0
    echo -e "${BLUE}[INFO]${NC} Buscando screenshots en $HOME_DIR..."
    
    # Buscar archivos screenshot_*.jpg en el directorio home
    for file in "$HOME_DIR"/screenshot_*.jpg; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            echo -e "${YELLOW}[MOVE]${NC} Moviendo: $filename"
            mv "$file" "$SCREENSHOT_DIR/"
            ((moved_count++))
        fi
    done
    
    # También buscar otros patrones comunes de screenshots
    for pattern in "Screenshot_*.png" "Screenshot_*.jpg" "Captura_*.png" "Captura_*.jpg" "*.png" "*.jpg"; do
        for file in "$HOME_DIR"/$pattern; do
            if [[ -f "$file" ]] && [[ "$(dirname "$file")" == "$HOME_DIR" ]]; then
                # Verificar si es realmente una captura (por nombre o tamaño)
                filename=$(basename "$file")
                if [[ "$filename" =~ ^(screenshot|Screenshot|captura|Captura) ]] || 
                   [[ "$filename" =~ [0-9]{8}_[0-9]{6} ]] ||
                   [[ "$filename" =~ [0-9]{2}[0-9]{2}[0-9]{4}.*[0-9]{6} ]]; then
                    echo -e "${YELLOW}[MOVE]${NC} Moviendo screenshot: $filename"
                    mv "$file" "$SCREENSHOT_DIR/"
                    ((moved_count++))
                fi
            fi
        done
    done
    
    echo -e "${GREEN}[OK]${NC} Screenshots organizados: $moved_count archivos"
}

# Función para organizar videos
organize_videos() {
    local moved_count=0
    echo -e "${BLUE}[INFO]${NC} Buscando videos .mkv en $HOME_DIR..."
    
    for file in "$HOME_DIR"/*.mkv; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            echo -e "${YELLOW}[MOVE]${NC} Moviendo video: $filename"
            mv "$file" "$VIDEO_DIR/"
            ((moved_count++))
        fi
    done
    
    echo -e "${GREEN}[OK]${NC} Videos organizados: $moved_count archivos"
}

# Función para mostrar estadísticas
show_stats() {
    local screenshot_count=$(find "$SCREENSHOT_DIR" -name "*.jpg" -o -name "*.png" | wc -l)
    local video_count=$(find "$VIDEO_DIR" -name "*.mkv" | wc -l)
    
    echo -e "\n${BLUE}=== ESTADÍSTICAS ===${NC}"
    echo -e "${GREEN}Screenshots:${NC} $screenshot_count archivos"
    echo -e "${GREEN}Videos:${NC} $video_count archivos"
    echo -e "${BLUE}Ubicación:${NC}"
    echo -e "  • Screenshots: $SCREENSHOT_DIR"
    echo -e "  • Videos: $VIDEO_DIR"
}

# Función para monitoreo continuo (requiere inotify-tools)
monitor_continuous() {
    if ! command -v inotifywait &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} inotify-tools no está instalado"
        echo -e "${YELLOW}[INFO]${NC} Instala con: sudo pacman -S inotify-tools"
        echo -e "${YELLOW}[INFO]${NC} Usando modo manual por ahora..."
        return 1
    fi
    
    echo -e "${GREEN}[INFO]${NC} Iniciando monitoreo continuo..."
    echo -e "${YELLOW}[INFO]${NC} Presiona Ctrl+C para detener"
    
    inotifywait -m -e create -e moved_to "$HOME_DIR" --format '%w%f' |
    while read file; do
        if [[ "$file" =~ \.mkv$ ]]; then
            echo -e "${YELLOW}[DETECT]${NC} Nuevo video detectado: $(basename "$file")"
            sleep 1  # Esperar a que termine la escritura
            mv "$file" "$VIDEO_DIR/"
            echo -e "${GREEN}[MOVED]${NC} Video movido a $VIDEO_DIR"
        elif [[ "$file" =~ screenshot.*\.(jpg|png)$ ]] || [[ "$file" =~ \.(jpg|png)$ ]]; then
            filename=$(basename "$file")
            if [[ "$filename" =~ ^(screenshot|Screenshot|captura|Captura) ]] || 
               [[ "$filename" =~ [0-9]{8}_[0-9]{6} ]] ||
               [[ "$filename" =~ [0-9]{2}[0-9]{2}[0-9]{4}.*[0-9]{6} ]]; then
                echo -e "${YELLOW}[DETECT]${NC} Nueva captura detectada: $filename"
                sleep 1  # Esperar a que termine la escritura
                mv "$file" "$SCREENSHOT_DIR/"
                echo -e "${GREEN}[MOVED]${NC} Screenshot movido a $SCREENSHOT_DIR"
            fi
        fi
    done
}

# Función principal
main() {
    echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    ORGANIZADOR DE MULTIMEDIA         ║${NC}"
    echo -e "${BLUE}║      Screenshots y Videos MKV        ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════╝${NC}\n"
    
    create_dirs
    
    case "${1:-organize}" in
        "organize")
            organize_screenshots
            organize_videos
            show_stats
            ;;
        "monitor")
            organize_screenshots
            organize_videos
            show_stats
            echo -e "\n${BLUE}[INFO]${NC} Iniciando modo monitor..."
            monitor_continuous
            ;;
        "stats")
            show_stats
            ;;
        "help")
            echo -e "${YELLOW}Uso:${NC} $0 [organize|monitor|stats|help]"
            echo -e "\n${YELLOW}Opciones:${NC}"
            echo -e "  organize  - Organiza archivos existentes (por defecto)"
            echo -e "  monitor   - Organiza y luego monitorea continuamente"
            echo -e "  stats     - Muestra estadísticas actuales"
            echo -e "  help      - Muestra esta ayuda"
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Opción no válida: $1"
            echo -e "${YELLOW}[INFO]${NC} Usa: $0 help"
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"

