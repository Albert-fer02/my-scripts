#!/bin/bash

# =============================================================================
# SCRIPT DE CONFIGURACIÓN POST-REINICIO
# Configuración automática de VirtualBox y VMware después del reinicio
# Compatible con Arch Linux
# =============================================================================

set -euo pipefail  # Salir en caso de error, variable no definida o fallo en pipe

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
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
    echo -e "${RED}[✗]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar si estamos ejecutando como root
check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        log_error "No ejecutes este script como root. Usa sudo cuando sea necesario."
        exit 1
    fi
}

# Función para verificar dependencias
check_dependencies() {
    log_info "Verificando dependencias..."
    
    local missing_deps=()
    
    # Verificar si VirtualBox está instalado
    if ! command_exists VBoxManage; then
        missing_deps+=("virtualbox")
    fi
    
    # Verificar si VMware está instalado
    if ! command_exists vmware; then
        missing_deps+=("vmware-workstation")
    fi
    
    # Verificar dkms
    if ! command_exists dkms; then
        missing_deps+=("dkms")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "Dependencias faltantes: ${missing_deps[*]}"
        log_info "Instala las dependencias faltantes antes de continuar."
        return 1
    fi
    
    log_success "Todas las dependencias están instaladas"
    return 0
}

# Función para configurar VirtualBox
setup_virtualbox() {
    log_info "Configurando VirtualBox..."
    
    local kernel_version
    kernel_version=$(uname -r)
    
    # Verificar si los módulos de VirtualBox ya están cargados
    if lsmod | grep -q "vboxdrv"; then
        log_success "VirtualBox ya está configurado correctamente"
        return 0
    fi
    
    # Compilar e instalar módulos VirtualBox
    log_info "Compilando módulos VirtualBox para kernel $kernel_version"
    
    # Buscar la versión de VirtualBox instalada
    local vbox_version
    if command_exists VBoxManage; then
        vbox_version=$(VBoxManage --version | cut -d'r' -f1)
        log_info "Versión de VirtualBox detectada: $vbox_version"
    else
        log_error "No se pudo detectar la versión de VirtualBox"
        return 1
    fi
    
    # Intentar compilar los módulos con dkms
    if sudo dkms status | grep -q "vboxhost"; then
        log_info "Módulos de VirtualBox encontrados en DKMS"
        sudo dkms install "vboxhost/$vbox_version" -k "$kernel_version" || {
            log_warning "Fallo en dkms install, intentando reconstruir..."
            sudo dkms remove "vboxhost/$vbox_version" -k "$kernel_version" 2>/dev/null || true
            sudo dkms install "vboxhost/$vbox_version" -k "$kernel_version"
        }
    else
        log_warning "Módulos de VirtualBox no encontrados en DKMS"
        log_info "Intentando reconfigurar VirtualBox..."
        sudo /sbin/vboxconfig || {
            log_error "Error al reconfigurar VirtualBox"
            return 1
        }
    fi
    
    # Cargar módulos VirtualBox
    log_info "Cargando módulos VirtualBox..."
    sudo modprobe vboxdrv || {
        log_error "Error al cargar módulo vboxdrv"
        return 1
    }
    
    sudo modprobe vboxnetadp || log_warning "Error al cargar módulo vboxnetadp (opcional)"
    sudo modprobe vboxnetflt || log_warning "Error al cargar módulo vboxnetflt (opcional)"
    
    # Verificar que VirtualBox funciona
    if [[ -c /dev/vboxdrv ]]; then
        log_success "VirtualBox configurado correctamente"
        return 0
    else
        log_error "VirtualBox no se configuró correctamente"
        return 1
    fi
}

