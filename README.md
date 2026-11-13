# Bash Scripts ⚙️
![Bash](https://img.shields.io/badge/Bash-4%2B-4EAA25?logo=gnubash&logoColor=white)

A collection of Bash scripts for automation, API integration, backups, and DevOps tasks.

**[English](#english-) | [Español](#español-)**

---

## English 🇬🇧

### Overview 📋
This repository contains a curated collection of Bash scripts designed to automate various tasks: Auth0 API integration, EC2 backups, AWS Inspector reports, Docker security scanning, JSON/CSV conversion, local LLM API testing, and conditional workflows. Each script is ready to be customized for your environment.

### Project Structure 📁
```
Bash.Scripts/
├── Aws/Inspector/                    # AWS Inspector v2 reports
│   ├── inspector-findings-report.sh  # Export findings report to S3 (CSV/JSON)
│   └── filters-example.json          # Example filter criteria
├── Health-Check/                     # API/service health monitoring
│   └── health-check.sh               # Ping endpoints and report status
├── S3-Cleanup/                       # S3 bucket cleanup
│   └── s3-cleanup.sh                 # Delete objects older than X days
├── Log-Rotation/                     # Log retention and compression
│   └── log-rotation.sh               # Gzip old logs, delete past retention
├── Auth0/                            # Auth0 API integration
│   └── access-token.sh               # Client credentials flow for Auth0 tokens
├── Chat-ai/                          # OpenAI-compatible API testing
│   ├── chat-try.sh                   # Chat completion request with curl
│   └── chat-try.py                   # Same request with the OpenAI Python SDK
├── Docker-Vulnerabilities/           # Security scanning
│   └── Vulnerabilities.sh            # Build & scan Docker images with Trivy
├── EC2/backups/                      # AWS EC2 backup automation
│   ├── mongo-backup.sh               # MongoDB backup to S3
│   └── redis-backup.sh               # Redis backup to S3
├── Github/                           # Git helpers
│   └── gitclone.sh                   # Clone a repository using credentials from env vars
├── read-json-and-write-csv/          # Data transformation
│   └── create-csv.sh                 # Convert JSON to CSV (AWS resources)
├── two-instructions-in-one/          # Chained script execution
│   ├── first-instruction.sh
│   └── instructions.sh               # Runs instructions sequentially
└── if-conditions.sh                  # Branch-based Dockerfile modifications
```

### Quick Start 🚀
> 💡 Run any script with `bash script.sh`, or make it executable once with `chmod +x script.sh` and run `./script.sh`.

**AWS Inspector Findings Report** 🛡️
```bash
cd Aws/Inspector
bash inspector-findings-report.sh --help
bash inspector-findings-report.sh \
  --bucket my-bucket \
  --kms-arn arn:aws:kms:us-east-1:123456789012:key/xxxx \
  --region us-east-1 \
  --severity CRITICAL,HIGH \
  --download ./out
# Or use a filter file: --filter-file filters-example.json
```
Inspector v2 must be enabled in the region, and the S3 bucket and KMS key must be in the same region with policies that allow Inspector to write.

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

**Chat AI (OpenAI-compatible API)** 🤖
```bash
cd Chat-ai
# Requires an OpenAI-compatible server on localhost:4000 (e.g. LiteLLM + Ollama)
# Edit API_KEY, API_URL and model in the script
bash chat-try.sh
# Python version:
pip install openai
python chat-try.py
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

**Git Clone** 🐙
```bash
cd Github
export GIT_USERNAME=your-user GIT_PASSWORD=your-token
# Replace repo.git with your repository URL
bash gitclone.sh
```

**JSON to CSV** 📊
```bash
cd read-json-and-write-csv
# Requires: data.json in the same directory
bash create-csv.sh
```

**Branch-based Dockerfile changes** 🌿
```bash
# Set branch_name (e.g. from your CI's Build.SourceBranch); needs a Dockerfile in the current directory
bash if-conditions.sh
```

### Requirements 📦
General: Bash 4+. On Windows, use Git Bash or WSL.

| Script | Dependencies |
|--------|--------------|
| Aws/Inspector | AWS CLI, `jq`, Inspector v2 enabled, S3 bucket + KMS key |
| Health-Check | `curl` |
| S3-Cleanup | AWS CLI, `jq` |
| Log-Rotation | `gzip`, `find` |
| Auth0 | `curl` |
| Chat-ai | `curl` / Python 3 + `openai`, local OpenAI-compatible server |
| Docker-Vulnerabilities | Docker, Trivy |
| EC2 backups | AWS CLI, `mongodump` (Mongo) / Redis |
| Github | `git` |
| read-json-and-write-csv | `jq` |

### Configuration & Security 🔒
Some scripts (Auth0, Chat-ai, Github) need credentials. Never commit them: keep them in environment variables or in a local `.env` file (already ignored by `.gitignore`).

```bash
# .env
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
```

```bash
set -a; source .env; set +a   # export every variable in .env
bash Auth0/access-token.sh
```

Inside a script, read the value with a clear error if it is missing: `client_secret="${AUTH0_CLIENT_SECRET:?AUTH0_CLIENT_SECRET is not set}"`.

### Contributing 🤝
To add a new script:
1. Create a folder named after the task (e.g. `S3-Cleanup/`) and put the script inside.
2. Start the script with `#!/bin/bash`, add a header comment explaining what it does, its usage and dependencies, and use `set -euo pipefail` when possible.
3. Read secrets from environment variables, never hardcode them.
4. Update this README **in both languages**: project structure, Quick Start, and Requirements.

### License 📄
By Agustina Fassina

---

## Español 🇪🇸

### Descripción 📝
Este repositorio contiene una colección de scripts Bash diseñados para automatizar distintas tareas: integración con la API de Auth0, backups en EC2, reportes de AWS Inspector, escaneo de seguridad en Docker, conversión de JSON a CSV, pruebas de APIs de LLM locales y flujos condicionales. Cada script puede personalizarse según tu entorno.

### Estructura del Proyecto 📁
```
Bash.Scripts/
├── Aws/Inspector/                    # Reportes de AWS Inspector v2
│   ├── inspector-findings-report.sh  # Exporta reporte de hallazgos a S3 (CSV/JSON)
│   └── filters-example.json          # Ejemplo de criterios de filtro
├── Health-Check/                     # Monitoreo de APIs/servicios
│   └── health-check.sh               # Ping a endpoints y reporte de estado
├── S3-Cleanup/                       # Limpieza de buckets S3
│   └── s3-cleanup.sh                 # Eliminar objetos más antiguos que X días
├── Log-Rotation/                     # Retención y compresión de logs
│   └── log-rotation.sh               # Gzip a logs viejos, borrar según retención
├── Auth0/                            # Integración con Auth0
│   └── access-token.sh               # Flujo client credentials para tokens Auth0
├── Chat-ai/                          # Pruebas de APIs compatibles con OpenAI
│   ├── chat-try.sh                   # Request de chat completion con curl
│   └── chat-try.py                   # El mismo request con el SDK de OpenAI en Python
├── Docker-Vulnerabilities/           # Escaneo de seguridad
│   └── Vulnerabilities.sh            # Construir y escanear imágenes Docker con Trivy
├── EC2/backups/                      # Automatización de backups en EC2
│   ├── mongo-backup.sh               # Backup de MongoDB a S3
│   └── redis-backup.sh               # Backup de Redis a S3
├── Github/                           # Utilidades de Git
│   └── gitclone.sh                   # Clonar un repo usando credenciales de variables de entorno
├── read-json-and-write-csv/          # Transformación de datos
│   └── create-csv.sh                 # Convertir JSON a CSV (recursos AWS)
├── two-instructions-in-one/          # Ejecución encadenada de scripts
│   ├── first-instruction.sh
│   └── instructions.sh               # Ejecuta instrucciones secuencialmente
└── if-conditions.sh                  # Modificaciones de Dockerfile según rama
```

### Inicio Rápido 🚀
> 💡 Ejecutá cualquier script con `bash script.sh`, o dale permisos una vez con `chmod +x script.sh` y corré `./script.sh`.

**Reporte de hallazgos de AWS Inspector** 🛡️
```bash
cd Aws/Inspector
bash inspector-findings-report.sh --help
bash inspector-findings-report.sh \
  --bucket mi-bucket \
  --kms-arn arn:aws:kms:us-east-1:123456789012:key/xxxx \
  --region us-east-1 \
  --severity CRITICAL,HIGH \
  --download ./out
# O con un archivo de filtros: --filter-file filters-example.json
```
Inspector v2 debe estar habilitado en la región, y el bucket S3 y la clave KMS deben estar en la misma región, con políticas que permitan a Inspector escribir.

**Health Check** 🏥
```bash
cd Health-Check
# Editá ENDPOINTS en el script o pasá URLs como argumentos
bash health-check.sh
# O: bash health-check.sh https://api.example.com https://app.example.com
```

**S3 Cleanup** 🗑️
```bash
cd S3-Cleanup
bash s3-cleanup.sh mi-bucket backups/ 30
bash s3-cleanup.sh --execute mi-bucket backups/ 30
```

**Rotación de logs** 📜
```bash
cd Log-Rotation
# Editá LOG_DIR, GLOB, DELETE_GLOB, COMPRESS_AFTER_DAYS, DELETE_AFTER_DAYS
bash log-rotation.sh /var/log/miapp 30 7
bash log-rotation.sh --execute /var/log/miapp 30 7
```

**Token de acceso Auth0** 🔐
```bash
cd Auth0
# Editá el script con tus credenciales de Auth0 primero
bash access-token.sh
```

**Chat AI (API compatible con OpenAI)** 🤖
```bash
cd Chat-ai
# Requiere un servidor compatible con OpenAI en localhost:4000 (ej. LiteLLM + Ollama)
# Editá API_KEY, API_URL y el modelo en el script
bash chat-try.sh
# Versión en Python:
pip install openai
python chat-try.py
```

**Instrucciones encadenadas** ⛓️
```bash
cd two-instructions-in-one
bash instructions.sh
```

**Escaneo de vulnerabilidades Docker (Trivy)** 🐳
```bash
cd Docker-Vulnerabilities
# Configurá image_name y context_dir en el script
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

**Git Clone** 🐙
```bash
cd Github
export GIT_USERNAME=tu-usuario GIT_PASSWORD=tu-token
# Reemplazá repo.git por la URL de tu repositorio
bash gitclone.sh
```

**JSON a CSV** 📊
```bash
cd read-json-and-write-csv
# Requiere: data.json en el mismo directorio
bash create-csv.sh
```

**Cambios en Dockerfile según rama** 🌿
```bash
# Definí branch_name (ej. desde Build.SourceBranch de tu CI); necesita un Dockerfile en el directorio actual
bash if-conditions.sh
```

### Requisitos 📦
General: Bash 4+. En Windows, usá Git Bash o WSL.

| Script | Dependencias |
|--------|--------------|
| Aws/Inspector | AWS CLI, `jq`, Inspector v2 habilitado, bucket S3 + clave KMS |
| Health-Check | `curl` |
| S3-Cleanup | AWS CLI, `jq` |
| Log-Rotation | `gzip`, `find` |
| Auth0 | `curl` |
| Chat-ai | `curl` / Python 3 + `openai`, servidor local compatible con OpenAI |
| Docker-Vulnerabilities | Docker, Trivy |
| Backups EC2 | AWS CLI, `mongodump` (Mongo) / Redis |
| Github | `git` |
| read-json-and-write-csv | `jq` |

### Configuración y Seguridad 🔒
Algunos scripts (Auth0, Chat-ai, Github) necesitan credenciales. Nunca las commitees: guardalas en variables de entorno o en un archivo `.env` local (ya ignorado en `.gitignore`).

```bash
# .env
AUTH0_CLIENT_ID=tu-client-id
AUTH0_CLIENT_SECRET=tu-client-secret
```

```bash
set -a; source .env; set +a   # exporta todas las variables del .env
bash Auth0/access-token.sh
```

Dentro del script, leé el valor con un error claro si falta: `client_secret="${AUTH0_CLIENT_SECRET:?AUTH0_CLIENT_SECRET no está definida}"`.

### Contribuir 🤝
Para sumar un script nuevo:
1. Creá una carpeta con el nombre de la tarea (ej. `S3-Cleanup/`) y poné el script adentro.
2. Empezá el script con `#!/bin/bash`, agregá un comentario de cabecera con qué hace, cómo se usa y sus dependencias, y usá `set -euo pipefail` cuando sea posible.
3. Leé los secretos desde variables de entorno, nunca los escribas en el código.
4. Actualizá este README **en ambos idiomas**: estructura del proyecto, Inicio Rápido y Requisitos.

### Licencia 📄
Por Agustina Fassina
