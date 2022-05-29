#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

serverRunning=true

# Logs error if JAVA process isn't detected but will continue anyways!!
if ! pgrep -u "$minecraftUser" "java"; then
    log "[$currentDay] Warning: $serverName is not running! Continuing without in-game warnings...\n"
    serverRunning=false
fi

if [ -z "$websiteBucket" -a -z "$1" ]; then
    log "[$currentDay] Error: No website bucket defined! Upload has been cancelled.\n"
    $exit 1
elif [ -z "$websiteBucket" -a -n "$1" ]; then
    websiteBucket="$1"
    log "[$currentDay] website bucket defined: $websiteBucket\n"
else
    log "[$currentDay] website bucket defined: $websiteBucket\n"
fi

# Wont do anything if server is running - Stop it
if $serverRunning; then
    log "[$currentDay] Server is running. Stopping it..."
    # Restart the server logic
    source "$dirname"/mc-manage-server.sh
    
    stopMessage
    log "[$currentDay] Sent players message"

    stopServer
    log "[$currentDay] Server stopped"
    serverRunning=false
fi

log "[$currentDay] Website: Starting the build for $overviewer_site\n"
$overviewer_path --config $overviewer_config --genpoi
$overviewer_path --config $overviewer_config

log "[$currentDay] Website: Uploading the build\n"
$oci_path os object put -bn $websiteBucket --file $overviewer_site/markers.js --name markers.js
$oci_path os object put -bn $websiteBucket --file $overviewer_site/markersDB.js --name markersDB.js
$oci_path os object bulk-upload -bn $websiteBucket --src-dir $overviewer_site/normalrender/ --overwrite --prefix "normalrender/"
$oci_path os object bulk-upload -bn $websiteBucket --src-dir $overviewer_site/survivalnether/ --overwrite --prefix "survivalnether/"

if ! $serverRunning; then
    # start back again

    startServer
    log "[$currentDay] Server is starting."
fi
$exit 0
