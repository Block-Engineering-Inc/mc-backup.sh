## What is it?
A BASH script to automate graceful restarting & local backups of a Minecraft server running in Screen on Ubuntu managed by services.

## Setup   
1. Open the script in a text editor and change these variables in `constants.sh`:  
- **serverDir** = Your root server directory. *(dont include closing "/")*  
- **backupDir** = The location to backup the compressed files to. *(dont include closing "/")*   
- **serverName** = The name of your server.  
- **startScript** = The command to restart the server. Keep in mind this is run from the screen session.  
- **serverWorlds** = An array of the servers world directory names. Includes defaults, add any of your custom worlds, seperated by a space. (ex: "arena" "lobby" "creative")  

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
- Backup just world files every other day at midnight: ```00 24 * * 1,3,5 bash /home/me/mc-backup.sh -w```
- Backup just plugin config files every friday: ```00 24 * * 6 bash /home/me/mc-backup.sh -pc```
- Full server backup every monday at 8 AM: ```00 8 * * 1 bash /home/me/mc-backup.sh```

## CAVEATS
- TODO: add restart functionality
- Only 1 or no arg can be called at a time.
- only 1 screen session can be running on the system.
- No way to disable auto restart of the server after a successful compression. 
- Script will continue with 0 screens running and java not running but not if java is running and 0 screens. (already continues without exiting with 1 screen and java not running.) 
