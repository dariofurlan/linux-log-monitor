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
# todo: instead of making more difficult than it is use
# todo: tail -1 /var/log/commands.log
# todo: so that we still get the last command at least in teory...

command_hook='RETURN_VAL=$?; python3 ~/Desktop/github/linux-log-monitor/action.py command $(whoami) $RETURN_VAL "$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")"'
newline1="export PROMPT_COMMAND='$command_hook'"
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

login_hook2='(python3 ~/Desktop/github/linux-log-monitor/action.py login $(whoami) $(echo ${SSH_CLIENT%% *}))'
login_hook='(echo "{\"event\":\"login\"}" >/dev/tcp/127.0.0.1/9000) 2>/dev/null'
file_login_hook="/etc/profile.d/login_hook.sh"
if [[ ! -e ${file_login_hook} ]]
then
    if is_string_to_write ${login_hook} ${file_login_hook}
    then
        echo "added login hook"
        echo ${login_hook} > ${file_login_hook}
    fi
fi
