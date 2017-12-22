#!/bin/bash

##
## Variablen
##

LOG="" # path of logfile
BACKUP_USER="" # username for repository
REPOSITORY_DIR="" # remote directory to store backups
RSA_PATH="" # path of rsa key
PASSPHRASE="" # passphrase for encryption of borg backup
BNAME={now:%Y-%m-%d_%H:%M} # name of backup

##
## Repository
##

REPOSITORY="ssh://${BACKUP_USER}@${BACKUP_USER}.your-storagebox.de:23/./${REPOSITORY_DIR}" # repository address, in example with hetzner storage box

##
## Ausgabe in Logfile
##

exec > >(tee -i ${LOG})
exec 2>&1
echo "##### Hostname: $(hostname) #####"
echo "##### Backup gestartet $(date) #####"

##
## Borg Export
##

export BORG_PASSPHRASE="$PASSPHRASE"
export BORG_RSH="ssh -i $RSA_PATH"

##
## BORG BACKUP
##

echo "Synchronisiere Dateien ..."
borg create -v --stats -C lz4                           \
    $REPOSITORY::${BNAME}                               \
      /                                                 \
      --exclude /dev                                    \
      --exclude /proc                                   \
      --exclude /sys                                    \
      --exclude /var/run                                \
      --exclude /run                                    \
      --exclude /lost+found                             \
      --exclude /mnt                                    \
      --exclude /var/lib/lxcfs

##
## BORG PRUNE
##

borg prune -v --list $REPOSITORY \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6

##
## Backup beenden
##

echo "###### Backup beendet: $(date) ######"

##
## Mail versenden
## send mails with the mailgun curl "api"
## https://documentation.mailgun.com/en/latest/quickstart-sending.html#send-via-api
##

curl -s --user '#####' \ # place your api key instead of #####
    https://api.mailgun.net/v3/#####/messages \ # place your domain name instead of #####
    -F from='AH:Backup <backup@example.tld>' \ # sender of the mail
    -F to=### \ # recipient of the mail
    -F subject="AH:Backup on $(hostname -f)" \ # subject of the mail
    -F text="$(cat $LOG)"

##
## Log schreiben und löschen
##

echo "" >> /var/log/borg.log
cat "$LOG" >> /var/log/borg.log
rm "$LOG"