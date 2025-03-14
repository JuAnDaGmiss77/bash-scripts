#!/bin/bash
# Script para cambiar el tema del sistema a oscuro en XFCE

echo "=== Cambiando el tema del sistema a oscuro en XFCE ==="

# Función para mostrar mensaje y salir en caso de error
error_exit() {
    echo "Error: $1"
    exit 1
}

# Verificar si se está usando XFCE (opcional)
if [ "$XDG_CURRENT_DESKTOP" != "XFCE" ] && [ "$DESKTOP_SESSION" != "xfce" ]; then
    echo "Advertencia: No parece que estés en un entorno XFCE. El script continuará, pero los cambios podrían no surtir efecto."
fi

# Intentar usar xfconf-query si está instalado
if command -v xfconf-query &>/dev/null; then
    echo "Usando xfconf-query para configurar el tema..."
    xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark" --create -t string || error_exit "No se pudo configurar el tema"
    xfconf-query -c xsettings -p /Net/IconThemeName -s "elementary-xfce-dark" --create -t string || error_exit "No se pudo configurar el icon theme"
    echo "Tema y iconos configurados a oscuro mediante xfconf-query."
else
    echo "xfconf-query no está disponible, se modificará el archivo de configuración XML directamente."
    
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
fi

echo "=== Operación completada ==="
echo "Reinicia tu sesión o el sistema para que los cambios surtan efecto."
