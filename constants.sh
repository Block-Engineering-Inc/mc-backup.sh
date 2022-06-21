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
logFile="/home/ubuntu/projects/mc-backup.sh/mc-backup.log"
oci_path="/home/ubuntu/bin/oci"
overviewer_path="/home/ubuntu/projects/Minecraft-Overviewer/overviewer.py"
overviewer_config="/home/ubuntu/projects/cuervos-map/server.conf"
overviewer_site="/home/ubuntu/projects/cuervos-map"
