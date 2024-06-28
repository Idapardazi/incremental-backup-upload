# Backup and Upload Script

This script allows you to create incremental backups of a specified directory, compress the backups, and upload them to a MinIO bucket. It uses Restic for creating incremental backups and MinIO client (`mc`) for uploading the backups.

## Prerequisites

1. **Restic**:
   - Install Restic:
     ```bash
     sudo apt update
     sudo apt install restic
     ```

2. **MinIO Client (mc)**:
   - Follow the [official MinIO client installation guide](https://docs.min.io/docs/minio-client-quickstart-guide.html).

## Usage

### Steps to Run the Script

1. **Save the script** to a file (e.g., `backup_script.sh`).
2. **Make the script executable**:
   ```bash
   chmod +x backup_script.sh
