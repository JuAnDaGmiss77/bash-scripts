#!/bin/bash
# Script para cambiar el tema del sistema a oscuro en XFCE,
# incluyendo la instalación de dbus-x11 si falta dbus-launch

echo "=== Cambiando el tema del sistema a oscuro en XFCE ==="

# Función para mostrar mensaje y salir en caso de error
error_exit() {
    echo "Error: $1"
    exit 1
}

# Verificar si dbus-launch está disponible, de lo contrario instalar dbus-x11
if ! command -v dbus-launch &>/dev/null; then
    echo "dbus-launch no se encontró. Instalando dbus-x11..."
    sudo apt update || error_exit "Error actualizando repositorios"
    sudo apt install -y dbus-x11 || error_exit "No se pudo instalar dbus-x11"
fi

# Verificar si se está en una sesión gráfica
if [ -z "$DISPLAY" ]; then
    echo "Advertencia: La variable DISPLAY no está definida. Asegúrate de ejecutar este script en una sesión gráfica de XFCE."
    echo "Continuando con la modificación directa del archivo XML..."
fi

# Intentar usar xfconf-query si está disponible y si DISPLAY está definida
if command -v xfconf-query &>/dev/null && [ -n "$DISPLAY" ]; then
    echo "Usando xfconf-query para configurar el tema..."
    xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark" --create -t string
    if [ $? -ne 0 ]; then
        echo "Advertencia: No se pudo configurar el tema mediante xfconf-query."
    else
        xfconf-query -c xsettings -p /Net/IconThemeName -s "elementary-xfce-dark" --create -t string
        echo "Tema y iconos configurados a oscuro mediante xfconf-query."
        exit 0
    fi
fi

echo "xfconf-query no se pudo usar correctamente, modificando archivo XML directamente."

# Definir ruta de configuración
CONFIG_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
CONFIG_FILE="$CONFIG_DIR/xsettings.xml"

# Crear directorio si no existe
mkdir -p "$CONFIG_DIR" || error_exit "No se pudo crear el directorio de configuración: $CONFIG_DIR"

# Realizar backup del archivo existente (si existe)
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak" || error_exit "No se pudo crear backup de $CONFIG_FILE"
    echo "Backup de xsettings.xml creado en $CONFIG_FILE.bak"
fi

# Escribir la nueva configuración
cat > "$CONFIG_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Adwaita-dark"/>
    <property name="IconThemeName" type="string" value="elementary-xfce-dark"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="-1"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
EOF

echo "Configuración de tema oscuro aplicada en $CONFIG_FILE."
echo "=== Operación completada ==="
echo "Reinicia tu sesión o el sistema para que los cambios surtan efecto."
