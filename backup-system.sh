#!/bin/bash
set -euo pipefail

# Variables principales
REPO_URL="https://github.com/tuusuario/backup-system.git"
SCRIPT_NAME="backup-system.sh"
LOCAL_SCRIPT="/usr/local/bin/$SCRIPT_NAME"
REPO_DIR="/tmp/backup-system-repo"

# Variables para flags
ACTION=""
UUID=""
MOUNT_POINT=""
NOTIFY=0
GIT_VALIDATE=0
GIT_UPDATE=0
BACKUP_VERSION=""
PRIVATE_KEY_PATH=""
HOSTNAME_LOCAL=""
ARGS=("$@")

# Funciones de colores para salida
msg_info() { echo -e "\e[34m[INFO]\e[0m $*"; }
msg_warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
msg_error() { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }
notify() {
  if [[ $NOTIFY -eq 1 && -x "$(command -v notify-send)" ]]; then
    notify-send "Backup System" "$*"
  fi
}

# Detectar gestor de paquetes según distro
detect_package_manager() {
  if [[ -x "$(command -v apt-get)" ]]; then
    echo "apt-get"
  elif [[ -x "$(command -v dnf)" ]]; then
    echo "dnf"
  elif [[ -x "$(command -v yum)" ]]; then
    echo "yum"
  elif [[ -x "$(command -v pacman)" ]]; then
    echo "pacman"
  elif [[ -x "$(command -v zypper)" ]]; then
    echo "zypper"
  else
    echo ""
  fi
}

# Instalar comando si no está instalado
check_install_cmd() {
  local cmd=$1
  if ! command -v "$cmd" &>/dev/null; then
    local pm=$(detect_package_manager)
    msg_warn "No encontré '$cmd', intentando instalar con $pm..."
    case "$pm" in
      apt-get)
        sudo apt-get update && sudo apt-get install -y "$cmd" || { msg_error "No pude instalar $cmd"; exit 1; }
        ;;
      dnf)
        sudo dnf install -y "$cmd" || { msg_error "No pude instalar $cmd"; exit 1; }
        ;;
      yum)
        sudo yum install -y "$cmd" || { msg_error "No pude instalar $cmd"; exit 1; }
        ;;
      pacman)
        sudo pacman -Sy --noconfirm "$cmd" || { msg_error "No pude instalar $cmd"; exit 1; }
        ;;
      zypper)
        sudo zypper install -y "$cmd" || { msg_error "No pude instalar $cmd"; exit 1; }
        ;;
      *)
        msg_error "No pude detectar gestor de paquetes para instalar $cmd"
        exit 1
        ;;
    esac
  fi
}

# Montar USB si no está montado
mount_usb() {
  check_install_cmd mount
  if mountpoint -q "$MOUNT_POINT"; then
    msg_info "USB ya está montado en $MOUNT_POINT"
  else
    msg_info "Montando USB en $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
    # Detectar dispositivo por UUID
    if [[ -n "$UUID" ]]; then
      local dev=$(blkid -U "$UUID")
      if [[ -z "$dev" ]]; then
        msg_error "No encontré dispositivo con UUID $UUID"
        exit 1
      fi
      sudo mount "$dev" "$MOUNT_POINT"
    else
      msg_error "No especificaste UUID para montar USB"
      exit 1
    fi
  fi
}

# Setup udev con regla para detectar USB con UUID
setup_udev() {
  check_install_cmd udevadm
  local rule_file="/etc/udev/rules.d/99-backup-system.rules"
  local script_path="$LOCAL_SCRIPT"

  if [[ ! -f "$script_path" ]]; then
    msg_error "No encontré el script $script_path, por favor instala antes"
    exit 1
  fi

  # Detectar UUID
  if [[ -z "$UUID" ]]; then
    msg_error "Necesito el UUID para configurar la regla udev (-u UUID)"
    exit 1
  fi

  echo "ACTION==\"add\", SUBSYSTEM==\"block\", ENV{ID_FS_UUID}==\"$UUID\", RUN+=\"$script_path -b -u $UUID -m $MOUNT_POINT -n\"" | sudo tee "$rule_file" >/dev/null
  msg_info "Regla udev creada en $rule_file"

  # Recargar reglas udev
  sudo udevadm control --reload-rules && sudo udevadm trigger
  notify "Setup finalizado. Conecta el USB para backups automáticos."
}

# Funciones backup, restore, limpieza, etc. aquí se mantienen igual (no las copio para no repetir todo)

# --- Main ---

# Parsear parámetros (simplificado)
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "Uso: $0 [-s|-b|-r] [-u UUID] [-m MOUNT_POINT] [-n]"
      exit 0
      ;;
    -s) ACTION="setup"; shift ;;
    -b) ACTION="backup"; shift ;;
    -r) ACTION="restore"; shift ;;
    -u) UUID="$2"; shift 2 ;;
    -m) MOUNT_POINT="$2"; shift 2 ;;
    -n) NOTIFY=1; shift ;;
    --git-validate) GIT_VALIDATE=1; shift ;;
    --git-update) GIT_UPDATE=1; shift ;;
    *) msg_warn "Opción desconocida $1"; shift ;;
  esac
done

# Default mount point
if [[ -z "$MOUNT_POINT" ]]; then
  MOUNT_POINT="/mnt/backup_usb"
fi

# Acciones
case "$ACTION" in
  setup)
    setup_udev
    ;;
  backup)
    mount_usb
    # Aquí iría create_backup
    ;;
  restore)
    mount_usb
    # Aquí iría restore_backup
    ;;
  *)
    msg_error "Debes especificar una acción: -s, -b o -r"
    exit 1
    ;;
esac