# Función para configurar VMware
setup_vmware() {
    log_info "Configurando VMware..."
    
    # Verificar si los módulos de VMware ya están cargados
    if lsmod | grep -q "vmmon"; then
        log_success "VMware ya está configurado correctamente"
        return 0
    fi
    
    # Verificar si vmware-modconfig existe
    if ! command_exists vmware-modconfig; then
        log_error "vmware-modconfig no encontrado. ¿Está VMware instalado correctamente?"
        return 1
    fi
    
    # Configurar módulos VMware
    log_info "Compilando e instalando módulos VMware..."
    sudo vmware-modconfig --console --install-all || {
        log_error "Error al configurar módulos VMware"
        return 1
    }
    
    # Cargar módulos VMware
    log_info "Cargando módulos VMware..."
    sudo modprobe vmmon || {
        log_error "Error al cargar módulo vmmon"
        return 1
    }
    
    sudo modprobe vmnet || {
        log_error "Error al cargar módulo vmnet"
        return 1
    }
    
    # Verificar que VMware funciona
    if [[ -c /dev/vmmon ]]; then
        log_success "VMware configurado correctamente"
        return 0
    else
        log_error "VMware no se configuró correctamente"
        return 1
    fi
}

# Función para mostrar el estado final
show_final_status() {
    echo
    log_info "=== VERIFICACIÓN FINAL ==="
    
    echo "Kernel actual: $(uname -r)"
    echo
    
    # Estado de VirtualBox
    if [[ -c /dev/vboxdrv ]]; then
        log_success "VirtualBox: OK"
    else
        log_error "VirtualBox: FALLO"
    fi
    
    # Estado de VMware
    if [[ -c /dev/vmmon ]]; then
        log_success "VMware: OK"
    else
        log_error "VMware: FALLO"
    fi
    
    echo
    log_info "Módulos cargados:"
    lsmod | grep -E "(vbox|vmw|vmmon|vmnet)" || log_warning "No se encontraron módulos de virtualización"
    
    echo
    log_info "Dispositivos creados:"
    ls -la /dev/vbox* 2>/dev/null || log_warning "No se encontraron dispositivos VirtualBox"
    ls -la /dev/vm* 2>/dev/null || log_warning "No se encontraron dispositivos VMware"
}

# Función para crear servicio systemd (opcional)
create_systemd_service() {
    local service_file="/etc/systemd/system/post-reboot-vm-config.service"
    local script_path
    script_path=$(realpath "$0")
    
    read -p "¿Quieres crear un servicio systemd para ejecutar este script automáticamente al inicio? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Creando servicio systemd..."
        
        sudo tee "$service_file" > /dev/null <<EOF
[Unit]
Description=Post-reboot VM configuration
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$script_path --auto
User=root
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable post-reboot-vm-config.service
        
        log_success "Servicio systemd creado y habilitado"
    fi
}

# Función principal
main() {
    echo "==============================================="
    echo "  CONFIGURACIÓN POST-REINICIO"
    echo "  VirtualBox y VMware para Arch Linux"
    echo "==============================================="
    echo
    
    # Verificar que no somos root
    check_sudo
    
    # Verificar dependencias
    if ! check_dependencies; then
        exit 1
    fi
    
    local vbox_success=false
    local vmware_success=false
    
    # Configurar VirtualBox
    if command_exists VBoxManage; then
        if setup_virtualbox; then
            vbox_success=true
        fi
    else
        log_warning "VirtualBox no está instalado, omitiendo configuración"
    fi
    
    echo
    
    # Configurar VMware
    if command_exists vmware; then
        if setup_vmware; then
            vmware_success=true
        fi
    else
        log_warning "VMware no está instalado, omitiendo configuración"
    fi
    
    # Mostrar estado final
    show_final_status
    
    # Crear servicio systemd si no estamos en modo automático
    if [[ "${1:-}" != "--auto" ]]; then
        echo
        create_systemd_service
    fi
    
    echo
    if $vbox_success || $vmware_success; then
        log_success "Configuración completada exitosamente!"
        exit 0
    else
        log_error "La configuración falló para todos los sistemas de virtualización"
        exit 1
    fi
}

# Ejecutar función principal con todos los argumentos
main "$@"

