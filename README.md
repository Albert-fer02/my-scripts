# 🐚 My Scripts Collection

[![ShellCheck](https://img.shields.io/badge/lint-shellcheck-brightgreen?logo=gnu-bash)](https://www.shellcheck.net/)
[![Arch Linux](https://img.shields.io/badge/platform-archlinux-blue?logo=arch-linux)](https://archlinux.org/)
[![Bash](https://img.shields.io/badge/shell-bash%20%7C%20zsh-yellow?logo=gnubash)](https://www.gnu.org/software/bash/)
[![Status](https://img.shields.io/badge/status-active-success)](#)

> Colección profesional y personal de scripts Bash/Zsh para automatización, administración, seguridad, multimedia, desarrollo y más.

**Autor:** dreamcoder08  
**Creado:** 2025-06-14  
**Plataforma:** Arch Linux (compatible con otras distros)  
**Shell:** Bash 4.0+ / Zsh  

---

## 📋 Tabla de Contenidos
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Categorías y Ejemplos](#categorías-y-ejemplos)
- [Estadísticas del Proyecto](#estadísticas-del-proyecto)
- [Guía de Uso Rápido](#guía-de-uso-rápido)
- [Instalación y Configuración](#instalación-y-configuración)
- [Buenas Prácticas y Contribución](#buenas-prácticas-y-contribución)
- [Enlaces Útiles](#enlaces-útiles)
- [Preguntas Frecuentes](#preguntas-frecuentes)
- [Notas de Seguridad](#notas-de-seguridad)

---

## 📁 Estructura del Proyecto

```
my-scripts/
├── 00-core/              # Núcleo, librerías y configuraciones base
├── 01-basics/            # Scripts básicos, juegos, calculadoras
├── 01-personal/          # Scripts personales y de aprendizaje
├── 02-system/            # Instalación, administración, monitoreo
├── 02-automation/        # Automatización y organización
├── 03-automation/        # Automatización avanzada (backups, despliegue)
├── 03-tools/             # Herramientas y utilidades
├── 04-network/           # Scripts de red, análisis, escaneo
├── 05-security/          # Seguridad, hardening, forense
├── 06-development/       # DevOps, testing, git hooks
├── 07-data/              # Procesamiento y análisis de datos
├── 08-multimedia/        # Audio, video, imagen, conversión
├── 09-advanced/          # Algoritmos, AI/ML, criptografía
├── 10-redteam/           # Red Team, C2, evasión, payloads
├── .Debian_Script_Cuztomizar/ # Scripts de personalización Debian
├── .scripts-meta/        # Metadatos y utilidades internas
├── archives/             # Scripts antiguos, experimentos
├── docs/                 # Documentación y guías
├── templates/            # Plantillas para nuevos scripts
├── tests/                # Pruebas unitarias, integración, performance
└── README.md             # Este archivo
```

---

## 🗂️ Categorías y Ejemplos

- **01-personal/**: Scripts de aprendizaje y uso diario  
  Ej: `calculadora_02.sh`, `script_troll_02.sh`
- **02-automation/**: Organización y automatización de tareas  
  Ej: `organize_multimedia.sh`, `auto_organize.sh`
- **03-tools/**: Herramientas especializadas (descargadores, etc.)
- **04-network/**: Análisis y monitoreo de red
- **05-security/**: Scripts de hardening, forense, explotación
- **06-development/**: DevOps, testing, integración continua
- **07-data/**: Procesamiento, extracción y análisis de datos
- **08-multimedia/**: Conversión y organización de audio/video/imagen
- **09-advanced/**: Algoritmos, AI/ML, criptografía avanzada
- **10-redteam/**: Red Team, C2, evasión, payloads
- **templates/**: Plantillas listas para crear nuevos scripts
- **docs/**: Documentación detallada y cheatsheets

---

## 📊 Estadísticas del Proyecto

- **Scripts Bash/Zsh:** ~30+ archivos
- **Líneas de Código:** ~2000+ líneas
- **Cobertura de tests:** Pruebas unitarias y de integración en `tests/`
- **Última actualización:** 2025-06-14

---

## 🚀 Guía de Uso Rápido

### Ejecutar un script
```bash
./01-personal/calculadora_02.sh
./02-automation/organize_multimedia.sh
```

### Ver documentación
```bash
cat docs/DOCUMENTATION.md
```

### Dar permisos de ejecución a todos los scripts
```bash
find . -name "*.sh" -exec chmod +x {} \;
```

### Verificar sintaxis de todos los scripts
```bash
find . -name "*.sh" -exec bash -n {} \;
```

---

## 🛠️ Instalación y Configuración

1. **Clona o descarga** este repositorio
2. **Da permisos de ejecución:**
   ```bash
   chmod +x 01-personal/*.sh 02-automation/*.sh
   # O para todos los scripts
   find . -name "*.sh" -exec chmod +x {} \;
   ```
3. **Configura aliases** (opcional):
   ```bash
   echo 'alias calc="~/my-scripts/01-personal/calculadora_02.sh"' >> ~/.bashrc
   echo 'alias organize="~/my-scripts/02-automation/organize_multimedia.sh"' >> ~/.bashrc
   ```
4. **Instala dependencias** (ejemplo):
   ```bash
   sudo pacman -S bc inotify-tools
   # O el gestor de tu distro
   ```

---

## 🤝 Buenas Prácticas y Contribución

- Usa las plantillas de `templates/` para nuevos scripts
- Sigue la convención de nombres y comentarios
- Documenta cada script con descripción, autor y fecha
- Haz pruebas antes de subir cambios (ver `tests/`)
- ¡Pull requests y sugerencias son bienvenidas!

---

## 🔗 Enlaces Útiles
- [Documentación Detallada](docs/DOCUMENTATION.md)
- [Plantillas de Scripts](templates/)
- [Cheatsheets y Guías](docs/cheatsheets/)
- [ShellCheck Online](https://www.shellcheck.net/)

---

## ❓ Preguntas Frecuentes

**¿Por qué recibo 'Permission denied'?**  
Asegúrate de dar permisos de ejecución: `chmod +x script.sh`

**¿Faltan dependencias como 'bc' o 'inotify-tools'?**  
Instálalas con tu gestor de paquetes: `sudo pacman -S bc inotify-tools`

**¿Puedo usar estos scripts en otras distros?**  
Sí, aunque algunos están optimizados para Arch Linux.

**¿Cómo contribuyo?**  
Lee la sección de buenas prácticas y haz un pull request.

---

## ⚠️ Notas de Seguridad y Advertencias

- Algunos scripts (como los de la carpeta `script_troll_02.sh`) son solo para fines educativos y pueden tener efectos visuales o de broma.
- No ejecutes scripts sensibles sin revisarlos antes.
- Usa siempre en entornos controlados y bajo tu propio riesgo.

---

**© 2025 dreamcoder08** - Proyecto personal de aprendizaje, automatización y hacking ético.

