#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

if ! sudo -n true; then
    log "[$(currentDay)] Please use user with sudo privileges."
    $exit 1
fi

if [ -f "$geyser_path" ]; then
    log "[$(currentDay)] Geyser found. Checking for updates..."
    geyser_folder=$(dirname "$geyser_path")
    sudo -u "$geyser_user" mv "$geyser_folder"/Geyser.jar "$geyser_folder"/Geyser.jar.old
    log "[$(currentDay)] Geyser backup made. Creating old file..."
    geyser_link="https://ci.opencollab.dev//job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/standalone/target/Geyser.jar"
    sudo -u "$geyser_user" wget -O "$geyser_folder/Geyser.jar" "$geyser_link"
    log "[$(currentDay)] Geyser updated."
fi

$exit 0
