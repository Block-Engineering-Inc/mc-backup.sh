#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

serverRunning=true

if [ -z "$mc_version" -a -z "$1" ]; then
    log "[$currentDay] Error: No Version defined! Update has been cancelled.\n"
    $exit 1
elif [ -z "$mc_version" -a -n "$1" ]; then
    mc_version="$1"
    log "[$currentDay] Version defined: $mc_version\n"
else
    log "[$currentDay] Version defined: $mc_version\n"
fi

# Logs error if JAVA process isn't detected but will continue anyways!!
if ! pgrep -u "$minecraftUser" "java"; then
    log "[$currentDay] Warning: $serverName is not running! Continuing without in-game warnings...\n"
    serverRunning=false
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

if [ -f "$serverDir"/minecraft_server.jar.old ]; then
    log "[$currentDay] Server jar found. Deleting it..."
    sudo rm "$serverDir"/minecraft_server.jar.old
fi

sudo mv "$serverDir"/minecraft_server.jar "$serverDir"/minecraft_server.jar.old

versionManifestUrl=$(curl --silent 'https://launchermeta.mojang.com/mc/game/version_manifest.json' | jq --arg VANILLA_VERSION "$mc_version" --raw-output '[.versions[]|select(.id == $VANILLA_VERSION)][0].url')
mc_download_url=$(curl --silent $versionManifestUrl | jq '.downloads.server.url')

wget -q -O "$serverDir"/minecraft_server.jar "$mc_download_url"

if ! $serverRunning; then
    # start back again

    startServer
    log "[$currentDay] Server is starting."
fi
$exit 0
