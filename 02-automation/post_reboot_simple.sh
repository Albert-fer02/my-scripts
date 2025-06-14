#!/bin/bash

# =============================================================================
# SCRIPT SIMPLE DE CONFIGURACIÓN POST-REINICIO
# Basado en tu script original, pero con mejoras
# =============================================================================

echo "=== CONFIGURACIÓN POST-REINICIO ==="
echo

# 1. Verificar kernel
echo "Kernel actual: $(uname -r)"
echo

# 2. Configurar VirtualBox
echo "[1/4] Configurando VirtualBox..."
if command -v VBoxManage >/dev/null 2>&1; then
    # Verificar si ya está funcionando
    if [[ -c /dev/vboxdrv ]]; then
        echo "✅ VirtualBox ya está configurado"
    else
        echo "📦 Compilando y cargando módulos VirtualBox..."
        
        # Obtener versión de VirtualBox
        VBOX_VERSION=$(VBoxManage --version | cut -d'r' -f1)
        echo "Versión detectada: $VBOX_VERSION"
        
        # Compilar módulos
        if sudo dkms install "vboxhost/$VBOX_VERSION" -k "$(uname -r)" 2>/dev/null; then
            echo "✅ Módulos compilados con DKMS"
        else
            echo "⚠️  DKMS falló, usando vboxconfig..."
            sudo /sbin/vboxconfig
        fi
        
        # Cargar módulos
        sudo modprobe vboxdrv vboxnetadp vboxnetflt 2>/dev/null
        
        # Verificar
        if [[ -c /dev/vboxdrv ]]; then
            echo "✅ VirtualBox OK"
        else
            echo "❌ VirtualBox FALLO"
        fi
    fi
else
    echo "⚠️  VirtualBox no instalado, omitiendo..."
fi

echo

# 3. Configurar VMware
echo "[2/4] Configurando VMware..."
if command -v vmware >/dev/null 2>&1; then
    # Verificar si ya está funcionando
    if [[ -c /dev/vmmon ]]; then
        echo "✅ VMware ya está configurado"
    else
        echo "📦 Configurando módulos VMware..."
        
        # Compilar e instalar módulos
        if sudo vmware-modconfig --console --install-all; then
            echo "✅ Módulos VMware compilados"
            
            # Cargar módulos
            sudo modprobe vmmon vmnet
            
            # Verificar
            if [[ -c /dev/vmmon ]]; then
                echo "✅ VMware OK"
            else
                echo "❌ VMware FALLO"
            fi
        else
            echo "❌ Error al configurar VMware"
        fi
    fi
else
    echo "⚠️  VMware no instalado, omitiendo..."
fi

echo

# 4. Estado final
echo "[3/4] Verificación final..."
echo "=== ESTADO DEL SISTEMA ==="
echo "Kernel: $(uname -r)"
echo

# Verificar dispositivos
echo "Dispositivos de virtualización:"
ls -la /dev/vbox* /dev/vm* 2>/dev/null || echo "No se encontraron dispositivos"
echo

# Mostrar módulos cargados
echo "Módulos cargados:"
lsmod | grep -E "(vbox|vmw|vmmon|vmnet)" || echo "No hay módulos de virtualización cargados"
echo

# 5. Resumen final
echo "[4/4] Resumen final:"
vbox_ok=false
vmware_ok=false

if [[ -c /dev/vboxdrv ]]; then
    echo "✅ VirtualBox: FUNCIONANDO"
    vbox_ok=true
else
    echo "❌ VirtualBox: NO DISPONIBLE"
fi

if [[ -c /dev/vmmon ]]; then
    echo "✅ VMware: FUNCIONANDO"
    vmware_ok=true
else
    echo "❌ VMware: NO DISPONIBLE"
fi

echo
if $vbox_ok || $vmware_ok; then
    echo "🎉 Configuración completada exitosamente!"
    echo
    echo "Sugerencias:"
    echo "• Para automatizar este script al inicio, añádelo a tu ~/.bashrc o crea un servicio systemd"
    echo "• Ejecuta este script después de cada actualización del kernel"
else
    echo "⚠️  Ningún sistema de virtualización está funcionando"
    echo "Verifica que VirtualBox o VMware estén instalados correctamente"
fi

echo
echo "Configuración completada!"

