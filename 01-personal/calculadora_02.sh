#!/bin/bash

# ============================================================================
# CALCULADORA BASH AVANZADA Y ROBUSTA
# Versión: 2.0
# Autor: Experto Bash
# Descripción: Calculadora interactiva con validaciones, manejo de errores,
#              operaciones avanzadas y múltiples modos de uso
# ============================================================================

# Configuración de colores y formato
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Configuración global
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="2.0"
readonly PRECISION=2  # Decimales para resultados

# ============================================================================
# FUNCIONES DE UTILIDAD Y LOGGING
# ============================================================================

print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}${BOLD}        🧮 CALCULADORA BASH v${VERSION}       ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}\n"
}

log_info() {
    echo -e "${GREEN}ℹ️  ${NC}$1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  ${NC}$1"
}

log_error() {
    echo -e "${RED}❌ Error: ${NC}$1" >&2
}

log_success() {
    echo -e "${GREEN}✅ ${NC}$1"
}

print_separator() {
    echo -e "${BLUE}────────────────────────────────────────${NC}"
}

# ============================================================================
# FUNCIONES DE VALIDACIÓN
# ============================================================================

is_valid_number() {
    local input="$1"
    
    # Permitir números enteros, decimales, negativos y notación científica
    if [[ $input =~ ^[+-]?([0-9]*\.?[0-9]+([eE][+-]?[0-9]+)?|[0-9]+\.?)$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_and_read_number() {
    local prompt="$1"
    local var_name="$2"
    local number
    
    while true; do
        echo -e "${CYAN}${prompt}${NC}"
        read -r number
        
        # Permitir salir con 'q' o 'quit'
        if [[ "$number" =~ ^(q|quit|exit)$ ]]; then
            log_info "Saliendo..."
            exit 0
        fi
        
        if is_valid_number "$number"; then
            # Usar declare para asignar a variable dinámica
            declare -g "$var_name"="$number"
            break
        else
            log_error "\"$number\" no es un número válido."
            log_warning "Formato válido: 123, -45.67, 1.2e-3, etc."
            echo
        fi
    done
}

# ============================================================================
# FUNCIONES MATEMÁTICAS
# ============================================================================

safe_divide() {
    local dividend="$1"
    local divisor="$2"
    
    if (( $(echo "$divisor == 0" | bc -l) )); then
        echo "ERROR_DIVISION_ZERO"
        return 1
    fi
    
    echo "scale=$PRECISION; $dividend / $divisor" | bc -l
}

calculate_percentage() {
    local number="$1"
    local percentage="$2"
    echo "scale=$PRECISION; ($number * $percentage) / 100" | bc -l
}

calculate_power() {
    local base="$1"
    local exponent="$2"
    
    # Manejar casos especiales
    if (( $(echo "$base == 0 && $exponent < 0" | bc -l) )); then
        echo "ERROR_ZERO_NEGATIVE_POWER"
        return 1
    fi
    
    echo "scale=$PRECISION; $base ^ $exponent" | bc -l
}

calculate_square_root() {
    local number="$1"
    
    if (( $(echo "$number < 0" | bc -l) )); then
        echo "ERROR_NEGATIVE_SQRT"
        return 1
    fi
    
    echo "scale=$PRECISION; sqrt($number)" | bc -l
}

# ============================================================================
# MODOS DE OPERACIÓN
# ============================================================================

interactive_mode() {
    while true; do
        print_header
        echo -e "${WHITE}Selecciona una operación:${NC}\n"
        echo -e "${GREEN}1)${NC} ➕ Suma"
        echo -e "${GREEN}2)${NC} ➖ Resta" 
        echo -e "${GREEN}3)${NC} ✖️  Multiplicación"
        echo -e "${GREEN}4)${NC} ➗ División"
        echo -e "${GREEN}5)${NC} 📊 Porcentaje"
        echo -e "${GREEN}6)${NC} 🔢 Potencia"
        echo -e "${GREEN}7)${NC} √  Raíz cuadrada"
        echo -e "${GREEN}8)${NC} 🧮 Modo calculadora continua"
        echo -e "${GREEN}9)${NC} 📋 Historial"
        echo -e "${RED}0)${NC} 🚪 Salir"
        
        echo -e "\n${CYAN}Opción (0-9): ${NC}"
        read -r option
        
        case $option in
            1) perform_basic_operation "suma" "+" ;;
            2) perform_basic_operation "resta" "-" ;;
            3) perform_basic_operation "multiplicación" "*" ;;
            4) perform_division ;;
            5) perform_percentage ;;
            6) perform_power ;;
            7) perform_square_root ;;
            8) continuous_calculator ;;
            9) show_history ;;
            0|q|quit|exit) 
                log_info "¡Gracias por usar la calculadora!"
                exit 0 
                ;;
            *) 
                log_error "Opción no válida: $option"
                sleep 2
                ;;
        esac
    done
}

