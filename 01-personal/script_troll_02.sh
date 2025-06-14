#!/bin/bash
# ░█▀▄░█▀█░█▄█░░░█░█░█▀▀░█▀█░█▀█░█▄█░▀█▀░█▀█░█░░░█▀█░█▀▀░█▀▄░█░█░▄▀█░█▄█
# ░█▀▄░█▀█░█░█░░░▀▄▀░██▄░█▀▄░█▄█░█░█░░█░░█▄█░█▄▄░█▄█░██▄░█▄▀░█▄█░█▀█░░█░
#           V6.0 - “Edición Limón con Chicha Morada y Sabor a Shell”
# ADVERTENCIA: Este script contiene altos niveles de sarcasmo y bits cósmicos.

#================= PALETA GALÁCTICA ==================#
COL() { echo -ne "\033[$1m"; } # Uso: COL 1; echo "Rojo"
END=$(COL 0)
NEGRITA=$(COL 1)
SUBR=$(COL 4)
PARP=$(COL 5)

ROJO=$(COL "1;31")
VERDE=$(COL "1;32")
AMARILLO=$(COL "1;33")
AZUL=$(COL "1;34")
MORADO=$(COL "1;35")
CELESTE=$(COL "1;36")
BLANCO=$(COL "1;37")
GRIS=$(COL "0;90")
ROSA=$(COL "1;95")

#================= EFECTOS UNIVERSALES ==================#

beep() { echo -ne '\a'; }

escribir() {
    local texto="$1"; local vel="${2:-0.04}"; local sonido="${3:-false}"
    for ((i=0; i<${#texto}; i++)); do
        echo -n "${texto:$i:1}"
        [[ "$sonido" == true ]] && beep
        sleep $vel
    done
    echo ""
}

spinner() {
    local pid=$1; local spin='🌑🌒🌓🌔🌕🌖🌗🌘'; local i=0
    tput civis
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r${AMARILLO}[ %s ]${END} Esperando al núcleo cuántico..." "${spin:$i:1}"
        sleep 0.1
    done
    printf "\r${VERDE}[✓] Listo.${END}                                      \n"
    tput cnorm
}

progreso() {
    local duracion=$1; local mensaje="$2"
    echo -e "\n$mensaje"
    echo -ne "["
    for ((i=0;i<40;i++)); do echo -n " "; done
    echo -n "] 0%"

    for ((i=1;i<=40;i++)); do
        sleep $duracion
        local porcentaje=$((i * 100 / 40))
        echo -ne "\r["
        echo -ne "${VERDE}$(printf '█%.0s' $(seq 1 $i))${END}"
        echo -ne "$(printf ' %.0s' $(seq 1 $((40-i))))] ${porcentaje}%"
    done
    echo -e " ${VERDE}[OK]${END}"
}

matrix_chicha() {
    clear
    trap "tput cnorm; clear; echo -e '\n${ROJO}[!] Interrupción detectada${END}'; exit" SIGINT
    echo -e "${CELESTE}Iniciando bypass cuántico del firewall interdimensional...${END}"
    sleep 2
    tput civis
    local cols=$(tput cols) rows=$(tput lines)
    while :; do
        for ((i=0; i<cols; i++)); do
            printf "\033[$((RANDOM % rows));$iH${VERDE}$(printf \\$(printf '%03o' $((RANDOM%57+33))))"
        done
        sleep 0.01
    done
}

#================= OPERACIONES TÁCTICAS ==================#

banner() {
    clear
    echo -e "${MORADO}${NEGRITA}"
    cat << "EOF"
    ██╗  ██╗ █████╗ ██████╗██╗  ██╗██╗  ██╗     ▀█▀ █▀█ █░█ █▄█
    ██║ ██╔╝██╔══██╗╚═══██╗██║ ██╔╝██║ ██╔╝     ░█░ █▄█ █▄█ ░█░
    █████═╝ ███████║ █████║█████═╝ █████═╝
    ██╔═██╗ ██╔══██║██╔═══╝██╔═██╗ ██╔═██╗
    ██║ ╚██╗██║  ██║╚██████╗██║ ╚██╗██║ ╚██╗
    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝
EOF
    echo -e "${CELESTE}     KUY KÓSMICO v6.0 - Hacker Multinacional de Barrio${END}\n"
}

hackeo_epico() {
    local objetivo="$1"
    echo -e "${NEGRITA}${AMARILLO}Objetivo fijado: ${ROJO}$objetivo${END}"
    sleep 1

    declare -A misiones=(
        ["🇷🇺 FSB"]="Injectando vodka digital..."
        ["🇨🇳 MSS"]="Descifrando firewall con Mahjong chino..."
        ["🇮🇱 Mossad"]="Atacando con hummus binario..."
        ["🇺🇸 NSA"]="Desplegando Freedom.exe..."
        ["🇵🇪 Cuy Hackers"]="Ejecutando chifa SQL con salsa anticuchera..."
        ["🇻🇦 Vaticano"]="Bendiciendo paquetes con agua bendita digital..."
    )

    for clave in "${!misiones[@]}"; do
        progreso 0.03 "${MORADO}${clave}${END} ${misiones[$clave]}"
    done

    echo -e "\n${VERDE}${NEGRITA}>> Hackeo completado con éxito interdimensional.${END}\n"
}

veredicto() {
    echo -e "${SUBR}${BLANCO}INFORME FINAL - Análisis de la Coalición Hacker Internacional:${END}\n"
    sleep 1
    declare -a frases=(
        "${ROJO}🇷🇺 KGB: Codificas como en Siberia: frío y lento.${END}"
        "${AMARILLO}🇨🇳 CCP: Tus hacks no pasarían el firewall de mi abuela.${END}"
        "${AZUL}🇮🇱 Mossad: Te falta hummus y te sobra sudo.${END}"
        "${BLANCO}🇺🇸 NSA: Te vigilamos... pero no por bueno.${END}"
        "${MORADO}🇵🇪 CuyTech: Apruébalo con ceviche y Ctrl+C.${END}"
    )
    for f in "${frases[@]}"; do
        escribir "$f" 0.03
        sleep 0.5
    done
    echo -e "\n${NEGRITA}${CELESTE}>> Resultado: Apto para trolear hasta Skynet.${END}"
}

#================= PROGRAMA PRINCIPAL ==================#

main() {
    banner
    escribir "${CELESTE}Bienvenido agente. Introduce el objetivo cibernético:${END}" 0.04
    read -p ">> " objetivo

    hackeo_epico "$objetivo"
    veredicto
}

main
