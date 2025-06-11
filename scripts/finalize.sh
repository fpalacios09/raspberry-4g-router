#!/bin/bash
set -e

clear
echo "*****************************************************************"
echo "         ¡ATENCIÓN! REQUISITOS ANTES DE EJECUTAR                  "
echo "*****************************************************************"
echo
echo "🔴 1. El HAT EC25-A DEBE estar CONECTADO por USB"
echo "🔴 2. La ANTENA 4G debe estar INSTALADA y bien enroscada"
echo "🔴 3. La tarjeta SIM DEBE estar INSERTADA y con saldo"
echo "🔴 4. El cable Ethernet DEBE estar DESCONECTADO"
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

echo "1. Verificando detección del módem..."
mmcli -L || { echo "No se detectó el módem. Verificá conexión USB y SIM."; exit 1; }

echo "2. Activando módem manualmente..."
sudo mmcli -m 0 -e || { echo "Error al activar el módem."; exit 1; }

echo "3. Conectando usando APN..."
sudo mmcli -m 0 --simple-connect="apn=internet.tigo.py" || { echo "Error al conectar el módem con APN."; exit 1; }

echo "4. Esperando unos segundos para que se establezca la conexión..."
sleep 10

echo "5. Probando conexión a internet..."
# 3 intentos a google.com
for i in {1..3}; do
    echo "Intento $i/3 con google.com..."
    if ping -c 2 google.com; then
        echo "✓ Ping exitoso a google.com"
        CONEXION_OK=true
        break
    fi
    sleep 5
done

# Si fallaron los 3 intentos a google.com, prueba con 8.8.8.8
if [ -z "$CONEXION_OK" ]; then
    echo "❌ Falló ping a google.com. Probando con 8.8.8.8..."
    if ! ping -c 2 8.8.8.8; then
        echo "❌ No hay conexión a Internet (falló incluso 8.8.8.8)."
        echo "Verificá:"
        echo "1. Señal de antena (mmcli -m 0 --signal-get)"
        echo "2. Configuración APN"
        echo "3. Saldo de la SIM"
        exit 1
    fi
fi

echo "6. Configurando dnsmasq para DHCP en eth0..."
if ! grep -q "^interface=eth0" /etc/dnsmasq.conf; then
    sudo bash -c 'echo -e "\ninterface=eth0\ndhcp-range=192.168.100.10,192.168.100.50,12h" >> /etc/dnsmasq.conf'
fi

sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq

echo "7. Habilitando reenvío de paquetes IPv4..."
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

echo "8. Configurando reglas iptables para NAT..."
sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
sudo iptables -A FORWARD -i usb0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "9. Guardando reglas iptables para que persistan tras reinicios..."
sudo netfilter-persistent save
sudo netfilter-persistent reload

echo "*****************************************************************"
echo "¡Configuración finalizada! El dispositivo conectado a eth0 debería"
echo "tener acceso a internet a través del módem 4G."
echo "*****************************************************************"
