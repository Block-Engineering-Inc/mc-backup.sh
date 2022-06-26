# Automation Scripts for Minecraft Server using bash and oci

## What is it?
A BASH script to automate graceful restarting & local backups of a Minecraft server running in Screen on Ubuntu managed by services.
Included scripts to build website for the server with [Minecraft Overviewer](https://github.com/overviewer/Minecraft-Overviewer). And to upload to [Oracle Object Storage](https://docs.oracle.com/pt-br/iaas/Content/Object/Concepts/objectstorageoverview.htm) automated backups.
These scripts can be used separately defined by the calls in cron. So if not using any modules, just skip the config to call it.

## Setup   
1. Open the script in a text editor and change these variables in `constants.sh`:  
- **serverDir** = Your root server directory. *(dont include closing "/")*  
- **backupDir** = The location to backup the compressed files to. *(dont include closing "/")*   
- **serverName** = The name of your server.
- **gracePeriod** = Time in seconds to wait before server shutdown.
- **serverWorlds** = An array of the servers world directory names. Includes defaults, add any of your custom worlds, seperated by a space. (ex: "arena" "lobby" "creative")  
- **serviceName** = Name given when started the service. Used in `service $serviceName status`
- **minecraftUser** = What username is the server running on

The program oriented variables serve to use other related functionality that do not focus in the server backup.
- **logFile** = Name of the file to save the log in the home user folder.
- **oci_path** = Path to the [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm) executable.
- **overviewer_path** = Path to overviewer.
- **overviewer_config** = Path to the overviewer conf script. Example: https://pastebin.com/Qzq6JJK9
- **overviewer_site** = Path to the overviewer site. (Where it will be built)
- **python_path** = Path to the python executable. (To run overviewer build)

The Geyser variables are related to the [Geyser server](https://geysermc.org/).
- **geyser_path** = Path to the Geyser server executable.
- **geyser_user** = The username of the Geyser server.
- **geyser_service** = The name of the Geyser service.

2. Do not forget that the scripts relly on Minecraft running as a service. For more info check [this-link](https://linuxconfig.org/ubuntu-20-04-minecraft-server-setup).

## Usage  
``bash mc-backup.sh [-h, -w, -p, -pc] ``

- **No args:** Compresses entire server directory to backup location.  

- **-h | help:** Shows arguments/modes available.   

- **-w | Worlds:** Compresses world directories only to backup location   
- **-p | plugins:** Compresses plugin directory only to backup location. Includes plugin .jars. 

- **-pc | pluginconfig:** Compresses plugin config directories only to backup location. Ignores plugin .jars.  

**Best when automated with [Crontab](https://www.thegeekstuff.com/2009/06/15-practical-crontab-examples/).**  
Crontab examples:
- Backup just world files every other day at midnight: ```00 24 * * 1,3,5 bash /home/me/mc-backup.sh/mc-backup.sh -w```
- Backup just plugin config files every friday: ```00 24 * * 6 bash /home/me/mc-backup.sh/mc-backup.sh -pc```
- Full server backup every monday at 8 AM: ```00 8 * * 1 bash /home/me/mc-backup.sh/mc-backup.sh```
- Upload server backup to Oracle Object Storage every week: ```30 7 * * 1 /home/me/mc-backup.sh/mc-backup-cloud.sh BackupBucket```
```
0 7 * * 1,3,5 /home/ubuntu/projects/mc-backup.sh/mc-backup.sh
30 7 * * 1 /home/ubuntu/projects/mc-backup.sh/mc-backup-cloud.sh BackupBucket
0 7 * * 2,4,6 /home/ubuntu/projects/mc-backup.sh/mc-build-website.sh websiteBucket
```

## CAVEATS
- Only 1 or no arg can be called at a time.
- No way to disable auto restart of the server after a successful compression. 
- Script will continue with 0 screens running and java not running but not if java is running and 0 screens. (already continues without exiting with 1 screen and java not running.)
