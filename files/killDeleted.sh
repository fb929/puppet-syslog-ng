#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin

DELETED_FILES=$( lsof -nP /var/log/ | grep '\(deleted\)' | grep -v "$( basename $0 )" | awk '{print $1 "\t" $2 "\t" $9}' | sort -u )

LOG_DIR="/var/log/$(basename $0)"
LOG_FILE="$LOG_DIR/$( date +%Y%m%d-%H%M ).log"

if [[ -z "$DELETED_FILES" ]]; then
    exit 0
else
    install -d $LOG_DIR
    echo "$DELETED_FILES" > $LOG_FILE
    KILL_PIDS=$( echo "$DELETED_FILES" | awk '{print $2}' | sort -u )
    for KILL_PID in $KILL_PIDS; do
        echo "$KILL_PID killing" >> $LOG_FILE
        kill $KILL_PID &>> $LOG_FILE
        echo "$KILL_PID done" >> $LOG_FILE
        service syslog-ng restart
    done
fi
