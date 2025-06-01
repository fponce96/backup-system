#!/bin/bash

# backup-system.sh
# Script argento para backup y restore del sistema con toda la facha

set -e

BACKUP_NAME=""
UUID=""
MOUNT_POINT=""
HOSTNAME=$(hostname)
VERSION="latest"
SCRIPT_PATH="/usr/local/bin/backup-system.sh"
UDEV_RULE="/etc/udev/rules.d/99-backup-system.rules"

# 💣 Che maestro, faltan herramientas, dejá, ya lo hago yo...
need_cmd() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "⛔ Che maestro, falta instalar '$cmd'. DEJÁ LOCO, YA LO HAGO YO..."
            sudo apt-get update && sudo apt-get install -y "$cmd"
        fi
    done
}

# 🧼 ALV los backups viejos
clean_old_backups() {
    echo "🧹 Limpiando backups con más de 3 meses... > ALV los Backups viejos"
    find "$MOUNT_POINT" -name "${HOSTNAME}-*-Backup.tar.zst.gpg" -mtime +90 -exec rm -f {} \;
}

# 💾 Backup del sistema
do_backup() {
    need_cmd gpg zstd tar date
    DATE=$(date +%Y%m%d)
    BACKUP_NAME="${HOSTNAME}-${DATE}-Backup.tar.zst.gpg"
    BACKUP_TMP="${MOUNT_POINT}/${HOSTNAME}-${DATE}-Backup.tar"

    echo "🧪 Preparando backup..."
    sudo tar --exclude=/home --exclude=/users --exclude=/proc --exclude=/sys \
        --exclude=/dev --exclude=/run --exclude=/tmp --exclude=/mnt --exclude=/media \
        --exclude=/lost+found -cpf - / /docker /volumes 2>/dev/null \
        | zstd -T0 -19 -o "${BACKUP_TMP}.zst"

    echo "🔐 Cifrando el backup con GPG (clave simétrica)..."
    gpg --symmetric --cipher-algo AES256 -o "${MOUNT_POINT}/${BACKUP_NAME}" "${BACKUP_TMP}.zst"
    rm -f "${BACKUP_TMP}.zst"
    echo "✅ Backup creado en: ${MOUNT_POINT}/${BACKUP_NAME}"

    clean_old_backups
}

# 🔁 Restaurar sistema
do_restore() {
    need_cmd gpg zstd tar

    BACKUP_FILE=""
    if [[ "$VERSION" == "latest" ]]; then
        BACKUP_FILE=$(ls -t "$MOUNT_POINT"/"${HOSTNAME}"-*-Backup.tar.zst.gpg 2>/dev/null | head -n1)
    else
        BACKUP_FILE="${MOUNT_POINT}/${HOSTNAME}-${VERSION}-Backup.tar.zst.gpg"
    fi

    if [[ ! -f "$BACKUP_FILE" ]]; then
        echo "❌ No encontré el backup para restaurar: $BACKUP_FILE"
        exit 1
    fi

    echo "⚠️ Vas a restaurar el sistema desde: $BACKUP_FILE"
    read -p "Última chance. Escribí 'RESTORE' para continuar, no te vas a mandar una cagada: " confirm
    if [[ "$confirm" != "RESTORE" ]]; then
        echo "⛔ Restauración cancelada, mejor así capo."
        exit 1
    fi

    echo "⏪ Restaurando sistema... agarrate"
    gpg --decrypt "$BACKUP_FILE" | zstd -d | sudo tar -xpf -
    echo "✅ Restauración completada, reiniciá el equipo."
}

# ⚙️ Configurar UDEV
setup_udev() {
    [[ -z "$UUID" ]] && echo "❌ Falta el UUID. Leé la documentación loco." && exit 1
    [[ -z "$MOUNT_POINT" ]] && MOUNT_POINT="/mnt/.backupUSB"

    # Validar que se corre desde un USB
    DEVICE=$(df -P . | tail -1 | awk '{print $1}')
    DEVICE_UUID=$(blkid -s UUID -o value "$DEVICE")

    if [[ "$DEVICE_UUID" != "$UUID" ]]; then
        echo "❌ Este USB no es el que dijiste. Conectá el correcto, man."
        exit 1
    fi

    echo "⚙️ Instalando script local en: $SCRIPT_PATH"
    sudo cp "$0" "$SCRIPT_PATH"
    sudo chmod +x "$SCRIPT_PATH"

    echo "⚙️ Escribiendo regla de udev..."
    echo "ACTION==\"add\", SUBSYSTEM==\"block\", ENV{ID_FS_UUID}==\"$UUID\", RUN+=\"/usr/local/bin/backup-system.sh -b -m $MOUNT_POINT\"" | sudo tee "$UDEV_RULE" > /dev/null

    echo "🔄 Recargando reglas de udev..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    echo "✅ Configuración completada. Backup se correrá al insertar el USB."
}

# 🆘 Ayuda
print_help() {
    cat <<EOF
Uso: backup-system.sh [opciones]

Opciones:
  -s                Configura UDEV y copia el script localmente
  -b                Crea un backup del sistema
  -r                Restaura un backup (requiere confirmación)
  -u <uuid>         UUID del USB para configurar la regla udev
  -m <mountpoint>   Punto de montaje del USB (por defecto: /mnt/.backupUSB)
  --host <nombre>   Nombre del host para restaurar (por defecto: hostname actual)
  -v <fecha>        Versión del backup a restaurar (formato YYYYMMDD o 'latest')
  -h, --help        Muestra esta ayuda

Ejemplos:
  ./backup-system.sh -b -m /mnt/backup
  ./backup-system.sh -r -m /mnt/backup -v latest
  ./backup-system.sh -s -u 1234-ABCD -m /mnt/.backupUSB
EOF
}

# 🧠 Parseo argento
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s) SETUP=true ;;
        -b) BACKUP=true ;;
        -r) RESTORE=true ;;
        -u) UUID="$2"; shift ;;
        -m) MOUNT_POINT="$2"; shift ;;
        -v) VERSION="$2"; shift ;;
        --host) HOSTNAME="$2"; shift ;;
        -h|--help) print_help; exit 0 ;;
        *) echo "❌ Parámetro no reconocido: $1"; print_help; exit 1 ;;
    esac
    shift
done

# 🧠 Ejecutar según parámetro
[[ "$SETUP" == true ]] && setup_udev
[[ "$BACKUP" == true ]] && do_backup
[[ "$RESTORE" == true ]] && do_restore

[[ "$SETUP" != true && "$BACKUP" != true && "$RESTORE" != true ]] && print_help
