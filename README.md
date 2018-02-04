# AH Borg Backup Skript

This is a simple backup script for [borgbackup](https://borgbackup.readthedocs.io/en/stable/) with the opportunity to use mailgun for email notifications.
I work with the Hetzner Storage Box, so it is "pre-configured" for this backup target.

## Usage
1. Download the project
```
wget https://github.com/lehuizi/ah_borg_backup/archive/master.zip
```

2. Unzip the package
```
unzip master.zip
```

3. Jump into the directory
```
cd ah_borg_backup-master/
```

4. Make the files executable
```
chmod +x borgbackup.sh borginit.sh
```

5. Configure config.local (The descriptions in the config file will help you)

6. Initialize the borg repository
```
./borginit.sh
```

7. Setup Cronjob
```
crontab -e
```
```
0 0 * * * /path/to/ah_borg_backup-master/borgbackup.sh >/dev/null 2>&1
```

8. Run your first backup
```
./borgbackup.sh
```
