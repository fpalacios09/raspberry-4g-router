#!/bin/bash
set -e

clear
echo "*****************************************************************"
echo "         ¡ATENCIÓN! REQUISITOS ANTES DE EJECUTAR ESTE SCRIPT      "
echo "*****************************************************************"
echo
echo "🔴 1. El HAT EC25-A DEBE estar colocado y CONECTADO por USB"
echo "🔴 2. La ANTENA 4G debe estar INSTALADA y bien enroscada"
echo "🔴 3. El cable Ethernet (eth0) DEBE estar DESCONECTADO"
echo
echo "⚠️  Si no se cumplen estos pasos, la configuración FALLARÁ"
echo "*****************************************************************"
echo
read -p "¿Cumpliste con TODOS los requisitos? [s/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "🛑 Configuración cancelada. Por favor verifica los requisitos."
    exit 1
fi

echo "1. Configurando IP estática para eth0 y DNS..."

# Remueve posibles líneas previas para evitar duplicados
grep -v -E '^interface eth0|^static ip_address=|^nohook wpa_supplicant|^static domain_name_servers=' /etc/dhcpcd.conf > /tmp/dhcpcd.conf.tmp

sudo tee /etc/dhcpcd.conf > /dev/null << EOF
$(cat /tmp/dhcpcd.conf.tmp)
interface eth0
static ip_address=192.168.100.1/24
nohook wpa_supplicant
static domain_name_servers=8.8.8.8 8.8.4.4
EOF

rm /tmp/dhcpcd.conf.tmp

echo
echo "2. Luego del reinicio, ejecutá el siguiente script para finalizar la configuración:"
echo "   sudo ./finalize.sh"
echo
echo "Presioná Enter para reiniciar la Raspberry Pi y aplicar los cambios..."
read -r
echo "Reiniciando ahora..."

sudo reboot
