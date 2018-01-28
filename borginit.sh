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
## initialize borg repository
##

borg init --encryption=repokey