perform_basic_operation() {
    local operation_name="$1"
    local operator="$2"
    local num1 num2 result
    
    print_separator
    echo -e "${WHITE}${BOLD}Operación: ${operation_name^}${NC}\n"
    
    validate_and_read_number "🔢 Primer número:" "num1"
    validate_and_read_number "🔢 Segundo número:" "num2"
    
    result=$(echo "scale=$PRECISION; $num1 $operator $num2" | bc -l)
    
    # Guardar en historial
    save_to_history "$num1 $operator $num2 = $result"
    
    print_separator
    echo -e "${GREEN}${BOLD}Resultado:${NC}"
    echo -e "${WHITE}$num1 $operator $num2 = ${YELLOW}${BOLD}$result${NC}\n"
    
    pause_and_continue
}

perform_division() {
    local num1 num2 result
    
    print_separator
    echo -e "${WHITE}${BOLD}Operación: División${NC}\n"
    
    validate_and_read_number "🔢 Dividendo:" "num1"
    validate_and_read_number "🔢 Divisor:" "num2"
    
    result=$(safe_divide "$num1" "$num2")
    
    if [[ "$result" == "ERROR_DIVISION_ZERO" ]]; then
        log_error "No se puede dividir por cero"
        pause_and_continue
        return 1
    fi
    
    # Guardar en historial
    save_to_history "$num1 ÷ $num2 = $result"
    
    print_separator
    echo -e "${GREEN}${BOLD}Resultado:${NC}"
    echo -e "${WHITE}$num1 ÷ $num2 = ${YELLOW}${BOLD}$result${NC}\n"
    
    pause_and_continue
}

perform_percentage() {
    local number percentage result
    
    print_separator
    echo -e "${WHITE}${BOLD}Operación: Porcentaje${NC}\n"
    
    validate_and_read_number "🔢 Número base:" "number"
    validate_and_read_number "📊 Porcentaje:" "percentage"
    
    result=$(calculate_percentage "$number" "$percentage")
    
    # Guardar en historial
    save_to_history "$percentage% de $number = $result"
    
    print_separator
    echo -e "${GREEN}${BOLD}Resultado:${NC}"
    echo -e "${WHITE}$percentage% de $number = ${YELLOW}${BOLD}$result${NC}\n"
    
    pause_and_continue
}

perform_power() {
    local base exponent result
    
    print_separator
    echo -e "${WHITE}${BOLD}Operación: Potencia${NC}\n"
    
    validate_and_read_number "🔢 Base:" "base"
    validate_and_read_number "🔢 Exponente:" "exponent"
    
    result=$(calculate_power "$base" "$exponent")
    
    if [[ "$result" == "ERROR_ZERO_NEGATIVE_POWER" ]]; then
        log_error "No se puede elevar 0 a una potencia negativa"
        pause_and_continue
        return 1
    fi
    
    # Guardar en historial
    save_to_history "$base^$exponent = $result"
    
    print_separator
    echo -e "${GREEN}${BOLD}Resultado:${NC}"
    echo -e "${WHITE}$base^$exponent = ${YELLOW}${BOLD}$result${NC}\n"
    
    pause_and_continue
}

