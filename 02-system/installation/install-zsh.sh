#!/usr/bin/env zsh
# ░█▀▀░█▀█░█░█░█▀▀░▀█▀░█▀▀░█▀▄░▀█▀░▀█▀░█▀█░█▀█
# ░█▀▀░█░█░▀▄▀░█▀▀░░█░░█▀▀░█▀▄░░█░░░█░░█░█░█░█
# ░▀░░░▀▀▀░░▀░░▀▀▀░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀
# Instalador automático para la configuración de Zsh
# github.com/voidblade/dotfiles

# -------------------------------------------------------------
# Configuración inicial
# -------------------------------------------------------------

# Asegurar que este script se ejecute como Zsh, no Bash
if [ -z "$ZSH_VERSION" ]; then
  exec zsh "$0" "$@"
fi

# Activar modo XTrace para depuración (descomentado si es necesario)
# set -x

# Manejar señales de interrupción de manera elegante
trap 'echo "\n❌ Instalación interrumpida" && exit 1' INT TERM

# Colores para mensajes con formato más legible
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # Sin color

# -------------------------------------------------------------
# Funciones de utilidad
# -------------------------------------------------------------

# Función mejorada para mensajes
print_message() {
  local color=$1
  local type=$2
  local message=$3
  echo -e "${color}${BOLD}${type}${NC} ${message}"
}

info() { print_message "$BLUE" "INFO" "$1"; }
success() { print_message "$GREEN" "✓" "$1"; }
warning() { print_message "$YELLOW" "⚠️" "$1"; }
error() { print_message "$RED" "❌" "$1"; }
task() { print_message "$MAGENTA" "»" "$1"; }

# Función para verificar si un comando existe
check_command() {
  command -v "$1" &>/dev/null
}

# Función mejorada para verificar e instalar paquetes
install_pkg() {
  local pkg=$1
  local desc=${2:-$1} # Descripción por defecto es el nombre del paquete
  task "Verificando $desc..."
  
  if ! pacman -Qi $pkg &>/dev/null; then
    info "Instalando $desc..."
    if sudo pacman -S --noconfirm $pkg; then
      success "$desc instalado correctamente"
    else
      error "Error al instalar $pkg"
      return 1
    fi
  else
    success "$desc ya está instalado"
  fi
}

# Función mejorada para instalar desde AUR
install_aur() {
  local pkg=$1
  local desc=${2:-$1} # Descripción por defecto es el nombre del paquete
  task "Verificando $desc desde AUR..."
  
  if ! check_command yay; then
    error "yay no está instalado. No se puede instalar paquetes AUR."
    return 1
  fi
  
  if ! yay -Qi $pkg &>/dev/null; then
    info "Instalando $desc desde AUR..."
    if yay -S --noconfirm $pkg; then
      success "$desc instalado correctamente"
    else
      error "Error al instalar $pkg desde AUR"
      return 1
    fi
  else
    success "$desc ya está instalado"
  fi
}

# Función para clonar repositorios con verificación de errores
clone_repo() {
  local repo=$1
  local dest=$2
  local branch=${3:-master}
  
  if [[ -d "$dest" ]]; then
    success "Repositorio ya existe en $dest"
    # Opcionalmente actualizar el repo
    if [[ "$4" == "update" ]]; then
      (cd "$dest" && git pull origin $branch)
    fi
  else
    info "Clonando $repo en $dest..."
    if git clone --depth=1 -b $branch "$repo" "$dest"; then
      success "Repositorio clonado correctamente"
    else
      error "Error al clonar repositorio"
      return 1
    fi
  fi
}

# Crear directorio si no existe
ensure_dir() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1" && success "Directorio $1 creado" || error "No se pudo crear $1"
  fi
}

# Función para hacer respaldo de archivo
backup_file() {
  local file=$1
  if [[ -f "$file" ]]; then
    local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$file" "$backup" && success "Respaldo creado: $backup" || error "No se pudo crear respaldo de $file"
  fi
}

# Mostrar progreso de instalación
show_progress() {
  local current=$1
  local total=$2
  local desc=$3
  local percent=$((current * 100 / total))
  
  # Barra de progreso visual
  local completed=$((percent / 2))
  local remaining=$((50 - completed))
  
  printf "${BOLD}[${BLUE}"
  printf "%${completed}s" | tr ' ' '='
  printf "${NC}${BOLD}>"
  printf "%${remaining}s" | tr ' ' ' '
  printf "${BOLD}] ${CYAN}%3d%%${NC} ${desc}\r" $percent
}

# -------------------------------------------------------------
# Verificaciones previas
# -------------------------------------------------------------

# Verificar si estamos en Arch Linux o derivados
if ! grep -qE "Arch Linux|Manjaro|EndeavourOS" /etc/os-release; then
  error "Este script está diseñado para Arch Linux y derivados."
  exit 1
fi

# -------------------------------------------------------------
# Inicio de instalación
# -------------------------------------------------------------

