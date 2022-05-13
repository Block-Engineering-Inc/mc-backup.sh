#!/bin/bash

# User Specific Oriented
serverDir="/opt/minecraft/survival"
backupDir="/opt/minecraft/full-backups"
serverName="survival"
gracePeriod="30s"
serverWorlds=("world")
serviceName="minecraft@survival.service"
minecraftUser="minecraft"

# Program Oriented
currentDay=$(date +"%Y-%m-%d-%H:%M")
logFile="mc-backup.log"
