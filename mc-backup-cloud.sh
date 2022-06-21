#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

# Check for backup folder existence
if [ ! -d "$backupDir" ]; then
    log "[$(currentDay)] Error: Backup folder not found! Backup has been cancelled. ($backupDir)\n"
    $exit 1
fi

checkBackupBucket "$1"

backup_files=($(ls $backupDir))

log "[$(currentDay)] Backup files: ${backup_files[-1]}\n"
$oci_path os object put -bn "$backupBucket" --file "$backupDir/${backup_files[-1]}" --name "${backup_files[-1]}" | tee -a "$logFile"

$exit 0