echo
echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║         INSTALADOR DE CONFIGURACIÓN ZSH            ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════╝${NC}"
echo

# Actualizar sistema antes de comenzar
task "Actualizando base de datos de paquetes..."
if sudo pacman -Syy --noconfirm; then
  success "Base de datos actualizada"
else
  warning "No se pudo actualizar la base de datos de paquetes"
fi

# Preparar para la instalación
total_steps=17
current_step=0

# -------------------------------------------------------------
# Instalación de paquetes básicos
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando paquetes esenciales"
install_pkg zsh "Zsh Shell"
install_pkg git "Git"
install_pkg curl "cURL"

# -------------------------------------------------------------
# Instalación de herramientas de desarrollo
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando editor y terminales"
install_pkg neovim "Neovim"
install_pkg wezterm "WezTerm (terminal)"
install_pkg firefox "Firefox"

# -------------------------------------------------------------
# Instalación de herramientas modernas CLI
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando utilidades modernas"
install_pkg eza "eza (reemplazo moderno de ls)"
install_pkg bat "bat (reemplazo moderno de cat)"
install_pkg fd "fd (reemplazo moderno de find)"
install_pkg ripgrep "ripgrep (reemplazo moderno de grep)"

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando herramientas de monitoreo"
install_pkg duf "duf (reemplazo moderno de df)"
install_pkg dust "dust (reemplazo moderno de du)"
install_pkg btop "btop (monitor de sistema)"
install_pkg bandwhich "bandwhich (monitor de red)"

# -------------------------------------------------------------
# Instalación de YAY (AUR Helper)
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Verificando gestor AUR"
if ! check_command yay; then
  task "Instalando yay (gestor AUR)..."
  
  # Asegurar que tenemos las herramientas de compilación
  install_pkg base-devel "Herramientas de compilación"
  
  # Clonar e instalar yay
  if [[ -d "/tmp/yay" ]]; then
    rm -rf "/tmp/yay"
  fi
  
  if git clone https://aur.archlinux.org/yay.git /tmp/yay; then
    (cd /tmp/yay && makepkg -si --noconfirm) && success "yay instalado correctamente" || error "Error al instalar yay"
  else
    error "No se pudo clonar el repositorio de yay"
  fi
else
  success "yay ya está instalado"
fi

# -------------------------------------------------------------
# Instalación de paquetes AUR
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando paquetes AUR"
install_pkg fzf "fzf (búsqueda difusa)"
install_aur nvm "nvm (gestor de versiones Node.js)"
install_aur ttf-meslo-nerd-font-powerlevel10k "Fuentes para Powerlevel10k"

# -------------------------------------------------------------
# Configuración de Oh My Zsh
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Configurando Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  task "Instalando Oh My Zsh..."
  
  # Descargar el instalador pero NO ejecutarlo con sh (necesitamos más control)
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/omz-install.sh
  chmod +x /tmp/omz-install.sh
  
  # Ejecutar instalador sin cambiar shell y sin interacción
  ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no /tmp/omz-install.sh --unattended
  
  success "Oh My Zsh instalado correctamente"
else
  success "Oh My Zsh ya está instalado"
fi

# -------------------------------------------------------------
# Instalación de Powerlevel10k
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando tema Powerlevel10k"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
clone_repo "https://github.com/romkatv/powerlevel10k.git" "$P10K_DIR" "master" "update"

# -------------------------------------------------------------
# Instalación de plugins de Zsh
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Instalando plugins de Zsh"
plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
ensure_dir "$plugins_dir"

