#!/usr/bin/env python3
import sys
import os
import subprocess
from time import time
import json
import datetime
import requests




def unused():
    output = subprocess.check_output(['last'])
    print(output.decode("utf-8"))
    out_lines = output.decode("utf-8").split('\n')
    for line in out_lines:
        for el in line.split():
            print(el, "\r")
        print("\n\n")

    ip_cmd = "echo $SSH_CONNECTION | awk '{ print $1 }'"
    output = subprocess.check_output(ip_cmd, shell=True)
    print(output)
    exit(1)

    datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%S.%FZ")


if __name__ == "__main__":
    if sys.argv[1] == "command":
        log_info = {
            'time': datetime.datetime.utcnow().isoformat(),
            'user': sys.argv[2],
            'return_value': sys.argv[3],
            'command': sys.argv[4],
        }
        requests.get('http://localhost:9000/command', params=log_info)
    elif sys.argv[1] == "login":
        # echo $(who | head -n[line] | tail -n1) | cut -d " " -f[field of line]
        pass
        # passo ip, tty, utente,
        # aggiornare tabella delle sessioni con il comando last (chi da quando a quando) e durata
    else:
        print("use (command | login)")
