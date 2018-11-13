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

esc() {
    printf "%s\n" "$1" | sed -e "s/'/'\"'\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}
json_escape () {
    printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

if [[ "$EUID" -ne 0 ]]
then
    echo "Please run as root"
    exit
fi
# todo: instead of making more difficult than it is use
# todo: tail -1 /var/log/commands.log
# todo: so that we still get the last command at least in teory...

log_hook='$((echo "{\"event\":\"commands\",\"data\":{\"command\":$(esc "$LAST_CMD")}}" >/dev/tcp/127.0.0.1/9000 ) 2>/dev/null)'
log='$(whoami) [$$]: $LAST_CMD [$RETRN_VAL]'
newline1='export PROMPT_COMMAND='"'"'RETRN_VAL=$?;LAST_CMD=$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//");logger -p local6.debug '"${log}"';'"$log_hook';"
if is_string_to_write "$newline1" "/etc/bash.bashrc"
then
    echo "added command hook pt.1"
    echo 'esc () {
    printf '"'"'%s'"'"' "$1" | python -c '"'"'import json,sys; print(json.dumps(sys.stdin.read()))'"'"'
}' >> /etc/bash.bashrc
    echo "$newline1" >> /etc/bash.bashrc
fi
newline2="local6.*    /var/log/commands.log"
if is_string_to_write "$newline2" "/etc/rsyslog.d/bash.conf"
then
    echo "added command hook pt.2"
    echo "$newline2" >> /etc/rsyslog.d/bash.conf
fi

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
