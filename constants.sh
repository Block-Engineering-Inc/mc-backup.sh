#!/bin/bash

# Backup Oriented
serverDir="/opt/minecraft/survival"
backupDir="/opt/minecraft/full-backups"
serverName="survival"
gracePeriod="30s"
serverWorlds=("world")
serviceName="minecraft@survival.service"
minecraftUser="minecraft"

# Cloud and Website Oriented
logFile="mc-backup.log"
oci_path="/home/ubuntu/bin/oci"
overviewer_path="/home/ubuntu/projects/Minecraft-Overviewer/overviewer.py"
overviewer_config="/home/ubuntu/projects/cuervos-map/server-prd.conf"

# Avoid changing
currentDay=$(date +"%Y-%m-%d-%H:%M")