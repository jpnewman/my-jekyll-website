#!/bin/bash

# This script uses logstash to format / normalized files that are generated by script "CheckUsersRequests.sh" and selects the files based on users listed in argument file (e.g. "search_users.txt").
#
# e.g.
#  ./FormatLogs.sh search_users.txt
#
# Bash (Windows)
#  ./FormatLogs.sh search_users.txt /c/temp/_per-user_logs /s/Dev/logstash/logstash-1.3.2-flatjar.jar /c/temp/_output_formatted /c/temp/_temp
#
# NOTE: Cygwin does not work with Java
#

usernames_file="$1"
: ${usernames_file:?"You MUST provide an file with usernames to search"}

input_path="$2"
: "_Output"

logstash_jar_file="$3"
: "/s/Dev/logstash/logstash-1.3.2-flatjar.jar"

output_path="$4"
: "_Output_Formatted"

temp_path="$5"
: "_Temp"

java_path="java"
logstash_config_file="logstash/logstash.conf"

if [ ! -d "$output_path" ]; then
  mkdir "$output_path"
fi

if [ ! -d "$temp_path" ]; then
  mkdir "$temp_path"
fi

echo "date	time	request_type	user	remote	repo	package	version	prerelease	msg	tags" > "header.txt"

while read username
do
  if [ ! -e "$input_path/$username.txt" ]; then
    echo "ERROR: File not found: $input_path/$username.txt"
  else
    echo "$username"

    # Remove log path from file line
    sed "s/^.*\/access.*.log.zip://" "$input_path/$username.txt" > "$temp_path/$username.txt"

    ${java_path} -Xmx512m -jar ${logstash_jar_file} agent -f "$logstash_config_file" < "$temp_path/$username.txt"

    if [ -e "output.json" ]; then
      mv "output.json" "$output_path/$username.json"
    fi

    if [ -e "output.txt" ]; then
      cat "header.txt" "output.txt" > "output.log"
      rm -f "output.txt"
      mv "output.log" "$output_path/$username.log"
    fi
  fi
done < "$usernames_file"

if [ -e "header.txt" ]; then
  rm -f "header.txt"
fi
