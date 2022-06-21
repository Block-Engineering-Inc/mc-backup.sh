#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

serverRunning=true
worldsOnly=false
pluginOnly=false
pluginconfigOnly=false
startStop=false
regex="[0-9]+[MGkKm][Bb]?"

worldfoldercheck () {
    # Checks to make sure all the worlds defined in serverWorlds array exist as directories
    for item in "${serverWorlds[@]}"
    do
        if [ ! -d "$backupDir"/"$item" ]; then
            log "[$(currentDay)] Error: World folder not found! Backup has been cancelled. ($backupDir/$item)\n"
            $exit 1
	fi
    done
}
deleteBackup() {
    # Deletes contents of backupDir
    if [ "$(ls -A "$backupDir")" ]; then
	log "[$(currentDay)] Warning: Backup directory not empty! Deleting contents before proceeding...\n"
        rm -R "${backupDir:?}"/*
        $exit 1
    fi
}

# USER INPUT
while [ $# -gt 0 ];
do
    case "$1" in
      -h|--help)
        read -p "MC-BACKUP by Jordan B
        ---------------------------
        A compression script of
        [$serverDir] to [$backupDir] for $serverName!
        Usage:
            No args | Compress $serverName root dir.
            -h | Help (this).
            -w | Compress worlds only.
            -p | Compress plugins only.
            -pc | Compress plugin config files only.
            -r | Restarts the server."
        $exit 0
        ;;
      -w|--worlds)
        worldfoldercheck
        worldsOnly=true
        ;;
      -p|--plugin)
        pluginOnly=true
        ;;
      -pc|--pluginconfig)
        pluginconfigOnly=true
        ;;
      -r|--restart)
        startStop=true
        ;;
      *)
      echo "[$(currentDay)] Error: Invalid argument: ${1}\n"
      ;;
    esac
    shift
done

# Logs error and cancels script if too many args given to script
if [ $# -gt 1 ]; then
    log -e "[$(currentDay)] Error: Too many arguments! Backup has been cancelled.\n"
    $exit 1
fi
# Logs error and cancels script if serverDir isn't found
if [ ! -d "$serverDir" ]; then
    log "[$(currentDay)] Error: Server folder not found! Backup has been cancelled. ($serverDir)\n"
    $exit 1
fi
# Logs error and cancels script if backupDir isn't found
if [ ! -d "$backupDir" ]; then
    log "[$(currentDay)] Error: Backup folder not found! Backup has been cancelled. ($backupDir)\n"
    $exit 1
fi
# Logs error if JAVA process isn't detected but will continue anyways!!
if ! pgrep -u "$minecraftUser" "java"; then
    log "[$(currentDay)] Warning: $serverName is not running! Continuing without in-game warnings...\n"
    serverRunning=false
fi

if ! sudo -n true; then
    log "[$(currentDay)] Please use user with sudo privileges."
    $exit 1
fi

# Wont do anything if server is running - Stop it
if $serverRunning; then
    log "[$(currentDay)] Server is running. Stopping it..."
    # Restart the server logic
    source "$dirname"/mc-manage-server.sh
    
    stopMessage
    log "[$(currentDay)] Sent players message"

    stopServer
    log "[$(currentDay)] Server stopped"
    serverRunning=false
fi

# Grabs date in seconds BEFORE compression begins
elapsedTimeStart="$(date -u +%s)"
fixedCurrentDay="$(currentDay)"

# LOGIC HANDLING
if $worldsOnly; then
    log "[$(currentDay)] Worlds only started ...\n"
    # Starts the tar with files from the void (/dev/null is a symlink to a non-existent dir) so that multiple files can be looped in from array then gziped together.
    sudo -u "$minecraftUser" tar cf "$backupDir"/"$serverName"[WORLDS]-"$(currentDay)".tar --files-from /dev/null
    for item in "${serverWorlds[@]}"
    do
        sudo -u "$minecraftUser" tar rf "$backupDir"/"$serverName"[WORLDS]-"$(currentDay)".tar "$serverDir/$item"
    done
    gzip "$backupDir"/"$serverName"[WORLDS]-"$(currentDay)".tar
elif $pluginOnly; then
    log "[$(currentDay)] Plugins only started...\n"
    sudo -u "$minecraftUser" tar -czPf "$backupDir"/"$serverName"[PLUGINS]-"$(currentDay)".tar.gz "$serverDir"/plugins
elif $pluginconfigOnly; then
    log "[$(currentDay)] Plugin Configs only started...\n"
    sudo -u "$minecraftUser" tar -czPf "$backupDir"/"$serverName"[PLUGIN-CONFIG]-"$(currentDay)".tar.gz --exclude='*.jar' "$serverDir"/plugins
elif $startStop; then
    log "[$(currentDay)] Skipping backup\n"
else
    log "[$(currentDay)] Full compression started...\n"
    sudo -u "$minecraftUser" tar -czPf "$backupDir"/"$serverName"-"$fixedCurrentDay".tar.gz "$serverDir"
    log "[$(currentDay)] Compressed file: $backupDir/$serverName-$fixedCurrentDay.tar.gz"
fi

# Grabs date in seconds AFTER compression completes then does math to find time it took to compress
elapsedTimeEnd="$(date -u +%s)"
elapsed="$(($elapsedTimeEnd-$elapsedTimeStart))"

# Grabs size of item in backuplocation, assumes compressed item is only file in dir via deletebackup function
compressedSize=$(du -sh "$backupDir"/"$serverName"-"$fixedCurrentDay" | grep -P "$regex")


if $worldsOnly; then
    log "[$(currentDay)] $serverWorlds compressed to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
elif $pluginOnly; then
    log "[$(currentDay)] $serverDir/plugins* compressed from $uncompressedSize to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
elif $pluginconfigOnly; then
    log "[$(currentDay)] Plugin configs compressed from $uncompressedSize to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
elif $startStop; then
    log "[$(currentDay)] Restart in progress."
else
    # Grabs size of Server file in kb for comparison on output
    uncompressedSize=$(du -sh "$serverDir" | grep -P "$regex")
    log "[$(currentDay)] $serverDir compressed from $uncompressedSize to $compressedSize and copied to $backupDir in $((elapsed/60)) min(s)!\n"
fi

backupFolderSize=$(du -sh "$backupDir" | grep -P "$regex")

log "[$(currentDay)] The backup folder is already $backupFolderSize in size."

if ! $serverRunning; then
    # start back again

    startServer
    log "[$(currentDay)] Server is starting."
fi
$exit 0
