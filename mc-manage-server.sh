#!/bin/bash

stopMessage () {
    # injects commands into console via stuff to warn chat of backup, sleeps for graceperiod, restarts, sleeps for hdd spin times
    log "[$currentDay] Warning players & stopping $serverName...\n"
    sudo -u $minecraftUser screen -p 0 -X stuff "say $serverName is restarting in $gracePeriod!$(printf \\r)"
    sleep $gracePeriod
    sudo -u $minecraftUser screen -p 0 -X stuff "say $serverName is restarting now!$(printf \\r)"
    sudo -u $minecraftUser screen -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
}
stopServer(){
    sudo systemctl stop $serviceName
    log "[$currentDay] Stopped Service $serviceName"
}
startServer(){
    sudo systemctl start $serviceName
    log "[$currentDay] Started Service $serviceName"
}