# Definir plugins a instalar
declare -A plugins
plugins[zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
plugins[zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
plugins[zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"

# Instalar cada plugin
for plugin in "${(@k)plugins}"; do
  task "Instalando plugin $plugin..."
  clone_repo "${plugins[$plugin]}" "$plugins_dir/$plugin" "master" "update"
done

# -------------------------------------------------------------
# Configuración de FZF
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Configurando FZF"
if [[ ! -f "$HOME/.fzf.zsh" ]]; then
  task "Configurando FZF..."
  if check_command fzf-share; then
    # Si fzf fue instalado mediante pacman
    install_pkg fzf-extras "Extras para FZF"
  else
    # Si fzf fue instalado por otros medios, usar el instalador propio
    if [[ -d "$HOME/.fzf" ]]; then
      (cd "$HOME/.fzf" && git pull && ./install --all --no-bash --no-fish)
    else
      git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" && \
        "$HOME/.fzf/install" --all --no-bash --no-fish
    fi
  fi
  success "FZF configurado correctamente"
else
  success "FZF ya está configurado"
fi

# -------------------------------------------------------------
# Creación de estructura de directorios
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Creando estructura de directorios"
ensure_dir "$HOME/.cache/zsh"
ensure_dir "$HOME/.local/share/zsh"
ensure_dir "$HOME/.config/zsh"

# -------------------------------------------------------------
# Instalación del archivo de configuración .zshrc
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Preparando archivo de configuración"
if [[ -f "$HOME/.zshrc" ]]; then
  backup_file "$HOME/.zshrc"
fi

# URL del archivo de configuración (cambia esto según tu repo)
ZSHRC_URL="https://raw.githubusercontent.com/voidblade/dotfiles/main/.zshrc"

task "Descargando archivo de configuración..."
if curl -fsSL "$ZSHRC_URL" -o "$HOME/.zshrc.new"; then
  success "Archivo de configuración descargado correctamente"
  mv "$HOME/.zshrc.new" "$HOME/.zshrc"
  chmod 644 "$HOME/.zshrc"
else
  error "No se pudo descargar el archivo de configuración"
  # Crear archivo básico como fallback
  cat > "$HOME/.zshrc" << 'EOL'
# Configuración básica
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git archlinux zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL
  warning "Se ha creado un archivo de configuración básico"
fi

# -------------------------------------------------------------
# Configuración de Powerlevel10k
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Preparando configuración Powerlevel10k"
if [[ ! -f "$HOME/.p10k.zsh" ]]; then
  task "Creando archivo base de Powerlevel10k..."
  # Crear un archivo básico p10k para prevenir errores
  cat > "$HOME/.p10k.zsh" << 'EOL'
# Configuración básica temporal de Powerlevel10k
# Un asistente de configuración se lanzará la primera vez que inicies Zsh
# Este archivo será reemplazado automáticamente
EOL
  success "Archivo base de Powerlevel10k creado"
else
  success "Configuración de Powerlevel10k ya existe"
fi

# -------------------------------------------------------------
# Configuración de Neovim
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Verificando configuración de Neovim"
if [[ ! -d "$HOME/.config/nvim" ]]; then
  task "Preparando configuración básica de Neovim..."
  ensure_dir "$HOME/.config/nvim"
  cat > "$HOME/.config/nvim/init.vim" << 'EOL'
" Configuración básica de Neovim
set number
set relativenumber
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set termguicolors
syntax enable
EOL
  success "Configuración básica de Neovim creada"
else
  success "Configuración de Neovim ya existe"
fi

# -------------------------------------------------------------
# Configuración de Zsh como shell predeterminado
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Configurando Zsh como shell predeterminado"
ZSHBIN=$(which zsh)
if [[ "$SHELL" != "$ZSHBIN" ]]; then
  task "Cambiando shell predeterminado a Zsh..."
  if grep -q "$ZSHBIN" /etc/shells; then
    chsh -s "$ZSHBIN" && success "Shell cambiado a Zsh" || error "No se pudo cambiar el shell"
  else
    warning "$ZSHBIN no está en /etc/shells"
    echo "$ZSHBIN" | sudo tee -a /etc/shells > /dev/null
    chsh -s "$ZSHBIN" && success "Shell cambiado a Zsh" || error "No se pudo cambiar el shell"
  fi
else
  success "Zsh ya es tu shell predeterminado"
fi

# -------------------------------------------------------------
# Verificación final
# -------------------------------------------------------------

current_step=$((current_step+1))
show_progress $current_step $total_steps "Verificando instalación"

# Verificar que todos los componentes necesarios estén instalados
CONFIG_STATUS="✓"
if [[ ! -f "$HOME/.zshrc" ]]; then CONFIG_STATUS="✗"; fi
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then CONFIG_STATUS="✗"; fi
if [[ ! -d "$P10K_DIR" ]]; then CONFIG_STATUS="✗"; fi

echo
if [ "$CONFIG_STATUS" = "✓" ]; then
  echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}${BOLD}║       INSTALACIÓN COMPLETADA EXITOSAMENTE          ║${NC}"
  echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════╝${NC}"
else
  echo -e "${YELLOW}${BOLD}╔════════════════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}${BOLD}║    INSTALACIÓN COMPLETADA CON ADVERTENCIAS         ║${NC}"
  echo -e "${YELLOW}${BOLD}╚════════════════════════════════════════════════════╝${NC}"
fi

# -------------------------------------------------------------
# Instrucciones finales
# -------------------------------------------------------------

echo
echo -e "${BOLD}Para completar la configuración:${NC}"
echo -e "  ${CYAN}1.${NC} Reinicia tu terminal o ejecuta: ${YELLOW}exec zsh${NC}"
echo -e "  ${CYAN}2.${NC} Configura Powerlevel10k ejecutando: ${YELLOW}p10k configure${NC}"
echo -e "  ${CYAN}3.${NC} Para actualizar en el futuro ejecuta: ${YELLOW}zshup${NC}"
echo

# Preguntar si desea iniciar Zsh ahora
echo -n -e "${BOLD}¿Deseas iniciar Zsh ahora? [S/n]:${NC} "
read -r response
if [[ "$response" =~ ^[Nn]$ ]]; then
  echo -e "${BOLD}¡Gracias por usar este instalador!${NC}"
else
  echo -e "${GREEN}${BOLD}Iniciando Zsh...${NC}"
  exec zsh -l
fi

exit 0