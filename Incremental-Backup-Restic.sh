#!/bin/bash

# Function to get user input for the directory path
get_path() {
  read -p "Enter the path to backup: " path
  echo $path
}

# Function to set MinIO credentials
set_minio_credentials() {
  read -p "Enter MinIO Access Key: " minio_access_key
  read -p "Enter MinIO Secret Key: " -s minio_secret_key
  echo
  export MINIO_ACCESS_KEY=$minio_access_key
  export MINIO_SECRET_KEY=$minio_secret_key
}

# Function to initialize Restic repository if not already initialized
initialize_restic_repo() {
  local repo=$1
  if ! restic -r $repo snapshots > /dev/null 2>&1; then
    restic -r $repo init
  fi
}

# Function to perform incremental backup using Restic
perform_backup() {
  local path=$1
  local repo=$2
  restic -r $repo backup $path
}

# Function to compress the backup
compress_backup() {
  local backup_dir=$1
  local compressed_path="${backup_dir}.tar.gz"
  tar -czf "$compressed_path" -C "$(dirname "$backup_dir")" "$(basename "$backup_dir")"
  echo $compressed_path
}

# Function to upload to MinIO
upload_to_minio() {
  local file_path=$1
  local bucket_name=$2
  local object_name=$(basename "$file_path")
  mc cp "$file_path" "myminio/$bucket_name/$object_name"
  if [ $? -eq 0 ]; then
    echo "Successfully uploaded $file_path to $bucket_name/$object_name"
  else
    echo "Failed to upload $file_path"
  fi
}

# Main script logic
main() {
  # Get the path to backup
  path=$(get_path)

  if [ ! -d "$path" ]; then
    echo "The specified path does not exist."
    exit 1
  fi

  # Set MinIO credentials
  set_minio_credentials

  # Set MinIO alias
  mc alias set myminio http://172.17.0.1:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

  # Define Restic repository location (this can be a local directory or a MinIO bucket URL)
  restic_repo="s3:http://172.17.0.1:9000/backup-repo"
  export AWS_ACCESS_KEY_ID=$MINIO_ACCESS_KEY
  export AWS_SECRET_ACCESS_KEY=$MINIO_SECRET_KEY

  # Initialize Restic repository if necessary
  initialize_restic_repo $restic_repo

  # Perform incremental backup
  perform_backup $path $restic_repo

  # Define the directory where Restic stores the backup metadata
  backup_dir="$HOME/.cache/restic"

  # Compress the backup directory
  compressed_path=$(compress_backup "$backup_dir")

  # Upload compressed backup to MinIO
  bucket_name='homework2'
  upload_to_minio "$compressed_path" "$bucket_name"
}

# Run the main function
main


