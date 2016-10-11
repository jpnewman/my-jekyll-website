#!/bin/bash

SERVICES=("tomcat7" "apache2")

echo "--------------------------------------------------------------------------------"
echo "[$(date '+%m-%d-%Y %H:%m:%S')] Checking Services..."
echo "--------------------------------------------------------------------------------"

for i in "${SERVICES[@]}"
do
    P=$(ps -ef | grep -v grep | grep $i)
    if [ ! -z "$P" ]; then
        echo "Service running: $i"
        while read -r line; do
            echo -ne "  "
            echo "$line" | tr -s ' ' | cut -d ' ' -f1,2
        done <<< "$P"
    else
        echo "Starting service: $i"
        sudo service $i start || { echo "ERROR: Command 'service $i start' failed!"; exit 1; }
    fi
done