perform_square_root() {
    local number result
    
    print_separator
    echo -e "${WHITE}${BOLD}Operación: Raíz Cuadrada${NC}\n"
    
    validate_and_read_number "🔢 Número:" "number"
    
    result=$(calculate_square_root "$number")
    
    if [[ "$result" == "ERROR_NEGATIVE_SQRT" ]]; then
        log_error "No se puede calcular la raíz cuadrada de un número negativo"
        pause_and_continue
        return 1
    fi
    
    # Guardar en historial
    save_to_history "√$number = $result"
    
    print_separator
    echo -e "${GREEN}${BOLD}Resultado:${NC}"
    echo -e "${WHITE}√$number = ${YELLOW}${BOLD}$result${NC}\n"
    
    pause_and_continue
}

continuous_calculator() {
    local expression result
    
    print_separator
    echo -e "${WHITE}${BOLD}🧮 Modo Calculadora Continua${NC}\n"
    echo -e "${YELLOW}Ingresa expresiones matemáticas directamente${NC}"
    echo -e "${YELLOW}Ejemplos: 2+3*4, (5-2)/3, 2^3+1${NC}"
    echo -e "${YELLOW}Escribe 'quit' para volver al menú principal${NC}\n"
    
    while true; do
        echo -e "${CYAN}Expresión: ${NC}"
        read -r expression
        
        if [[ "$expression" =~ ^(q|quit|exit|back)$ ]]; then
            break
        fi
        
        if [[ -z "$expression" ]]; then
            continue
        fi
        
        # Validar caracteres permitidos
        if [[ ! "$expression" =~ ^[0-9+\-*/().\ eE^]+$ ]]; then
            log_error "Expresión contiene caracteres no válidos"
            continue
        fi
        
        # Evaluar expresión usando bc
        result=$(echo "scale=$PRECISION; $expression" | bc -l 2>/dev/null)
        
        if [[ $? -eq 0 && -n "$result" ]]; then
            save_to_history "$expression = $result"
            echo -e "${GREEN}= ${YELLOW}${BOLD}$result${NC}\n"
        else
            log_error "Expresión matemática no válida"
        fi
    done
}

# ============================================================================
# SISTEMA DE HISTORIAL
# ============================================================================

init_history() {
    readonly HISTORY_FILE="/tmp/bash_calculator_history_$$"
    touch "$HISTORY_FILE"
}

save_to_history() {
    local operation="$1"
    echo "$(date '+%H:%M:%S') - $operation" >> "$HISTORY_FILE"
}

show_history() {
    print_separator
    echo -e "${WHITE}${BOLD}📋 Historial de Operaciones${NC}\n"
    
    if [[ ! -f "$HISTORY_FILE" ]] || [[ ! -s "$HISTORY_FILE" ]]; then
        log_warning "El historial está vacío"
    else
        cat "$HISTORY_FILE" | tail -20 | while IFS= read -r line; do
            echo -e "${CYAN}$line${NC}"
        done
    fi
    
    echo
    pause_and_continue
}

cleanup_history() {
    [[ -f "$HISTORY_FILE" ]] && rm -f "$HISTORY_FILE"
}

# ============================================================================
# MODO LÍNEA DE COMANDOS
# ============================================================================

