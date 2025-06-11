#!/bin/bash
set -e

# Configurables
ETH_IFACE="eth0"
USB_IFACE="usb0"
PING_TEST="8.8.8.8"

clear
echo "*****************************************************************"
echo "ADVERTENCIA: Este proceso debe realizarse con conexión a Internet"
echo "             por Ethernet (cable), SIN el HAT 4G conectado."
echo "             Asegúrate de que:"
echo "             1. El HAT 4G NO está conectado a la Raspberry Pi"
echo "             2. Tienes conexión a Internet por cable Ethernet"
echo "*****************************************************************"
echo
read -p "Presiona Enter para continuar o Ctrl+C para cancelar..." -r

# Verificación mejorada de conexión
echo "Verificando condiciones del sistema..."

# 1. Verificar interfaz Ethernet
if ! ip link show $ETH_IFACE | grep -q "state UP"; then
    echo "❌ Error: $ETH_IFACE no está conectada o no está activa."
    echo "   Por favor conecta el cable Ethernet antes de continuar."
    exit 1
fi

# 2. Verificar ausencia de interfaz USB (HAT 4G)
if ip link show $USB_IFACE &>/dev/null; then
    echo "❌ Error: Se detectó $USB_IFACE (HAT 4G conectado)."
    echo "   Por favor desconecta el HAT 4G antes de continuar."
    exit 1
fi

# 3. Verificar conectividad a Internet
if ! ping -c 3 $PING_TEST &>/dev/null; then
    echo "❌ Error: No hay conexión a Internet."
    echo "   Por favor verifica tu conexión Ethernet."
    exit 1
fi

echo "✓ Verificación exitosa:"
echo "   - Ethernet ($ETH_IFACE) activa"
echo "   - HAT 4G ($USB_IFACE) no detectado"
echo "   - Conexión a Internet funcionando"

echo
echo "1. Deteniendo y eliminando NetworkManager para evitar conflictos..."
read -p "¿Estás seguro de querer eliminar NetworkManager? [s/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Instalación cancelada por el usuario."
    exit 0
fi

sudo systemctl stop NetworkManager || true
sudo systemctl disable NetworkManager || true
sudo apt remove -y network-manager

echo
echo "2. Actualizando repositorios e instalando paquetes necesarios..."
sudo apt update -y
sudo apt install -y modemmanager dnsmasq iptables iptables-persistent

echo
echo "3. El sistema se apagará para que conectes el HAT EC25-A por USB con SIM y ANTENA."
echo "   Después de encenderlo de nuevo, deberás ejecutar:"
echo "   sudo ./configure.sh"
echo
read -p "Presiona Enter para apagar ahora o Ctrl+C para cancelar..." -r
sudo shutdown -r now
