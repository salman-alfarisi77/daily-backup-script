#!/bin/bash

# Load environment variables from .env file securely
set -a
source .env
set +a

# Ensure the log directory exists
logDir="logs"
mkdir -p $logDir

# Log file for the current execution
logFile="$logDir/backup_$(date +'%Y%m%d_%H%M%S').log"

# Logging function
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" | tee -a $logFile
}

# Function to upload file to S3
upload_to_s3() {
    local file_path=$1
    local s3_bucket=$2
    local s3_key=$3

    if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_DEFAULT_REGION" || -z "$s3_bucket" || -z "$s3_key" ]]; then
        log "Missing AWS configuration or S3 parameters"
        return 1
    fi

    log "Uploading $file_path to s3://$s3_bucket/$s3_key"
    aws s3 cp "$file_path" "s3://$s3_bucket/$s3_key" --region "$AWS_DEFAULT_REGION" 2>&1 | tee -a $logFile
    if [[ $? -ne 0 ]]; then
        log "Failed to upload $file_path to s3://$s3_bucket/$s3_key"
        return 1
    fi
    log "Backup successfully uploaded to S3"
    return 0
}

# Validate the number of arguments
if [[ $# != 2 ]]; then
    log "Usage: backup.sh target_directory_name destination_directory_name"
    exit 1
fi

# Validate the directories
if [[ ! -d $1 || ! -d $2 ]]; then
    log "Invalid directory path provided"
    exit 1
fi

targetDirectory=$1
destinationDirectory=$2

log "Starting backup process"
log "Target Directory: $targetDirectory"
log "Destination Directory: $destinationDirectory"

currentTS=$(date +%s)
log "Current Timestamp: $currentTS"

backupFileName="backup-$currentTS.tar.gz"
log "Backup File Name: $backupFileName"

origAbsPath=$(pwd)
log "Original Absolute Path: $origAbsPath"

cd $destinationDirectory
destAbsPath=$(pwd)
log "Destination Absolute Path: $destAbsPath"
cd $origAbsPath

cd $targetDirectory
log "Changed directory to: $(pwd)"

yesterdayTS=$(($currentTS - 86400))
log "Yesterday Timestamp: $yesterdayTS"

declare -a toBackup

for file in $(ls); do
    fileModTime=$(date -r $file +%s)
    if [[ $fileModTime -gt $yesterdayTS ]]; then
        toBackup+=($file)
    fi
done

if [ ${#toBackup[@]} -eq 0 ]; then
    log "No files to backup"
else
    tar -czf $origAbsPath/$backupFileName ${toBackup[@]} 2>&1 | tee -a $logFile
    if [[ $? -ne 0 ]]; then
        log "Failed to create backup file"
        exit 1
    fi
    log "Backup created: $origAbsPath/$backupFileName"

    mv $origAbsPath/$backupFileName $destAbsPath 2>&1 | tee -a $logFile
    if [[ $? -ne 0 ]]; then
        log "Failed to move backup file to $destAbsPath"
        exit 1
    fi
    log "Backup moved to: $destAbsPath/$backupFileName"
fi

if [[ "$AWS_UPLOAD" == "true" && -f $destAbsPath/$backupFileName ]]; then
    upload_to_s3 "$destAbsPath/$backupFileName" "$S3_BUCKET" "$S3_KEY/$backupFileName"
    if [[ $? -ne 0 ]]; then
        log "Failed to upload backup to S3"
        exit 1
    fi
fi

log "Backup process completed successfully"
