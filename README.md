# 🛡️ backup-system

Sistema de backups automáticos hacia USB con compresión `zstd`, cifrado `GPG`, restauración, limpieza, validación y actualización desde GitHub. Hecho en Bash, simple pero poderoso.

![Logo Backup System](https://img.shields.io/badge/bash-script-blue.svg) ![License MIT](https://img.shields.io/badge/license-MIT-green.svg) ![Maintained](https://img.shields.io/badge/maintained-yes-brightgreen)

---

## 🇦🇷 Descripción

Este script fue creado con el objetivo de simplificar los backups automáticos hacia un dispositivo USB. Funciona en cualquier distro Linux y permite:

- 🔐 Cifrado automático con GPG (clave asimétrica).
- 🗜️ Compresión eficiente con Zstandard.
- 🔁 Restauración rápida desde USB.
- 📦 Limpieza de backups viejos.
- 🔔 Notificaciones opcionales con `notify-send`.
- 🧩 Integración con reglas Udev para ejecución automática al conectar USB.
- 🛠️ Autogeneración de llaves GPG si no existen.
- 📤 Copia de clave pública al mismo directorio para restauración remota.
- 🌐 Actualización desde GitHub.

---

## 🇺🇸 English Version

`backup-system` is a Bash script that automates backups to a USB device, compresses them using `zstd`, encrypts with `gpg`, and supports restore, cleanup, GitHub updates, and udev rules for automation.

---

## 📦 Instalación

```bash
git clone https://github.com/tuusuario/backup-system.git
cd backup-system
sudo cp backup-system.sh /usr/local/bin/backup-system.sh
sudo chmod +x /usr/local/bin/backup-system.sh
```

---

## 🛠️ Configuración

1. **Clave GPG:** el script generará automáticamente una si no tenés una existente.
2. **UUID:** conseguílo con `blkid` o `lsblk -f`.
3. **Configuración udev:**

```bash
sudo backup-system.sh -s -u TU_UUID -m /mnt/backup_usb -n
```

Esto crea una regla para ejecutar backup automáticamente al conectar el USB.

---

## 🚀 Uso

### Backup manual:

```bash
sudo backup-system.sh -b -u TU_UUID -m /mnt/backup_usb -n
```

### Restauración:

```bash
sudo backup-system.sh -r -u TU_UUID -m /mnt/backup_usb -n
```

### Setup udev:

```bash
sudo backup-system.sh -s -u TU_UUID -m /mnt/backup_usb
```

---

## 🧾 Parámetros

| Parámetro        | Descripción                                               |
|------------------|-----------------------------------------------------------|
| `-s`             | Setup del sistema y regla udev                            |
| `-b`             | Ejecuta el backup                                         |
| `-r`             | Restaura el último backup                                 |
| `-u UUID`        | UUID del dispositivo USB                                  |
| `-m MOUNTPOINT`  | Ruta donde montar el USB (default: /mnt/backup_usb)       |
| `-n`             | Activa notificaciones con `notify-send`                   |
| `--git-update`   | Actualiza el script desde GitHub                          |
| `--git-validate` | Valida si hay nueva versión disponible en el repositorio  |

---

## 🛡️ Seguridad

- Se genera automáticamente un par de claves GPG.
- La clave privada nunca se expone ni se copia fuera del sistema.
- El backup está comprimido y cifrado.
- La clave pública queda disponible junto al script para restauraciones remotas.

---

## 🎨 Imágenes

![Ejecución del backup](https://raw.githubusercontent.com/tuusuario/backup-system/main/images/backup.png)
![Restauración](https://raw.githubusercontent.com/tuusuario/backup-system/main/images/restore.png)

---

## 🧠 Buenas prácticas

- No pierdas tu clave privada.
- Hacé pruebas de restauración regularmente.
- Usá un USB exclusivamente para este propósito.
- Usá cron para backups periódicos si no usás Udev.

---

## 📝 Licencia

MIT License

```
Copyright (c) 2025 Facundo Ponce (INSYCOM.com.ar)
Email: fponce@insycom.com.ar
```

---

## ❤️ Contribuciones

Pull requests, issues o sugerencias son siempre bienvenidas.
