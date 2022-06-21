#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

checkBackupBucket "$1"

maxBackupCount=14

backupFilesCount=$(ls "$backupDir" | wc -w)
backupFiles=($(ls "$backupDir"))

cloudBackupFilesCount=$($oci_path os object list -bn "$backupBucket" | jq '.data | length')
mapfile -t cloudBackupFiles < <($oci_path os object list -bn "$backupBucket" | jq --raw-output '.data | .[] | .name' | sort)

log "[$(currentDay)] Amount of backups are at $backupFilesCount files\n"

if [ "$backupFilesCount" -gt "$maxBackupCount" ]; then
    diff=$(("$backupFilesCount"-"$maxBackupCount"-1))
    diffLog=$(("$diff"+1))
    log "[$(currentDay)] Amount of backups have surpassed $maxBackupCount. Deleting $diffLog old files.\n"
    for i in $(seq 0 $diff); do
        file="${backupFiles[i]}"
        log "[$(currentDay)] Local | Deleting $file.\n"
        sudo -u "$minecraftUser" rm "$backupDir/$file"
    done
fi

if [ "$cloudBackupFilesCount" -gt "$maxBackupCount" ]; then
    diff=$(("$cloudBackupFilesCount"-"$maxBackupCount"-1))
    diffLog=$(("$diff"+1))
    log "[$(currentDay)] Amount of Cloud backups have surpassed $maxBackupCount. Deleting $diffLog old files.\n"
    for i in $(seq 0 $diff); do
        file="${cloudBackupFiles[i]}"
        log "[$(currentDay)] Cloud | Deleting $file.\n"
        $oci_path os object delete -bn "$backupBucket" ---object-name "$file"
    done
fi

$exit 0
