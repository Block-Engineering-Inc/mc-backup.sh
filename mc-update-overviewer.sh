#!/bin/bash

pathFile=$(readlink -f "$BASH_SOURCE")
dirname=${pathFile%/*}

required_files=(constants.sh lib.sh)

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { echo "File ${v} not found. Exiting..."; $exit; }; }

source "$dirname"/constants.sh
source "$dirname"/lib.sh

if [ -f "$overviewer_path" ]; then
    log "[$(currentDay)] Overviewer found. Checking for updates..."
    overviewer_folder=$(dirname "$overviewer_path")
    cd "$overviewer_folder" && git pull && $python_path "$overviewer_folder/setup.py" build
    log "[$(currentDay)] Overviewer updated."
fi

$exit 0
