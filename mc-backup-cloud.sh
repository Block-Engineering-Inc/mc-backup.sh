#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh)

source "$dirname"/constants.sh

exit=$( [[ $0 == -bash ]] && echo return || echo exit )

log () {
    # Echos text passed to function and appends to file at same time
    builtin echo -e "$@" | tee -a "$logFile"
}

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

oci_version=$(oci --version)

# Check for backup folder existence
if [ ! -d "$backupDir" ]; then
    log "[$currentDay] Error: Backup folder not found! Backup has been cancelled. ($backupDir)\n"
    $exit 1
fi

if [ -z "$backupBucket" -a -z "$1" ]; then
    log "[$currentDay] Error: No backup bucket defined! Backup has been cancelled.\n"
    $exit 1
elif [ -z "$backupBucket" -a -n "$1" ]; then
    backupBucket="$1"
    log "[$currentDay] Backup bucket defined: $backupBucket\n"
else
    log "[$currentDay] Backup bucket defined: $backupBucket\n"
fi

backup_files=($(ls $backupDir))

log "[$currentDay] Backup files: ${backup_files[-1]}\n"
$oci_path os object put -bn "$backupBucket" --file "$backupDir/${backup_files[-1]}" --name "${backup_files[-1]}" | tee -a "$logFile"
