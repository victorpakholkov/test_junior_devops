#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
MONITORING_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"
LAST_PID_FILE="/tmp/last_pid.txt"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

if pgrep -x "$PROCESS_NAME" > /dev/null; then
	CURRENT_PID=$(pgrep -x "$PROCESS_NAME")

	if [ -f "$LAST_PID_FILE" ]; then
		LAST_PID=$(cat "$LAST_PID_FILE")
		if [ "$CURRENT_PID" != "$LAST_PID" ]; then
			log_message "Process $PROCESS_NAME was restarted. Old PID: $LAST_PID, New PID: $CURRENT_PID"
		fi
	fi

	echo "$CURRENT_PID" > "$LAST_PID_FILE"


	if curl -s --head --request GET "$MONITORING_URL" | grep "200 OK" > /dev/null; then
		curl -s "$MONITORING_URL" > /dev/null
	else
		log_message "Monitoring server is not available"
	fi

else
	exit 0

fi
