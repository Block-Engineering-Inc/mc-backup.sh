#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh)

source "$dirname"/constants.sh

exit=$( [[ $0 == -bash ]] && echo return || echo exit )

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

oci_version=$(oci --version)

# Check for backup folder existence
if [ ! -d "$backupDir" ]; then
    "[$currentDay] Error: Backup folder not found! Backup has been cancelled. ($backupDir)\n"
    $exit 1
fi

if [ -z "$backupBucket" ]; then
    log "[$currentDay] Error: No backup bucket defined! Backup has been cancelled.\n"
    $exit 1
fi

backup_files=($(ls $backupDir))

oci os object put -bn $backupBucket --file $backupDir/${backup_files[-1]} --name $backup_files
