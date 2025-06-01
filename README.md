
# backup-system

![backup-system](https://img.shields.io/badge/backup--system-v1.0-blue)

---

## 🇦🇷 Descripción (Español, tono porteño informal pero profesional)

Este **backup-system** es un script en Bash que te hace la vida más fácil para hacer backups automáticos hacia un USB, con compresión zstd y cifrado GPG. Además tiene soporte para reglas udev (así se ejecuta cuando enchufás el USB), limpieza automática de backups viejos, restauración fácil, validación y actualización automática desde GitHub. 

Ideal para laburar tranqui y que tus datos estén seguros sin estar pendiente todo el tiempo. Lo podés usar en cualquier GNU/Linux con bash, sin depender de interfaces gráficas, todo en línea de comandos. ¡Un golazo para los que bancan la consola!

---

## 🇬🇧 Description (English, professional tone)

**backup-system** is a Bash script designed to simplify automatic backups to USB devices, featuring zstd compression and GPG encryption. It supports udev rules for automatic triggering upon USB connection, automated old backup cleanup, easy restoration, integrity validation, and automatic updates from GitHub.

Ideal for sysadmins or users preferring CLI tools to keep data securely backed up without manual intervention. Compatible with any GNU/Linux system with Bash, no GUI dependencies required.

---

## 📥 Instalación

1. Cloná el repositorio (o descargá el script directamente):

```bash
git clone https://github.com/tuusuario/backup-system.git
cd backup-system
```

2. Instalá dependencias si no las tenés (se instalan automáticamente si el script tiene permisos):

- `zstd`
- `gpg`
- `mount`
- `udevadm`
- `notify-send` (opcional para notificaciones de escritorio)

3. Copiá el script al path para poder ejecutarlo fácil:

```bash
sudo cp backup-system.sh /usr/local/bin/backup-system.sh
sudo chmod +x /usr/local/bin/backup-system.sh
```

---

## ⚙️ Configuración y uso

### Parámetros principales

| Parámetro       | Descripción                                                                                  |
|-----------------|----------------------------------------------------------------------------------------------|
| `-s`            | Setup: instala la regla udev para detectar el USB y lanzar el backup automáticamente.       |
| `-b`            | Backup: realiza el backup manualmente.                                                      |
| `-r`            | Restore: restaura un backup desde el USB.                                                   |
| `-u UUID`       | UUID del dispositivo USB donde se hará el backup/restauración. Obligatorio para montaje.    |
| `-m MOUNT_POINT`| Punto de montaje local del USB. Por defecto `/mnt/backup_usb`.                              |
| `-n`            | Notificaciones desktop con notify-send.                                                     |
| `--git-validate`| Valida que el script local esté actualizado con la versión de GitHub.                       |
| `--git-update`  | Actualiza automáticamente el script desde GitHub.                                           |
| `-h, --help`    | Muestra ayuda con uso y parámetros.                                                         |

---

### Ejemplos prácticos

#### Setup con regla udev para backups automáticos al enchufar el USB

```bash
sudo backup-system.sh -s -u 1234-ABCD -m /mnt/backup_usb -n
```

Esta orden configura el sistema para que cuando conectes el USB con UUID `1234-ABCD`, se monte automáticamente en `/mnt/backup_usb` y se lance el backup. Las notificaciones de escritorio estarán activas.

#### Hacer un backup manual

```bash
backup-system.sh -b -u 1234-ABCD -m /mnt/backup_usb
```

Esto monta el USB y crea un backup con compresión y cifrado.

#### Restaurar un backup manualmente

```bash
backup-system.sh -r -u 1234-ABCD -m /mnt/backup_usb
```

Monta el USB y restaura el último backup disponible.

#### Validar actualización del script

```bash
backup-system.sh --git-validate
```

Chequea si el script local está actualizado con la versión en GitHub.

#### Actualizar el script desde GitHub

```bash
sudo backup-system.sh --git-update
```

Descarga la última versión y reemplaza el script local.

---

## 🔍 Detalles técnicos importantes

- El script monta el USB automáticamente con el UUID indicado.
- Usa `zstd` para comprimir los backups y ahorrar espacio.
- Los archivos quedan cifrados con GPG para seguridad.
- La regla udev permite que al enchufar el USB se ejecute el backup sin que intervengas.
- Limpia backups viejos para no saturar el dispositivo.
- La restauración valida que el backup esté íntegro.
- Actualiza el script con git para mantenerlo al día.

---

## 🔐 Seguridad y buenas prácticas

- Usá siempre claves GPG seguras y protegidas.
- No compartas la clave privada del cifrado.
- Mantené el USB en un lugar seguro.
- Verificá el espacio libre antes de lanzar backups.
- Probá la restauración periódicamente para asegurar la integridad.
- Usá usuarios con permisos mínimos necesarios para correr el script.
- Actualizá regularmente el script para tener mejoras y parches.

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT**.

```text
Copyright (c) 2025 Facundo Ponce - INSYCOM.com.ar

Email: fponce@insycom.com.ar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

[...]
```

---

## Contacto

Facundo Ponce  
INSYCOM.com.ar  
Email: fponce@insycom.com.ar  

---

¡Cualquier duda o mejora, tirame un mensaje!

---

*Backup your stuff, mate. No hay excusas para perder datos.*

---
