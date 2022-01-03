#!/bin/bash

# User Specific Oriented
serverDir="/opt/minecraft/survival"
backupDir="/opt/minecraft/full-backups"
serverName="survival"
startScript="/opt/minecraft/survival/start.sh"
gracePeriod="30s"
serverWorlds=("world")

# Program Oriented
currentDay=$(date +"%Y-%m-%d-%H:%M")
