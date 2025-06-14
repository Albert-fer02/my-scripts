#!/bin/bash

# =============================================================================
# CONFIGURADOR DE AUTOMATIZACIÓN PARA SCRIPTS DE VIRTUALIZACIÓN
# Instala y configura la automatización de los scripts post-reinicio
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo "==============================================="
echo "  CONFIGURADOR DE AUTOMATIZACIÓN VM"
echo "  Para VirtualBox y VMware en Arch Linux"
echo "==============================================="
echo

# Verificar que tenemos los scripts
SCRIPT_DIR="$(dirname "$(realpath "$0")")"  
SIMPLE_SCRIPT="$SCRIPT_DIR/post_reboot_simple.sh"
ADVANCED_SCRIPT="$SCRIPT_DIR/post_reboot_config.sh"

if [[ ! -f "$SIMPLE_SCRIPT" ]]; then
    log_error "No se encontró $SIMPLE_SCRIPT"
    exit 1
fi

log_info "Scripts encontrados:"
echo "  • Simple: $SIMPLE_SCRIPT"
[[ -f "$ADVANCED_SCRIPT" ]] && echo "  • Avanzado: $ADVANCED_SCRIPT"
echo

# Menú de opciones
log_info "Opciones de automatización:"
echo "1) Crear servicio systemd (recomendado)"
echo "2) Añadir al ~/.bashrc"
echo "3) Crear alias convenientes"
echo "4) Todo lo anterior"
echo "5) Solo mostrar comandos manuales"
echo

read -p "Selecciona una opción (1-5): " -n 1 -r
echo
echo

case $REPLY in
    1)
        log_info "Creando servicio systemd..."
        
        # Crear el servicio
        sudo tee /etc/systemd/system/vm-post-reboot.service > /dev/null <<EOF
[Unit]
Description=Configure VM modules after reboot
After=multi-user.target
Wants=multi-user.target

[Service]
Type=oneshot
ExecStart=$SIMPLE_SCRIPT
User=root
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        
        # Habilitar el servicio
        sudo systemctl daemon-reload
        sudo systemctl enable vm-post-reboot.service
        
        log_success "Servicio systemd creado y habilitado"
        log_info "El script se ejecutará automáticamente en cada reinicio"
        ;;
        
    2)
        log_info "Añadiendo al ~/.bashrc..."
        
        # Añadir al bashrc
        if ! grep -q "post_reboot_simple.sh" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Auto-configurar módulos de virtualización" >> ~/.bashrc
            echo "if [[ -f '$SIMPLE_SCRIPT' ]]; then" >> ~/.bashrc
            echo "    # Ejecutar solo si hay dispositivos de VM faltantes" >> ~/.bashrc
            echo "    if [[ ! -c /dev/vboxdrv && ! -c /dev/vmmon ]]; then" >> ~/.bashrc
            echo "        echo 'Configurando módulos de virtualización...'" >> ~/.bashrc
            echo "        '$SIMPLE_SCRIPT'" >> ~/.bashrc
            echo "    fi" >> ~/.bashrc
            echo "fi" >> ~/.bashrc
            
            log_success "Añadido al ~/.bashrc"
        else
            log_warning "Ya existe una entrada en ~/.bashrc"
        fi
        ;;
        
    3)
        log_info "Creando aliases..."
        
        # Crear aliases
        if ! grep -q "alias fix-vm" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Aliases para scripts de virtualización" >> ~/.bashrc
            echo "alias fix-vm='$SIMPLE_SCRIPT'" >> ~/.bashrc
            [[ -f "$ADVANCED_SCRIPT" ]] && echo "alias fix-vm-advanced='$ADVANCED_SCRIPT'" >> ~/.bashrc
            echo "alias vm-status='lsmod | grep -E \"(vbox|vmw|vmmon|vmnet)\" && ls -la /dev/vbox* /dev/vm* 2>/dev/null'" >> ~/.bashrc
            
            log_success "Aliases creados:"
            echo "  • fix-vm - Ejecutar script simple"
            [[ -f "$ADVANCED_SCRIPT" ]] && echo "  • fix-vm-advanced - Ejecutar script avanzado"
            echo "  • vm-status - Ver estado de módulos VM"
        else
            log_warning "Los aliases ya existen en ~/.bashrc"
        fi
        ;;
        
    4)
        log_info "Configurando todo..."
        
        # Servicio systemd
        sudo tee /etc/systemd/system/vm-post-reboot.service > /dev/null <<EOF
[Unit]
Description=Configure VM modules after reboot
After=multi-user.target
Wants=multi-user.target

[Service]
Type=oneshot
ExecStart=$SIMPLE_SCRIPT
User=root
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable vm-post-reboot.service
        
        # Bashrc
        if ! grep -q "post_reboot_simple.sh" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Auto-configurar módulos de virtualización" >> ~/.bashrc
            echo "if [[ -f '$SIMPLE_SCRIPT' ]]; then" >> ~/.bashrc
            echo "    if [[ ! -c /dev/vboxdrv && ! -c /dev/vmmon ]]; then" >> ~/.bashrc
            echo "        echo 'Configurando módulos de virtualización...'" >> ~/.bashrc
            echo "        '$SIMPLE_SCRIPT'" >> ~/.bashrc
            echo "    fi" >> ~/.bashrc
            echo "fi" >> ~/.bashrc
        fi
        
        # Aliases
        if ! grep -q "alias fix-vm" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Aliases para scripts de virtualización" >> ~/.bashrc
            echo "alias fix-vm='$SIMPLE_SCRIPT'" >> ~/.bashrc
            [[ -f "$ADVANCED_SCRIPT" ]] && echo "alias fix-vm-advanced='$ADVANCED_SCRIPT'" >> ~/.bashrc
            echo "alias vm-status='lsmod | grep -E \"(vbox|vmw|vmmon|vmnet)\" && ls -la /dev/vbox* /dev/vm* 2>/dev/null'" >> ~/.bashrc
        fi
        
        log_success "Configuración completa instalada"
        ;;
        
    5)
        log_info "Comandos manuales:"
        echo
        echo "Para ejecutar manualmente:"
        echo "  $SIMPLE_SCRIPT"
        echo
        echo "Para crear el servicio systemd manualmente:"
        echo "  sudo systemctl enable $SCRIPT_DIR/vm-post-reboot.service"
        echo
        echo "Para añadir al bashrc manualmente:"
        echo "  echo \"$SIMPLE_SCRIPT\" >> ~/.bashrc"
        ;;
        
    *)
        log_error "Opción no válida"
        exit 1
        ;;
esac

echo
log_info "Configuración completada!"

if [[ $REPLY != "5" ]]; then
    echo
    log_info "Próximos pasos:"
    echo "1. Reinicia tu terminal o ejecuta: source ~/.bashrc"
    echo "2. Después del próximo reinicio, los módulos se configurarán automáticamente"
    echo "3. Para ejecutar manualmente: fix-vm"
    echo "4. Para ver el estado: vm-status"
fi

echo

