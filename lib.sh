#!/bin/bash

exit=$( [[ $0 == -bash ]] && echo return || echo exit )

log () {
    # Echos text passed to function and appends to file at same time
    builtin echo -e "$@" | tee -a "$logFile"
}

currentDay() {
    # Returns date in format YYYY-MM-DD-HH:MM
    date +"%Y-%m-%d-%H:%M"
}

checkBackupBucket () {
    if [ -z "$backupBucket" -a -z "$1" ]; then
        log "[$(currentDay)] Error: No backup bucket defined! Backup has been cancelled.\n"
        $exit 1
    elif [ -z "$backupBucket" -a -n "$1" ]; then
        backupBucket="$1"
        log "[$(currentDay)] Backup bucket defined: $backupBucket\n"
    else
        log "[$(currentDay)] Backup bucket defined: $backupBucket\n"
    fi
}