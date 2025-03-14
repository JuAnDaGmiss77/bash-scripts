#!/bin/bash
# Script para configurar Oh My Zsh con plugins recomendados y un tema oscuro (powerlevel10k)

# Función para mostrar mensajes de estado
print_status() {
    echo "=== $1 ==="
}

# Función para verificar si el comando se ejecutó correctamente
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Actualizar repositorios e instalar Zsh si no está instalado
print_status "Verificando e instalando Zsh (si es necesario)"
if ! command -v zsh &> /dev/null; then
    sudo apt update
    sudo apt install -y zsh
    check_command "No se pudo instalar Zsh"
else
    print_status "Zsh ya está instalado"
fi

# Instalar Oh My Zsh en modo no interactivo (si no está instalado)
if [ ! -d ~/.oh-my-zsh ]; then
    print_status "Instalando Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    check_command "No se pudo instalar Oh My Zsh"
else
    print_status "Oh My Zsh ya está instalado"
fi

# Definir directorio custom de Oh My Zsh
export ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Instalar o actualizar plugins recomendados

# zsh-autosuggestions
print_status "Instalando/actualizando zsh-autosuggestions"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    check_command "No se pudo clonar zsh-autosuggestions"
else
    print_status "zsh-autosuggestions ya está instalado"
fi

# zsh-syntax-highlighting
print_status "Instalando/actualizando zsh-syntax-highlighting"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    check_command "No se pudo clonar zsh-syntax-highlighting"
else
    print_status "zsh-syntax-highlighting ya está instalado"
fi

# zsh-completions
print_status "Instalando/actualizando zsh-completions"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
    check_command "No se pudo clonar zsh-completions"
else
    print_status "zsh-completions ya está instalado"
fi

# history-substring-search
print_status "Instalando/actualizando history-substring-search"
if [ ! -d "$ZSH_CUSTOM/plugins/history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/history-substring-search"
    check_command "No se pudo clonar history-substring-search"
else
    print_status "history-substring-search ya está instalado"
fi

# Instalar autojump (si no está instalado)
print_status "Verificando/instalando autojump"
if ! command -v autojump &> /dev/null; then
    sudo apt install -y autojump
    check_command "No se pudo instalar autojump"
else
    print_status "autojump ya está instalado"
fi

# Instalar Powerlevel10k (tema con estética oscura)
print_status "Instalando/actualizando Powerlevel10k"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    check_command "No se pudo clonar Powerlevel10k"
else
    print_status "Powerlevel10k ya está instalado"
fi

# Actualizar el archivo .zshrc para usar los plugins y el tema deseado
print_status "Actualizando .zshrc"
if [ -f ~/.zshrc ]; then
    # Configurar plugins y establecer el tema a powerlevel10k
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search autojump)/' ~/.zshrc
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
else
    # Si no existe, copiar la plantilla de Oh My Zsh y modificarla
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions history-substring-search autojump)/' ~/.zshrc
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# Cambiar la shell predeterminada a Zsh
print_status "Cambiando shell predeterminada a Zsh"
chsh -s "$(which zsh)"

print_status "Configuración de Oh My Zsh completada"
echo "Por favor, cierra la sesión y vuelve a iniciarla para ver los cambios."
