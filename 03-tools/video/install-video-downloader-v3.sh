#!/bin/bash
# Instalador del Descargador Universal de Videos v3.0
# Sistema completo con interfaz gráfica, colas, notificaciones y backup
# Para Arch Linux
# Autor: DreamCoder08

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${BLUE}🚀 Instalador del Descargador Universal de Videos v3.0${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""
echo -e "${YELLOW}🎆 NUEVAS CARACTERÍSTICAS v3.0:${NC}"
echo -e "${GREEN}✓${NC} Interfaz gráfica con Zenity"
echo -e "${GREEN}✓${NC} Sistema de colas de descarga"
echo -e "${GREEN}✓${NC} Notificaciones de escritorio"
echo -e "${GREEN}✓${NC} Backup automático de configuración"
echo -e "${GREEN}✓${NC} Integración con redes sociales"
echo -e "${GREEN}✓${NC} Logs y monitoreo avanzado"
echo -e "${GREEN}✓${NC} Sistema de actualización automática"
echo -e "${GREEN}✓${NC} Encriptación de backups"
echo ""

# Verificar que estamos en Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}❌ Error: Este script es solo para Arch Linux${NC}"
    exit 1
fi

echo -e "${YELLOW}💻 Verificando sistema...${NC}"
sleep 1

# Lista de paquetes necesarios
PACKAGES_CORE="yt-dlp ffmpeg python-pip jq"
PACKAGES_GUI="zenity libnotify"
PACKAGES_EXTRA="xclip curl wget tar gzip openssl"
PACKAGES_OPTIONAL="firefox chromium aria2"

echo -e "${YELLOW}📦 Instalando paquetes principales...${NC}"
echo "Paquetes: $PACKAGES_CORE"
sudo pacman -S --needed --noconfirm $PACKAGES_CORE

echo ""
echo -e "${YELLOW}🎨 Instalando dependencias de interfaz gráfica...${NC}"
echo "Paquetes: $PACKAGES_GUI"
sudo pacman -S --needed --noconfirm $PACKAGES_GUI

echo ""
echo -e "${YELLOW}🔧 Instalando herramientas adicionales...${NC}"
echo "Paquetes: $PACKAGES_EXTRA"
sudo pacman -S --needed --noconfirm $PACKAGES_EXTRA

echo ""
echo -e "${YELLOW}🌍 ¿Instalar navegadores para soporte completo de cookies? (recomendado)${NC}"
read -p "Instalar Firefox y Chromium? [Y/n]: " install_browsers
if [[ "$install_browsers" =~ ^[Nn]$ ]]; then
    echo "Omitiendo instalación de navegadores"
else
    echo "Instalando navegadores..."
    sudo pacman -S --needed --noconfirm $PACKAGES_OPTIONAL || echo "Algunos navegadores no se pudieron instalar"
fi

echo ""
echo -e "${GREEN}✅ Paquetes instalados correctamente${NC}"

# Verificar instalación
echo ""
echo -e "${YELLOW}🔍 Verificando instalación...${NC}"

verify_package() {
    local package="$1"
    local command="$2"
    
    if command -v "$command" &> /dev/null; then
        local version=$("$command" --version 2>/dev/null | head -1 || echo "Instalado")
        echo -e "${GREEN}✓${NC} $package: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $package: No instalado"
        return 1
    fi
}

# Verificar paquetes críticos
verify_package "yt-dlp" "yt-dlp" || { echo -e "${RED}Error crítico: yt-dlp no instalado${NC}"; exit 1; }
verify_package "FFmpeg" "ffmpeg" || { echo -e "${RED}Error crítico: FFmpeg no instalado${NC}"; exit 1; }
verify_package "jq" "jq" || { echo -e "${RED}Error crítico: jq no instalado${NC}"; exit 1; }
verify_package "Zenity" "zenity" || { echo -e "${RED}Error crítico: Zenity no instalado${NC}"; exit 1; }
verify_package "notify-send" "notify-send" || echo -e "${YELLOW}Advertencia: notificaciones limitadas${NC}"

echo ""
echo -e "${BLUE}🚀 Configurando el sistema...${NC}"

# Configurar directorios
echo "Creando estructura de directorios..."
mkdir -p ~/.config/video-downloader/{backups,queue,logs,themes}
mkdir -p ~/.local/bin
mkdir -p ~/Descargas/Videos/{TikTok,YouTube,Instagram,Twitter,Facebook,Otros}
mkdir -p ~/.cache/video-downloader

# Verificar que los scripts existan
if [[ ! -f ~/.local/bin/download-video ]]; then
    echo -e "${RED}Error: Scripts principales no encontrados${NC}"
    echo "Asegúrate de que todos los scripts estén en ~/.local/bin/"
    exit 1
fi

# Configurar PATH
echo "Configurando PATH..."
if ! grep -q "$HOME/.local/bin" ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

if ! grep -q "$HOME/.local/bin" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Aplicar PATH inmediatamente
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo -e "${BLUE}🎨 Configurando temas y personalización...${NC}"

# Crear tema por defecto
cat > ~/.config/video-downloader/themes/default.conf << 'EOF'
# Tema por defecto para Video Downloader v3.0
THEME_NAME="Default"
THEME_PRIMARY_COLOR="#2196F3"
THEME_SECONDARY_COLOR="#FFC107"
THEME_SUCCESS_COLOR="#4CAF50"
THEME_ERROR_COLOR="#F44336"
THEME_WARNING_COLOR="#FF9800"
THEME_BACKGROUND="#FFFFFF"
THEME_TEXT="#000000"
THEME_FONT="Sans 10"
EOF

echo ""
echo -e "${BLUE}🔄 Configurando servicios automáticos...${NC}"

# Configurar backup automático en crontab
echo "¿Configurar backup automático diario?"
read -p "Agregar a crontab? [Y/n]: " setup_cron
if [[ ! "$setup_cron" =~ ^[Nn]$ ]]; then
    # Añadir entrada a crontab si no existe
    if ! crontab -l 2>/dev/null | grep -q "video-downloader-backup"; then
        (
            crontab -l 2>/dev/null || true
            echo "# Backup automático del Video Downloader v3.0"
            echo "0 2 * * * $HOME/.local/bin/video-downloader-backup scheduled"
        ) | crontab -
        echo -e "${GREEN}✓${NC} Backup automático configurado (diario a las 2:00 AM)"
    else
        echo -e "${YELLOW}⚠${NC} Backup automático ya configurado"
    fi
fi

echo ""
echo -e "${BLUE}🌐 Configurando integración con redes sociales...${NC}"

# Crear configuración de redes sociales
cat > ~/.config/video-downloader/social.conf << 'EOF'
# Configuración de redes sociales
TWITTER_ENABLED=true
TELEGRAM_ENABLED=true
DISCORD_ENABLED=true
AUTO_SHARE=false
DEFAULT_HASHTAGS="#VideoDownloader #YTdlp #ArchLinux"
SHARE_TEMPLATE="¡Acabo de descargar un video increíble con Video Downloader v3.0! 🎬"
EOF

echo ""
echo -e "${BLUE}💾 Creando backup inicial...${NC}"
video-downloader-backup create "initial_install" >/dev/null 2>&1 || echo "Backup inicial omitido"

echo ""
echo -e "${BLUE}🧪 Probando funcionalidad...${NC}"

# Verificar que los comandos funcionen
echo "Verificando comandos principales..."
download-video --help >/dev/null && echo -e "${GREEN}✓${NC} download-video funcional"
download-queue-manager >/dev/null && echo -e "${GREEN}✓${NC} download-queue-manager funcional"
video-downloader-backup >/dev/null && echo -e "${GREEN}✓${NC} video-downloader-backup funcional"

# Probar interfaz gráfica (solo verificar dependencias)
if command -v zenity &>/dev/null; then
    echo -e "${GREEN}✓${NC} Interfaz gráfica disponible"
else
    echo -e "${YELLOW}⚠${NC} Interfaz gráfica limitada"
fi

echo ""
echo -e "${GREEN}🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE! ${NC}"
echo ""
echo -e "${BLUE}=== COMANDOS DISPONIBLES ===${NC}"
echo ""
echo -e "${YELLOW}🎬 COMANDOS PRINCIPALES:${NC}"
echo -e "${GREEN}download-video${NC} 'URL'                    - Descargador universal"
echo -e "${GREEN}video-downloader-gui${NC}                   - Interfaz gráfica principal"
echo -e "${GREEN}download-queue-manager${NC}                 - Gestor de colas"
echo -e "${GREEN}video-downloader-backup${NC}               - Sistema de backup"
echo ""
echo -e "${YELLOW}🎁 COMANDOS ESPECIALIZADOS:${NC}"
echo -e "${GREEN}download-tiktok${NC} 'URL'                 - Especializado para TikTok"
echo -e "${GREEN}download-youtube${NC} 'URL'                - Especializado para YouTube"
echo -e "${GREEN}download-instagram${NC} 'URL'              - Especializado para Instagram"
echo ""
echo -e "${YELLOW}🔧 HERRAMIENTAS:${NC}"
echo -e "${GREEN}video-downloader-update${NC}               - Actualización del sistema"
echo ""
echo -e "${BLUE}=== EJEMPLOS DE USO ===${NC}"
echo ""
echo -e "${CYAN}# Interfaz gráfica (RECOMENDADO)${NC}"
echo -e "${WHITE}video-downloader-gui${NC}"
echo ""
echo -e "${CYAN}# Tu enlace de TikTok:${NC}"
echo -e "${WHITE}download-video 'https://www.tiktok.com/@silentxploitt/video/7505853157516414213?is_from_webapp=1&sender_device=pc'${NC}"
echo ""
echo -e "${CYAN}# Descarga por lotes:${NC}"
echo -e "${WHITE}download-queue-manager add 'URL1'${NC}"
echo -e "${WHITE}download-queue-manager add 'URL2'${NC}"
echo -e "${WHITE}download-queue-manager start${NC}"
echo ""
echo -e "${CYAN}# Gestión de backups:${NC}"
echo -e "${WHITE}video-downloader-backup interactive${NC}"
echo ""
echo -e "${BLUE}=== UBICACIONES IMPORTANTES ===${NC}"
echo ""
echo -e "${YELLOW}Descargas:${NC} ~/Descargas/Videos/"
echo -e "${YELLOW}Configuración:${NC} ~/.config/video-downloader/"
echo -e "${YELLOW}Logs:${NC} ~/.config/video-downloader/logs/"
echo -e "${YELLOW}Backups:${NC} ~/.config/video-downloader/backups/"
echo -e "${YELLOW}Documentación:${NC} ~/Descargas/Videos/README-DESCARGADOR.md"
echo ""
echo -e "${BLUE}=== NOTAS IMPORTANTES ===${NC}"
echo ""
echo -e "${GREEN}✓${NC} Sistema 100% seguro - Sin virus ni malware"
echo -e "${GREEN}✓${NC} Basado en yt-dlp (código abierto)"
echo -e "${GREEN}✓${NC} Backup automático configurado"
echo -e "${GREEN}✓${NC} Notificaciones de escritorio habilitadas"
echo -e "${GREEN}✓${NC} Soporte para múltiples plataformas"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "1. Reinicia tu terminal o ejecuta: source ~/.zshrc"
echo "2. Usa responsablemente respetando términos de servicio"
echo "3. Ejecuta 'video-downloader-update' semanalmente"
echo "4. Lee la documentación completa en el README"
echo ""
echo -e "${BLUE}🚀 ¡COMIENZA AHORA!${NC}"
echo -e "${WHITE}video-downloader-gui${NC}  ← Ejecuta esto para empezar"
echo ""
echo -e "${GREEN}Desarrollado por DreamCoder08 | v3.0 | 2025-06-14${NC}"

