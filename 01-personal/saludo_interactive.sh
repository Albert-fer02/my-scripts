#!/bin/bash

# Script con interacción del usuario
echo "¿Cómo te llamas?"
read nombre

echo "Hola, $nombre. Es un placer conocerte."
echo "¿Cuál es tu edad?"
read edad

echo "¡Wow! $edad años es una gran edad para aprender Bash."

# Calcular año de nacimiento aproximado
anio_actual=$(date +%Y)
anio_nacimiento=$((anio_actual - edad))

echo "Naciste aproximadamente en el año $anio_nacimiento."