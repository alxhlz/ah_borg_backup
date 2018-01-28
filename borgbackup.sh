#!/bin/bash

##
## load config file
##

if [[ -z "$1" ]]; then
    CONFIG_FILE="$(dirname $0)/local.conf"
    echo "Using $CONFIG_FILE as config."
else
    CONFIG_FILE=$1
fi

if ! source "$(dirname $0)/local.conf"; then
    echo "Error: can't load configuration file local.conf"
    exit 1
fi

# only overwrite defaults
if ! source "$CONFIG_FILE"; then
    echo "Error: can't load configuration file $CONFIG_FILE"
    exit 1
fi

##
## write logfile
##

exec > >(tee -i ${LOG})
exec 2>&1
echo "##### Hostname: $(hostname) #####"
echo "##### Backup gestartet $(date) #####"

##
## BORG BACKUP
##

echo "Synchronisiere Dateien ..."
borg create -v --one-file-system --stats -C lz4            \
	::${PREFIX}-{now:%Y-%m-%d_%H:%M}                    \
      $BACKUP_DIRS                                      \
      --exclude /dev                                    \
      --exclude /proc                                   \
      --exclude /sys                                    \
      --exclude /var/run                                \
      --exclude /run                                    \
      --exclude /lost+found                             \
      --exclude /mnt                                    \
      --exclude /var/lib/lxcfs				            \
      --exclude /lib/modules				            \
      --exclude '*.pyc'                           	    \
      --exclude '/var/backups/'                         \
      --exclude '/var/log/'                           	\
      --exclude '*.swp'

##
## BORG PRUNE
##

borg prune -v -s --save-space --list :: --prefix ${PREFIX}- $KEEP_BACKUPS

##
## stop backup
##

echo "###### Backup beendet: $(date) ######"

##
## send mails with the mailgun api
## https://documentation.mailgun.com/en/latest/quickstart-sending.html#send-via-api
##

if [[ $MGENABLE = 1 ]]; then
    curl -s --user $MGAPI \
        https://api.mailgun.net/v3/$MGDOMAIN/messages \
        -F from="AH:Backup <$MGMAIL>" \
        -F to=$MGRECIPIENT \
        -F subject="AH:Backup on $(hostname -f)" \
        -F text="$(cat $LOG)"
fi

##
## Write log and delete temporary log
##

echo "" >> /var/log/borg.log
cat "$LOG" >> /var/log/borg.log
rm "$LOG"