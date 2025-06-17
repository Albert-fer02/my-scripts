# ==============================================================================
#            MI ARCHIVO DE CONFIGURACIÓN DE ZSH PARA ARCH LINUX
#
#           Corregido y optimizado para máxima eficiencia y claridad.
# ==============================================================================

# ------------------------------------------------------------------------------
# [0] 📦 DEPENDENCIAS - Herramientas necesarias para este archivo
# ------------------------------------------------------------------------------
# Antes de usar este .zshrc, asegúrate de tener todo instalado.
# sudo pacman -S --needed zsh oh-my-zsh-git fzf fd bat eza ripgrep jq \
#   zsh-autosuggestions zsh-syntax-highlighting zsh-completions thefuck \
#   duf dust btop delta xh lsof curl git nvm neovim
#
# Nota: --needed evita reinstalar paquetes que ya tienes.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# [1] 🧠 ZSH FRAMEWORK - Oh My Zsh y Tema Powerlevel10k
# ------------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Lista de plugins de Oh My Zsh
plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    history-substring-search
    z
    thefuck
)

# Carga de Oh My Zsh. DEBE estar antes de la mayoría de las configuraciones.
source $ZSH/oh-my-zsh.sh

# Carga de Powerlevel10k (si existe)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ------------------------------------------------------------------------------
# [2] ⚙️ VARIABLES DE ENTORNO Y CONFIGURACIÓN DE LA SHELL
# ------------------------------------------------------------------------------

# Historial de comandos
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS    # No guardar duplicados consecutivos
setopt HIST_IGNORE_SPACE       # No guardar comandos con espacio al inicio
setopt HIST_FIND_NO_DUPS       # Al buscar, no mostrar duplicados
setopt INC_APPEND_HISTORY      # Guardar historial al instante
setopt SHARE_HISTORY           # Compartir historial entre terminales

# Editor por defecto para comandos como `fc` o `crontab -e`
export EDITOR='nvim'
export VISUAL='nvim'

# Localización y lenguaje. Asegúrate de tener 'es_PE.UTF-8' generado.
# (descomenta la línea en /etc/locale.gen y ejecuta `sudo locale-gen`)
export LANG=es_PE.UTF-8
export LC_ALL=es_PE.UTF-8

# Otras opciones de Zsh
setopt CORRECT      # Auto-corrige comandos simples (ej. sl -> ls)
setopt NOCLOBBER    # Evita sobrescribir archivos con el operador de redirección `>`

# Colores para las páginas del manual (`man`)
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'


# ------------------------------------------------------------------------------
# [3] 🛠️ ALIAS - Atajos para comandos frecuentes
# ------------------------------------------------------------------------------

# Reemplazos modernos (¡asegúrate de que los paquetes estén instalados!)
alias cat='bat --style=plain --paging=never --theme="Catppuccin-frappe"' # Requiere el tema de bat
alias ls='eza --icons --group-directories-first --git'
alias ll='eza -l --icons --group-directories-first --git --time-style=long-iso'
alias la='ll -a'
alias tree='eza --tree --level=3 --icons'
alias grep='rg --smart-case --hidden --glob "!**/.git/*" --glob "!**/node_modules/*"'
alias df='duf'
alias find='fd'
alias du='dust'
alias top='btop'
alias diff='delta'
alias vim='nvim'
alias vi='nvim'
alias http='xh'
alias psg='ps aux | grep -v grep | grep -i'
alias open='xdg-open'
alias myip='curl ifconfig.me'
alias ports='sudo lsof -i -P -n | grep LISTEN'
alias usage='du -h --max-depth=1'

# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Sistema y limpieza
alias clean='sudo pacman -Sc && sudo journalctl --vacuum-time=7d'
alias reboot='echo "Usa systemctl reboot si estás seguro"'
alias shutdown='echo "Usa systemctl poweroff si estás seguro"'

# Motivación
alias salud='echo "💪 Respira, hidrátate y enfócate."'
alias coffee='echo "☕ Tómate un cafecito y sigue."'
alias motivacion='curl -s https://zenquotes.io/api/random | jq -r ".[0].q + \" —\" + .[0].a"'



export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
