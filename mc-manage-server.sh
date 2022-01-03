#!/bin/bash

path=$(readlink -f $BASH_SOURCE)
dirname=${path%/*}

required_files=(constants.sh)

exit=$( [[ $0 == -bash ]] && echo return || echo exit )

log () {
    # Echos text passed to function and appends to file at same time
    builtin echo -e "$@" | tee -a mc-backup_log.txt
}

# Do we execute?

for v in ${required_files[*]}; { [[ -r "$dirname"/${v} ]] || { log "File ${v} not found. Exiting..."; $exit; }; }

source constants.sh

stopMessage () {
    # injects commands into console via stuff to warn chat of backup, sleeps for graceperiod, restarts, sleeps for hdd spin times
    log "[$currentDay] Warning players & stopping $serverName...\n"
    screen -p 0 -X stuff "say $serverName is restarting in $gracePeriod!$(printf \\r)"
    sleep $gracePeriod
    screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
    screen -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
}
stopServer(){
    service mysql stop
    log "[$currentDay] Stopped Service"
}
startServer(){
    service mysql start
    log "[$currentDay] Started Service"
}

# USER INPUT
while [ $# -gt 0 ];
do
    case "$1" in
      -s|--start)
        startServer
        ;;
      -t|--stop)
        stopServer
        ;;
      *)
      log -e "[$currentDay] Error: Invalid argument: ${1}\n"
      ;;
    esac
    shift
done
