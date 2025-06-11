# Raspberry 4G Router

Este proyecto permite convertir una Raspberry Pi equipada con un HAT 4G (modelo EC25-A) en un router 4G funcional. El dispositivo compartirá conexión a internet móvil a través de su puerto Ethernet (`eth0`), actuando como puerta de enlace para otros dispositivos conectados por cable.

## 🛠️ Requisitos

### Hardware
- Raspberry Pi (probado en Raspberry Pi 2B v1.1)
- Módulo HAT 4G EC25-A (con conexión por USB)
- Antena 4G
- Tarjeta SIM con saldo y datos activos
- Cable Ethernet

### Software
- Raspberry Pi OS (probado con Legacy Desktop)
- Acceso por terminal (local o SSH)

## Descripción
El conjunto de scripts automatiza la configuración de red para que la Raspberry Pi use el módem 4G como salida a internet y comparta la conexión con otros dispositivos a través de la interfaz Ethernet.

Los pasos son:
1. Preparar el sistema (desactivar NetworkManager, instalar dependencias).
2. Configurar IP estática y DNS para la interfaz Ethernet.
3. Activar el módem 4G, establecer la conexión y configurar NAT para compartir internet.

---

## Estructura del proyecto

```plaintext
raspberry-4g-router/
├── scripts/
│   ├── setup/
│   │   └── prepare.sh       # Paso 1: Preparar el sistema
│   ├── configure.sh         # Paso 2: Configurar IP y red
│   └── finalize.sh          # Paso 3: Activar módem y NAT
├── README.md
├── LICENSE
└── .gitignore
```

## Instrucciones de uso
### Paso 1: Preparar el sistema
- Asegúrate de que la Raspberry Pi esté conectada a Internet por cable Ethernet.
- Desconecta el módem 4G (HAT) USB de la Raspberry Pi.
- Ejecuta el script prepare.sh:
    
```plaintext
sudo bash ./scripts/setup/prepare.sh
```

El script desactivará NetworkManager, instalará dependencias y reiniciará la Raspberry Pi.
Luego conecta el módem 4G por USB y continúa al siguiente paso.

### Paso 2: Configurar IP estática y DNS

