#!/bin/bash

# ===============================================
# Script de Instalación y Configuración Automática
# Autor: Claude
# Fecha: 2024
# Descripción: Script para instalar y configurar Zsh, Kitty, Fastfetch
# y otras herramientas de forma automática
# ===============================================

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# Función para mostrar mensajes
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Función para crear directorios si no existen
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_info "Directorio creado: $1"
    fi
}

# Función para hacer backup de archivos existentes
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup_path="$BACKUP_DIR/$(basename "$file")"
        create_dir "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        log_info "Backup creado: $backup_path"
    fi
}

# Función para instalar dependencias
install_dependencies() {
    log_info "Instalando dependencias necesarias..."
    
    # Lista de paquetes necesarios
    packages=(
        "zsh"
        "git"
        "curl"
        "wget"
        "kitty"
        "fastfetch"
        "neovim"
        "fzf"
        "fd"
        "ripgrep"
        "bat"
        "eza"
        "jq"
        "lsof"
        "fonts-powerline"  # Para los iconos de Powerlevel10k
        "fonts-jetbrains-mono"  # Para la fuente JetBrains Mono
    )

    # Instalar paquetes
    for pkg in "${packages[@]}"; do
        if ! command_exists "$pkg"; then
            log_info "Instalando $pkg..."
            sudo apt install -y "$pkg" || log_error "Error al instalar $pkg"
        else
            log_warn "$pkg ya está instalado"
        fi
    done
}

# Función para instalar Oh My Zsh y plugins
install_zsh_config() {
    log_info "Configurando Zsh..."

    # Backup del .zshrc existente
    backup_file "$HOME/.zshrc"

    # Instalar Oh My Zsh si no existe
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_error "Error al instalar Oh My Zsh"
    fi

    # Instalar Powerlevel10k
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        log_info "Instalando Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || log_error "Error al instalar Powerlevel10k"
    fi

    # Instalar plugins de Zsh
    ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
    )

    for plugin in "${plugins[@]}"; do
        if [ ! -d "$ZSH_CUSTOM_DIR/plugins/$plugin" ]; then
            case "$plugin" in
                "zsh-autosuggestions")
                    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/$plugin"
                    ;;
                "zsh-syntax-highlighting")
                    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/$plugin"
                    ;;
                "zsh-completions")
                    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM_DIR/plugins/$plugin"
                    ;;
            esac
        fi
    done

    # Copiar .zshrc personalizado
    if [ -f "$SCRIPT_DIR/.zshrc" ]; then
        cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc" || log_error "Error al copiar .zshrc"
        log_info "Configuración personalizada de Zsh instalada"
    else
        log_error "No se encontró el archivo .zshrc en $SCRIPT_DIR"
    fi

    # Crear archivo p10k.zsh si no existe
    if [ ! -f "$HOME/.p10k.zsh" ]; then
        touch "$HOME/.p10k.zsh"
        log_info "Archivo .p10k.zsh creado"
    fi
}

# Función para configurar Kitty
install_kitty_config() {
    log_info "Configurando Kitty Terminal..."
    
    # Backup de la configuración existente
    backup_file "$HOME/.config/kitty/kitty.conf"
    backup_file "$HOME/.config/kitty/user.conf"
    
    # Crear directorio de configuración
    create_dir "$HOME/.config/kitty"
    
    # Copiar configuración de Kitty
    if [ -f "$SCRIPT_DIR/kitty/kitty.conf" ]; then
        cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf" || log_error "Error al copiar kitty.conf"
        log_info "Configuración personalizada de Kitty instalada"
    else
        log_error "No se encontró el archivo kitty.conf en $SCRIPT_DIR/kitty/"
    fi
    
    # Crear archivo de configuración de usuario si no existe
    if [ ! -f "$HOME/.config/kitty/user.conf" ]; then
        touch "$HOME/.config/kitty/user.conf"
        log_info "Archivo user.conf creado en ~/.config/kitty/"
    fi
}

# Función para configurar Fastfetch
install_fastfetch_config() {
    log_info "Configurando Fastfetch..."
    
    # Backup de la configuración existente
    backup_file "$HOME/.config/fastfetch/config.jsonc"
    
    # Crear directorio de configuración
    create_dir "$HOME/.config/fastfetch"
    
    # Copiar configuración de Fastfetch
    if [ -f "$SCRIPT_DIR/fastfetch/config.jsonc" ]; then
        cp "$SCRIPT_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc" || log_error "Error al copiar config.jsonc"
        log_info "Configuración personalizada de Fastfetch instalada"
    else
        log_error "No se encontró el archivo config.jsonc en $SCRIPT_DIR/fastfetch/"
    fi
    
    # Crear directorio para logos si no existe
    create_dir "$HOME/.config/fastfetch/logos"
    
    # Copiar logo personalizado si existe
    if [ -f "$SCRIPT_DIR/fastfetch/Aizen.jpg" ]; then
        cp "$SCRIPT_DIR/fastfetch/Aizen.jpg" "$HOME/.config/fastfetch/Aizen.jpg"
        log_info "Logo personalizado de Fastfetch instalado"
    fi
}

# Función para verificar la estructura de directorios
verify_directory_structure() {
    log_info "Verificando estructura de directorios..."
    
    local required_files=(
        ".zshrc"
        "kitty/kitty.conf"
        "fastfetch/config.jsonc"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$file" ]; then
            log_error "No se encontró el archivo requerido: $file"
        fi
    done
    
    log_info "Estructura de directorios verificada correctamente"
}

# Función principal
main() {
    log_info "Iniciando instalación y configuración..."
    
    # Verificar si el script se ejecuta como root
    if [ "$EUID" -eq 0 ]; then
        log_error "No ejecutes este script como root"
    fi
    
    # Verificar estructura de directorios
    verify_directory_structure
    
    # Crear directorio de backup
    create_dir "$BACKUP_DIR"
    log_info "Directorio de backup creado: $BACKUP_DIR"
    
    # Actualizar sistema
    log_info "Actualizando sistema..."
    sudo apt update && sudo apt upgrade -y || log_error "Error al actualizar el sistema"
    
    # Instalar dependencias
    install_dependencies
    
    # Instalar configuraciones
    install_zsh_config
    install_kitty_config
    install_fastfetch_config
    
    # Establecer Zsh como shell por defecto
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Estableciendo Zsh como shell por defecto..."
        chsh -s "$(which zsh)" || log_error "Error al cambiar el shell por defecto"
    fi
    
    log_info "
¡Instalación completada! 
Para que los cambios surtan efecto:
1. Cierra y vuelve a abrir tu terminal
2. Si es la primera vez que usas Zsh, se te pedirá configurar Powerlevel10k
3. Ejecuta 'source ~/.zshrc' para recargar la configuración

Tus configuraciones anteriores han sido respaldadas en: $BACKUP_DIR

¡Disfruta de tu nueva configuración!
"
}

# Ejecutar script
main "$@" 