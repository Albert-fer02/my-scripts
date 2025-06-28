#!/bin/bash
# Script de instalación automática del Descargador Universal de Videos
# Para Arch Linux
# Autor: DreamCoder08

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}💻 Instalación del Descargador Universal de Videos${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""

# Verificar que estamos en Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}❌ Error: Este script es solo para Arch Linux${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Instalando paquetes necesarios...${NC}"

# Instalar paquetes base
echo "Instalando yt-dlp, ffmpeg, y dependencias..."
sudo pacman -S --needed --noconfirm yt-dlp ffmpeg python-pip jq

# Instalar Firefox si no está instalado (para cookies)
if ! command -v firefox &> /dev/null; then
    echo -e "${YELLOW}🌉 ¿Quieres instalar Firefox para soporte completo de cookies? (s/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Ss]$ ]]; then
        sudo pacman -S --noconfirm firefox
        echo -e "${GREEN}✅ Firefox instalado${NC}"
    fi
fi

echo -e "${GREEN}✅ Paquetes instalados correctamente${NC}"
echo ""

# Verificar instalación
echo -e "${YELLOW}🔍 Verificando instalación...${NC}"

if command -v yt-dlp &> /dev/null; then
    echo -e "${GREEN}✅ yt-dlp: $(yt-dlp --version)${NC}"
else
    echo -e "${RED}❌ yt-dlp no se instaló correctamente${NC}"
    exit 1
fi

if command -v ffmpeg &> /dev/null; then
    echo -e "${GREEN}✅ FFmpeg: Instalado${NC}"
else
    echo -e "${RED}❌ FFmpeg no se instaló correctamente${NC}"
    exit 1
fi

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✅ jq: Instalado${NC}"
else
    echo -e "${RED}❌ jq no se instaló correctamente${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ ¡Instalación completada!${NC}"
echo ""
echo -e "${BLUE}🚀 Comandos disponibles:${NC}"
echo "  • download-video 'URL'           - Descargador universal"
echo "  • download-tiktok 'URL'         - Especializado para TikTok"
echo "  • download-youtube 'URL'        - Especializado para YouTube"
echo "  • download-instagram 'URL'      - Especializado para Instagram"
echo "  • video-downloader-update       - Actualización y mantenimiento"
echo ""
echo -e "${YELLOW}📚 Lee la documentación completa en:${NC}"
echo "  ~/Descargas/Videos/README-DESCARGADOR.md"
echo ""
echo -e "${BLUE}🎉 ¡Ejemplo de uso con tu enlace de TikTok!${NC}"
echo -e "${YELLOW}download-video 'https://www.tiktok.com/@silentxploitt/video/7505853157516414213?is_from_webapp=1&sender_device=pc'${NC}"
echo ""
echo -e "${GREEN}⚠️  Importante: Reinicia tu terminal o ejecuta 'source ~/.zshrc' para usar los comandos${NC}"

