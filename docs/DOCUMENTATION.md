# 📖 Documentación Detallada - My Scripts Collection

## 📚 Scripts Personales (01-personal/)

### 🧮 calculadora_02.sh
**Descripción:** Calculadora interactiva avanzada con múltiples modos de operación

**Características:**
- ✅ Modo interactivo con menú visual
- ✅ Modo línea de comandos
- ✅ Operaciones básicas: suma, resta, multiplicación, división
- ✅ Operaciones avanzadas: potencia, raíz cuadrada, porcentaje
- ✅ Modo calculadora continua (expresiones complejas)
- ✅ Historial de operaciones
- ✅ Validación robusta de entrada
- ✅ Manejo de errores (división por cero, etc.)
- ✅ Soporte para decimales y notación científica

**Uso:**
```bash
# Modo interactivo
./calculadora_02.sh

# Modo línea de comandos
./calculadora_02.sh 10 + 5
./calculadora_02.sh 15.5 / 3.2

# Ayuda
./calculadora_02.sh --help
```

**Dependencias:** `bc` (calculadora de línea de comandos)

---

### 👋 mi_primer_Script.sh
**Descripción:** Script básico de introducción mostrando información del sistema

**Funcionalidad:**
- Saludo básico
- Fecha y hora actual
- Usuario actual
- Directorio de trabajo

**Uso:**
```bash
./mi_primer_Script.sh
```

---

### 🎭 script_troll_02.sh
**Descripción:** Script divertido con efectos visuales y simulación de "hackeo"

**Características:**
- 🌈 Efectos de colores y animaciones
- 📱 Spinner y barras de progreso
- 🎯 Simulación de "hackeo" a diferentes organizaciones
- 🎨 Interfaz visual tipo "hacker" con ASCII art
- 🔊 Efectos de sonido (beep)

**Uso:**
```bash
./script_troll_02.sh
```

**Nota:** Script puramente educativo y de entretenimiento

---

### 💬 saludo_interactive.sh
**Descripción:** Script interactivo de saludo personalizado

**Funcionalidad:**
- Solicita nombre del usuario
- Saludo personalizado
- Ejemplo de interacción básica

**Uso:**
```bash
./saludo_interactive.sh
```

## 🤖 Scripts de Automatización (02-automation/)

### 📁 organize_multimedia.sh
**Descripción:** Organizador completo de archivos multimedia con monitoreo

**Características:**
- 📷 Organiza screenshots automáticamente
- 🎬 Organiza videos .mkv
- 📊 Estadísticas de archivos
- 👁️ Modo monitoreo continuo (requiere inotify-tools)
- 🎨 Interfaz colorida con progreso visual
- 📈 Múltiples patrones de detección

**Uso:**
```bash
# Organizar archivos existentes
./organize_multimedia.sh

# Monitoreo continuo
./organize_multimedia.sh monitor

# Solo estadísticas
./organize_multimedia.sh stats
```

---

### ⚡ auto_organize.sh
**Descripción:** Script simple para cron - organiza multimedia automáticamente

**Características:**
- 🔄 Diseñado para ejecutarse vía cron
- 📝 Logging automático
- 🧹 Limpieza automática de logs
- ⚡ Ejecución rápida y eficiente

**Configuración cron:**
```bash
# Ejecutar cada minuto
* * * * * /home/dreamcoder08/my-scripts/02-automation/auto_organize.sh
```

---

### 🖥️ setup_vm_automation.sh
**Descripción:** Configurador de automatización para scripts de virtualización

**Características:**
- ⚙️ Configura servicios systemd
- 🔧 Añade automatización al bashrc
- 📝 Crea aliases convenientes
- 💻 Soporte para VirtualBox y VMware

**Uso:**
```bash
./setup_vm_automation.sh
```

---

### 🔄 post_reboot_*.sh
**Descripción:** Scripts de configuración post-reinicio

- **post_reboot_simple.sh:** Configuración básica
- **post_reboot_config.sh:** Configuración avanzada

**Funcionalidad:**
- Recarga módulos de virtualización
- Configura servicios necesarios
- Automatización post-reinicio

## 🛠️ Herramientas de Desarrollo

### Verificar Sintaxis
```bash
# Verificar todos los scripts
find . -name "*.sh" -exec bash -n {} \;
```

### Dar Permisos de Ejecución
```bash
# Todos los scripts
find . -name "*.sh" -exec chmod +x {} \;
```

### Análisis de Código
```bash
# Usar shellcheck si está disponible
shellcheck *.sh
```

## 📋 Plantillas Disponibles

Ver `templates/` para plantillas de nuevos scripts:
- `template-basic.sh` - Script básico
- `template-interactive.sh` - Script interactivo
- `template-automation.sh` - Script de automatización

## 🐛 Resolución de Problemas

### Problemas Comunes

1. **Error: Permission denied**
   ```bash
   chmod +x nombre_script.sh
   ```

2. **Error: bc command not found**
   ```bash
   sudo pacman -S bc  # Arch Linux
   ```

3. **Error: inotify-tools not found**
   ```bash
   sudo pacman -S inotify-tools  # Para monitoreo
   ```

### Logs y Debugging

- Los scripts generan logs en `/tmp/` y `~/.multimedia_organizer.log`
- Usar `bash -x script.sh` para debugging detallado
- Verificar permisos con `ls -la`

---

**Última actualización:** $(date '+%Y-%m-%d %H:%M:%S')

