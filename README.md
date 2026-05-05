# Bash Scripts ⚙️
A collection of Bash scripts for automation, API integration, backups, and DevOps tasks.

### Overview 📋
This repository contains a curated collection of Bash scripts designed to automate various tasks: Auth0 API integration, EC2 backups, Docker security scanning, JSON/CSV conversion, and conditional workflows. Each script is ready to be customized for your environment.

### Project Structure 📁
```
Bash.Scripts/
├── Health-Check/             # API/service health monitoring
│   └── health-check.sh       # Ping endpoints and report status
├── S3-Cleanup/               # S3 bucket cleanup
│   └── s3-cleanup.sh         # Delete objects older than X days
├── Log-Rotation/             # Log retention and compression
│   └── log-rotation.sh       # Gzip old logs, delete past retention
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

### Quick Start 🚀
**Health Check** 🏥
```bash
cd Health-Check
# Edit ENDPOINTS in the script or pass URLs as arguments
bash health-check.sh
# Or: bash health-check.sh https://api.example.com https://app.example.com
```

**S3 Cleanup** 🗑️
```bash
cd S3-Cleanup
bash s3-cleanup.sh my-bucket backups/ 30
bash s3-cleanup.sh --execute my-bucket backups/ 30
```

**Log rotation** 📜
```bash
cd Log-Rotation
# Edit LOG_DIR, GLOB, DELETE_GLOB, COMPRESS_AFTER_DAYS, DELETE_AFTER_DAYS
bash log-rotation.sh /var/log/myapp 30 7
bash log-rotation.sh --execute /var/log/myapp 30 7
```

**Auth0 Access Token** 🔐
```bash
cd Auth0
# Edit the script with your Auth0 credentials first
bash access-token.sh
```

**Chained Instructions** ⛓️
```bash
cd two-instructions-in-one
bash instructions.sh
```

**Docker Vulnerability Scan (Trivy)** 🐳
```bash
cd Docker-Vulnerabilities
# Configure image_name and context_dir in the script
bash Vulnerabilities.sh
```

**MongoDB Backup to S3** 💾
```bash
cd EC2/backups
bash mongo-backup.sh
```

**Redis Backup to S3** 💾
```bash
cd EC2/backups
bash redis-backup.sh
```

**JSON to CSV** 📊
```bash
cd read-json-and-write-csv
# Requires: data.json in the same directory
bash create-csv.sh
```

### Requirements 📦
| Script | Dependencies |
|--------|--------------|
| Health-Check | `curl` |
| S3-Cleanup | AWS CLI, `jq` |
| Log-Rotation | `gzip`, `find` |
| Auth0 | `curl` |
| Docker-Vulnerabilities | Docker, Trivy |
| EC2 backups | AWS CLI, `mongodump` (Mongo) / Redis |
| read-json-and-write-csv | `jq` |

### License 📄
By Agustina Fassina

## Español 🇪🇸
### Descripcion 📝
Este repositorio contiene una coleccion de scripts Bash diseñados para automatizar distintas tareas: integracion con la API de Auth0, backups en EC2, escaneo de seguridad en Docker, conversion de JSON a CSV y flujos condicionales. Cada script puede personalizarse segun tu entorno.

### Estructura del Proyecto 📁
```
Bash.Scripts/
├── Health-Check/             # Monitoreo de APIs/servicios
│   └── health-check.sh       # Ping a endpoints y reporte de estado
├── S3-Cleanup/               # Limpieza de buckets S3
│   └── s3-cleanup.sh         # Eliminar objetos mas antiguos que X dias
├── Log-Rotation/             # Retencion y compresion de logs
│   └── log-rotation.sh       # Gzip a logs viejos, borrar segun retencion
├── Auth0/                    # Integracion con Auth0
│   └── access-token.sh       # Flujo client credentials para tokens Auth0
├── Docker-Vulnerabilities/   # Escaneo de seguridad
│   └── Vulnerabilities.sh    # Construir y escanear imagenes Docker con Trivy
├── EC2/backups/              # Automatizacion de backups en EC2
│   ├── mongo-backup.sh       # Backup de MongoDB a S3
│   └── redis-backup.sh       # Backup de Redis a S3
├── read-json-and-write-csv/  # Transformacion de datos
│   └── create-csv.sh         # Convertir JSON a CSV (recursos AWS)
├── two-instructions-in-one/  # Ejecucion encadenada de scripts
│   ├── first-instruction.sh
│   └── instructions.sh       # Ejecuta instrucciones secuencialmente
└── if-conditions.sh          # Modificaciones de Dockerfile segun rama
```

### Inicio Rapido 🚀
**Health Check** 🏥
```bash
cd Health-Check
# Edita ENDPOINTS en el script o pasa URLs como argumentos
bash health-check.sh
# O: bash health-check.sh https://api.example.com https://app.example.com
```

**S3 Cleanup** 🗑️
```bash
cd S3-Cleanup
bash s3-cleanup.sh mi-bucket backups/ 30
bash s3-cleanup.sh --execute mi-bucket backups/ 30
```

**Rotacion de logs** 📜
```bash
cd Log-Rotation
# Edita LOG_DIR, GLOB, DELETE_GLOB, COMPRESS_AFTER_DAYS, DELETE_AFTER_DAYS
bash log-rotation.sh /var/log/miapp 30 7
bash log-rotation.sh --execute /var/log/miapp 30 7
```

**Token de acceso Auth0** 🔐
```bash
cd Auth0
# Edita el script con tus credenciales de Auth0 primero
bash access-token.sh
```

**Instrucciones encadenadas** ⛓️
```bash
cd two-instructions-in-one
bash instructions.sh
```

**Escaneo de vulnerabilidades Docker (Trivy)** 🐳
```bash
cd Docker-Vulnerabilities
# Configura image_name y context_dir en el script
bash Vulnerabilities.sh
```

**Backup de MongoDB a S3** 💾
```bash
cd EC2/backups
bash mongo-backup.sh
```

**Backup de Redis a S3** 💾
```bash
cd EC2/backups
bash redis-backup.sh
```

**JSON a CSV** 📊
```bash
cd read-json-and-write-csv
# Requiere: data.json en el mismo directorio
bash create-csv.sh
```

### Requisitos 📦
| Script | Dependencias |
|--------|--------------|
| Health-Check | `curl` |
| S3-Cleanup | AWS CLI, `jq` |
| Log-Rotation | `gzip`, `find` |
| Auth0 | `curl` |
| Docker-Vulnerabilities | Docker, Trivy |
| Backups EC2 | AWS CLI, `mongodump` (Mongo) / Redis |
| read-json-and-write-csv | `jq` |

### Licencia 📄
Por Agustina Fassina