command_line_mode() {
    local num1="$1"
    local operator="$2"
    local num2="$3"
    local result
    
    # Validar números
    if ! is_valid_number "$num1" || ! is_valid_number "$num2"; then
        log_error "Números no válidos: $num1, $num2"
        show_usage
        exit 1
    fi
    
    case "$operator" in
        "+"|"add"|"suma")
            result=$(echo "scale=$PRECISION; $num1 + $num2" | bc -l)
            echo "$num1 + $num2 = $result"
            ;;
        "-"|"sub"|"resta")
            result=$(echo "scale=$PRECISION; $num1 - $num2" | bc -l)
            echo "$num1 - $num2 = $result"
            ;;
        "*"|"mul"|"multiplicacion")
            result=$(echo "scale=$PRECISION; $num1 * $num2" | bc -l)
            echo "$num1 × $num2 = $result"
            ;;
        "/"|"div"|"division")
            result=$(safe_divide "$num1" "$num2")
            if [[ "$result" == "ERROR_DIVISION_ZERO" ]]; then
                log_error "División por cero"
                exit 1
            fi
            echo "$num1 ÷ $num2 = $result"
            ;;
        "^"|"pow"|"potencia")
            result=$(calculate_power "$num1" "$num2")
            if [[ "$result" == "ERROR_ZERO_NEGATIVE_POWER" ]]; then
                log_error "No se puede elevar 0 a potencia negativa"
                exit 1
            fi
            echo "$num1^$num2 = $result"
            ;;
        *)
            log_error "Operador no válido: $operator"
            show_usage
            exit 1
            ;;
    esac
}

# ============================================================================
# FUNCIONES DE AYUDA Y UTILIDAD
# ============================================================================

show_usage() {
    cat << EOF
${BOLD}Uso:${NC}
  $SCRIPT_NAME                    # Modo interactivo
  $SCRIPT_NAME [num1] [op] [num2] # Modo línea de comandos
  $SCRIPT_NAME -h|--help          # Mostrar ayuda
  $SCRIPT_NAME -v|--version       # Mostrar versión

${BOLD}Operadores válidos:${NC}
  +, add, suma           # Suma
  -, sub, resta          # Resta  
  *, mul, multiplicacion # Multiplicación
  /, div, division       # División
  ^, pow, potencia       # Potencia

${BOLD}Ejemplos:${NC}
  $SCRIPT_NAME 10 + 5
  $SCRIPT_NAME 15.5 / 3.2
  $SCRIPT_NAME 2 ^ 8

${BOLD}Características:${NC}
  ✅ Validación robusta de entrada
  ✅ Manejo de errores (división por cero, etc.)
  ✅ Soporte para decimales y notación científica
  ✅ Historial de operaciones
  ✅ Modo calculadora continua
  ✅ Operaciones avanzadas (potencia, raíz, porcentaje)
EOF
}

show_version() {
    echo -e "${BOLD}$SCRIPT_NAME versión $VERSION${NC}"
    echo "Calculadora Bash avanzada con múltiples características"
}

pause_and_continue() {
    echo -e "\n${CYAN}Presiona Enter para continuar...${NC}"
    read -r
}

check_dependencies() {
    if ! command -v bc &> /dev/null; then
        log_error "bc (calculadora de línea de comandos) no está instalado"
        log_info "Instálalo con: sudo apt install bc (Ubuntu/Debian) o sudo yum install bc (CentOS/RHEL)"
        exit 1
    fi
}

# ============================================================================
# MANEJO DE SEÑALES Y CLEANUP
# ============================================================================

cleanup() {
    cleanup_history
    echo -e "\n ${GREEN}¡Gracias por usar la calculadora!${NC}"
}

trap cleanup EXIT
trap 'echo -e "\n${YELLOW}Operación cancelada${NC}"; exit 130' INT

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

main() {
    # Verificar dependencias
    check_dependencies
    
    # Inicializar historial
    init_history
    
    # Procesar argumentos de línea de comandos
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        "")
            # Modo interactivo (sin argumentos)
            interactive_mode
            ;;
        *)
            # Modo línea de comandos
            if [[ $# -eq 3 ]]; then
                command_line_mode "$1" "$2" "$3"
            else
                log_error "Número incorrecto de argumentos"
                show_usage
                exit 1
            fi
            ;;
    esac
}

# ============================================================================
# PUNTO DE ENTRADA
# ============================================================================

# Ejecutar solo si el script se llama directamente (no si se hace source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi