#!/usr/bin/env bash

is_string_to_write() {
    #pass as first argument the string ang then the file
    if `grep -Fxq "$1" $2 2>/dev/null`
    then
        false
    else
        true
    fi
}


if [[ "$EUID" -ne 0 ]]
then
    echo "Please run as root"
    exit
fi
log_hook='$((echo "{\"event\":\"command\"}" >/dev/tcp/127.0.0.1/9000) 2>/dev/null)'
log='$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]'
newline1="export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"${log_hook} ${log}\"'"
if is_string_to_write "$newline1" "/etc/bash.bashrc"
then
    echo "added command hook pt.1"
    echo "$newline1" >> /etc/bash.bashrc
fi
newline2="local6.*    /var/log/commands.log"
if is_string_to_write "$newline2" "/etc/rsyslog.d/bash.conf"
then
    echo "added command hook pt.2"
    echo "$newline2" >> /etc/rsyslog.d/bash.conf
fi

file_login_hook="/etc/profile.d/login_hook.sh"
login_hook='(echo "{\"event\":\"login\"}" >/dev/tcp/127.0.0.1/9000) 2>/dev/null'
if [[ ! -e ${file_login_hook} ]]
then
    if is_string_to_write ${login_hook} ${file_login_hook}
    then
        echo "added login hook"
        echo ${login_hook} > ${file_login_hook}
    fi
fi

# todo una grande libreria bash con tutte le funzioni per l'ambiente
# todo login hook da mettere in /etc/profile.d/[script].sh