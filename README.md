# 🧠 backup-system.sh

## 🇦🇷 Explicación bien argenta

Este script es un **backup y restore del sistema**, pero hecho con toda la onda, para que no te mandes ninguna cagada.

### ¿Qué hace?

- Te genera un backup comprimido con `zstd` y lo cifra con `gpg`, ¡como debe ser!
- Guarda los backups en un USB, y borra los que tengan más de 3 meses (ALV los viejos).
- Si enchufás el USB correcto, ¡te hace el backup solo! Magia pura.
- También podés restaurar desde un backup, pero no sin antes confirmar que no vas a romper todo.

### ¿Cómo se usa?

#### 🔧 Configurar (una sola vez)

Esto copia el script al sistema y crea una regla para que se ejecute cuando conectás el USB:

```bash
./backup-system.sh -s -u TU_UUID -m /mnt/.backupUSB
```

> Tenés que reemplazar `TU_UUID` por el UUID de tu pendrive.

#### 💾 Hacer backup

```bash
./backup-system.sh -b -m /mnt/.backupUSB
```

#### 🔁 Restaurar

```bash
./backup-system.sh -r -m /mnt/.backupUSB --host mi-servidor -v latest
```

> **Ojo loco**, tenés que escribir `RESTORE` para confirmar que sabés lo que estás haciendo.

---

## 🇬🇧 Professional English Description

### `backup-system.sh`: A Secure Linux Backup & Restore Automation Script

This script provides a reliable and automated way to back up and restore Linux systems using:

- `tar` for archiving
- `zstd` for high-performance compression
- `gpg` for encryption

It supports **automated backups when a specific USB device is connected**, via udev rules, and **manual restores with safety prompts**.

### 🔐 Features

- Creates compressed, encrypted backups of the system
- Excludes transient and unnecessary directories (e.g., `/proc`, `/tmp`)
- Automatically deletes backups older than 90 days
- Supports restoration of specific hosts and versions
- Installs missing dependencies on the fly

### 🧰 Requirements

- `tar`
- `zstd`
- `gpg`
- `udev` (for auto-backup on USB insertion)
- `sudo` privileges

### ⚙️ Setup

Register the USB device by UUID and create a udev rule:

```bash
./backup-system.sh -s -u YOUR-USB-UUID -m /mnt/.backupUSB
```

### 💾 Manual Backup

```bash
./backup-system.sh -b -m /mnt/.backupUSB
```

### 🔁 Manual Restore

```bash
./backup-system.sh -r -m /mnt/.backupUSB --host my-server -v 20250530
```

> The script will prompt the user to type `RESTORE` before proceeding.

### 📁 Backup Format

Backups are named using the format:

```
<hostname>-<date>-Backup.tar.zst.gpg
```

### 🔒 Restore Safety

The restore operation will:
- Require the user to explicitly confirm
- Use the latest backup or one by date
- Restore only if the USB device matches the expected UUID

---

## 📜 License

MIT – Use it, tweak it, mejoralo.

---

### Hecho con amor y mate, por un sysadmin argento.
