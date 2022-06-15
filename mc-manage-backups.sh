#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

maxBackupCount=14
backupFilesCount=$(ls "$backupDir" | wc -w)
backup_files=($(ls $backupDir))

log "[$currentDay] Amount of backups are at $backupFilesCount files\n"

if [ "$backupFilesCount" -gt "$maxBackupCount" ]; then
    diff=$(("$backupFilesCount"-"$maxBackupCount"-1))
    diffLog=$(("$diff"+1))
    log "[$currentDay] Amount of backups have surpassed $maxBackupCount. Deleting $diffLog old files.\n"
    for i in $(seq 0 $diff); do
        file="${backup_files[i]}"
        log "[$currentDay] Deleting $file.\n"
        sudo -u "$minecraftUser" rm "$backupDir/$file"
    done
fi

$exit 0
