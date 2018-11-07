#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
then
    echo "Please run as root"
    exit
fi

# todo check if line is already written if not write the newline
log='$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]'
newline1="export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "${log}"'"
#echo "$newline1" >> /etc/bash.bashrc
echo $newline1

newline2="local6.*    /var/log/commands.log"
#echo "$newline2" >> /etc/rsyslog.d/bash.conf

# login hook da mettere in /etc/profile.d/[script].sh
