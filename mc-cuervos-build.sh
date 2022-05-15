#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

if [ -z "$websiteBucket" -a -z "$1" ]; then
    log "[$currentDay] Error: No website bucket defined! Upload has been cancelled.\n"
    $exit 1
elif [ -z "$websiteBucket" -a -n "$1" ]; then
    websiteBucket="$1"
    log "[$currentDay] website bucket defined: $websiteBucket\n"
else
    log "[$currentDay] website bucket defined: $websiteBucket\n"
fi

log "[$currentDay] Website: Starting the build\n"
$overviewer_path $serverDir/world/ $overviewer_site

log "[$currentDay] Website: Uploading the build\n"
$oci_path os object bulk-upload -bn $websiteBucket --src-dir $overviewer_site/world-lighting/ --overwrite --prefix "world-lighting/"
