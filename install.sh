#!/usr/bin/env bash

# dependecies:
# inotify-tools

is_string_to_write() {
    #pass as first argument the string ang then the file
    if grep -Fxq "$1" $2
    then
        false
    else
        true
    fi
}

if [ "$EUID" -ne 0 ]
then
    echo "Please run as root"
    exit
fi

log_hook='$()'
log='$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]'
newline1="export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug '${log_hook} ${log}'"
if is_string_to_write "$newline1" "/etc/bash.bashrc"
then
    echo "$newline1" >> /etc/bash.bashrc
fi
newline2="local6.*    /var/log/commands.log"
if is_string_to_write "$newline2" "/etc/rsyslog.d/bash.conf"
then
    echo "$newline2" >> /etc/rsyslog.d/bash.conf
fi

# todo una grande libreria bash con tutte le funzioni per l'ambiente
# todo login hook da mettere in /etc/profile.d/[script].sh
