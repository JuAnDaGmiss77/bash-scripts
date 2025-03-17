#!/bin/bash

# Script de configuración de entorno de desarrollo en Debian
# Instalación de: python, VSCode, Brave, PostgreSQL
# Validación e instalación de XFCE si es necesario
# Creación de atajos de teclado para XFCE

# Función para mostrar mensajes de estado
print_status() {
    echo "=== $1 ==="
}

# Función para verificar si el comando fue exitoso
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Actualizar repositorios
print_status "Actualizando repositorios"
sudo apt update
check_command "No se pudieron actualizar los repositorios"

# Verificar si XFCE está instalado
print_status "Verificando si XFCE está instalado"
if ! dpkg -l | grep -q xfce4-session; then
    print_status "XFCE no está instalado. Instalando XFCE..."
    sudo apt install -y xfce4 xfce4-goodies
    check_command "No se pudo instalar XFCE"
    
    # Configurar XFCE como entorno de escritorio predeterminado
    if [ -f /usr/bin/update-alternatives ]; then
        sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session
    fi
    
    # Crear directorio de configuración si no existe
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    
    # Configurar tema oscuro para XFCE
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << EOL
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
EOL

    # Configurar fondo de pantalla oscuro
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << EOL
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="color1" type="array">
            <value type="uint" value="0"/>
            <value type="uint" value="0"/>
            <value type="uint" value="0"/>
            <value type="uint" value="65535"/>
          </property>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOL

    print_status "XFCE instalado y configurado en modo oscuro"
else
    print_status "XFCE ya está instalado. Continuando con la configuración..."
fi

# Instalar dependencias básicas
print_status "Instalando dependencias básicas"
sudo apt install -y curl wget apt-transport-https software-properties-common ca-certificates gnupg lsb-release xdg-utils
check_command "No se pudieron instalar las dependencias básicas"


# Instalar Python y pip
print_status "Instalando Python y pip"
sudo apt install -y python3 python3-pip python3-venv
check_command "No se pudo instalar Python"

# Crear alias para python (si es necesario)
if ! command -v python &> /dev/null; then
    echo "alias python='python3'" >> ~/.bashrc
    echo "alias pip='pip3'" >> ~/.bashrc
fi

# Instalar Visual Studio Code
print_status "Instalando Visual Studio Code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code
check_command "No se pudo instalar Visual Studio Code"

# Instalar Brave Browser
print_status "Instalando Brave Browser"
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser
check_command "No se pudo instalar Brave Browser"

# Instalar PostgreSQL
print_status "Instalando PostgreSQL"
sudo apt install -y postgresql postgresql-contrib
check_command "No se pudo instalar PostgreSQL"

# Iniciar servicio de PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql
check_command "No se pudo iniciar el servicio de PostgreSQL"

# Crear directorio para atajos de teclado de XFCE si no existe
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/

# Crear atajos de teclado para XFCE
print_status "Configurando atajos de teclado para XFCE"
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml << EOL
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="exo-open --launch TerminalEmulator"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;b" type="string" value="brave-browser"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;c" type="string" value="code"/>
    </property>
  </property>
</channel>
EOL

# Configurar VSCode con tema oscuro
print_status "Configurando VSCode con tema oscuro"
mkdir -p ~/.config/Code/User/
cat > ~/.config/Code/User/settings.json << EOL
{
    "workbench.colorTheme": "Default Dark+",
    "editor.fontSize": 14,
    "editor.tabSize": 4,
    "editor.renderWhitespace": "boundary",
    "editor.formatOnSave": true,
    "terminal.integrated.fontSize": 14
}
EOL

# Mostrar mensaje de finalización
print_status "Instalación completada"
echo "Reinicia tu terminal para que los cambios surtan efecto"
echo "Atajos de teclado configurados:"
echo "Ctrl+Alt+T: Abrir terminal"
echo "Ctrl+Alt+B: Abrir Brave Browser"
echo "Ctrl+Alt+C: Abrir Visual Studio Code"
echo ""
echo ""
echo "Cierra sesión y vuelve a iniciar para que los cambios de XFCE y los atajos de teclado funcionen correctamente"

# Cambiar shell predeterminada a Zsh
print_status "Cambiando shell predeterminada a Zsh"
chsh -s $(which zsh)
