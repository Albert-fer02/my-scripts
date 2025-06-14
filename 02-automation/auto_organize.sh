#!/bin/bash

# Script simple para cron - Organiza multimedia automáticamente
# Se ejecuta cada minuto via cron

HOME_DIR="$HOME"
SCREENSHOT_DIR="$HOME/Multimedia/Screenshots"
VIDEO_DIR="$HOME/Multimedia/Videos"
LOG_FILE="$HOME/.multimedia_organizer.log"

# Crear directorios si no existen
mkdir -p "$SCREENSHOT_DIR" "$VIDEO_DIR"

# Función para logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Organizar screenshots
for file in "$HOME_DIR"/screenshot_*.jpg "$HOME_DIR"/screenshot_*.png; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        mv "$file" "$SCREENSHOT_DIR/"
        log "Screenshot movido: $filename"
    fi
done

# Organizar videos .mkv
for file in "$HOME_DIR"/*.mkv; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        mv "$file" "$VIDEO_DIR/"
        log "Video movido: $filename"
    fi
done

# Limpiar log si es muy grande (mantener solo últimas 100 líneas)
if [[ -f "$LOG_FILE" ]] && [[ $(wc -l < "$LOG_FILE") -gt 100 ]]; then
    tail -100 "$LOG_FILE" > "${LOG_FILE}.tmp"
    mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

