<div align="center">

# Bash Scripts &nbsp; 🐚 ⚡ 🔧 📜 🚀

A collection of Bash scripts for automation, API integration, backups, and DevOps tasks.

</div>

---

## English

### Overview

This repository contains a curated collection of Bash scripts designed to automate various tasks: Auth0 API integration, EC2 backups, Docker security scanning, JSON/CSV conversion, and conditional workflows. Each script is ready to be customized for your environment.

### Project Structure

```
Bash.Scripts/
├── Auth0/                    # Auth0 API integration
│   └── access-token.sh       # Client credentials flow for Auth0 tokens
├── Docker-Vulnerabilities/   # Security scanning
│   └── Vulnerabilities.sh    # Build & scan Docker images with Trivy
├── EC2/backups/              # AWS EC2 backup automation
│   ├── mongo-backup.sh       # MongoDB backup to S3
│   └── redis-backup.sh       # Redis backup to S3
├── read-json-and-write-csv/  # Data transformation
│   └── create-csv.sh         # Convert JSON to CSV (AWS resources)
├── two-instructions-in-one/  # Chained script execution
│   ├── first-instruction.sh
│   └── instructions.sh       # Runs instructions sequentially
└── if-conditions.sh          # Branch-based Dockerfile modifications
```

### Quick Start

**Auth0 Access Token:**
```bash
cd Auth0
# Edit the script with your Auth0 credentials first
bash access-token.sh
```

**Chained Instructions:**
```bash
cd two-instructions-in-one
bash instructions.sh
```

**Docker Vulnerability Scan (Trivy):**
```bash
cd Docker-Vulnerabilities
# Configure image_name and context_dir in the script
bash Vulnerabilities.sh
```

**MongoDB Backup to S3:**
```bash
cd EC2/backups
bash mongo-backup.sh
```

**Redis Backup to S3:**
```bash
cd EC2/backups
bash redis-backup.sh
```

**JSON to CSV:**
```bash
cd read-json-and-write-csv
# Requires: data.json in the same directory
bash create-csv.sh
```

### Requirements

| Script | Dependencies |
|--------|--------------|
| Auth0 | `curl` |
| Docker-Vulnerabilities | Docker, Trivy |
| EC2 backups | AWS CLI, `mongodump` (Mongo) / Redis |
| read-json-and-write-csv | `jq` |

### License

MIT

---

## Español

### Descripción

Este repositorio contiene una colección de scripts Bash diseñados para automatizar distintas tareas: integración con la API de Auth0, backups en EC2, escaneo de seguridad en Docker, conversión de JSON a CSV y flujos condicionales. Cada script puede personalizarse según tu entorno.

### Estructura del Proyecto

```
Bash.Scripts/
├── Auth0/                    # Integración con Auth0
│   └── access-token.sh       # Flujo client credentials para tokens Auth0
├── Docker-Vulnerabilities/   # Escaneo de seguridad
│   └── Vulnerabilities.sh    # Construir y escanear imágenes Docker con Trivy
├── EC2/backups/              # Automatización de backups en EC2
│   ├── mongo-backup.sh       # Backup de MongoDB a S3
│   └── redis-backup.sh       # Backup de Redis a S3
├── read-json-and-write-csv/  # Transformación de datos
│   └── create-csv.sh         # Convertir JSON a CSV (recursos AWS)
├── two-instructions-in-one/  # Ejecución encadenada de scripts
│   ├── first-instruction.sh
│   └── instructions.sh       # Ejecuta instrucciones secuencialmente
└── if-conditions.sh          # Modificaciones de Dockerfile según rama
```

### Inicio Rápido

**Token de acceso Auth0:**
```bash
cd Auth0
# Edita el script con tus credenciales de Auth0 primero
bash access-token.sh
```

**Instrucciones encadenadas:**
```bash
cd two-instructions-in-one
bash instructions.sh
```

**Escaneo de vulnerabilidades Docker (Trivy):**
```bash
cd Docker-Vulnerabilities
# Configura image_name y context_dir en el script
bash Vulnerabilities.sh
```

**Backup de MongoDB a S3:**
```bash
cd EC2/backups
bash mongo-backup.sh
```

**Backup de Redis a S3:**
```bash
cd EC2/backups
bash redis-backup.sh
```

**JSON a CSV:**
```bash
cd read-json-and-write-csv
# Requiere: data.json en el mismo directorio
bash create-csv.sh
```

### Requisitos

| Script | Dependencias |
|--------|--------------|
| Auth0 | `curl` |
| Docker-Vulnerabilities | Docker, Trivy |
| Backups EC2 | AWS CLI, `mongodump` (Mongo) / Redis |
| read-json-and-write-csv | `jq` |

### Licencia

MIT
