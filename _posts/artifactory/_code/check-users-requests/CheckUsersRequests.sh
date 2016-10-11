#!/bin/bash

# This script greps the Artifactory logs for users list in argument file (e.g. "search_users.txt") and for each generates a "username" file.
#
# e.g.
#  ./CheckUsersRequests.sh search_users.txt
#
# Cygwin
#  ./CheckUsersRequests.sh search_users.txt /cygdrive/c/Users/john.newman/Desktop/Artifactory_Logs/
#  ./CheckUsersRequests.sh search_users.txt /cygdrive/c/Users/john.newman/Desktop/Artifactory_Logs/ /cygdrive/c/temp/_per-user_logs
#
# As command "zgrep" is used a Linux box or Cygwin is required.
#
# NOTE: The output log files are used by script "CreateExcelDoc.ps1" with JSON files created for debugging.
#

usernames_file="$1"
: ${usernames_file:?"You MUST provide an file with usernames to search"}

log_file_path="$2"
: "/opt/artifactory/logs"

output_path="$3"
: "_per-user_logs"

if [ ! -d "$output_path" ]; then
  mkdir "$output_path"
fi

while read username
do
  echo "$username"
  grep "$username" $log_file_path/access.log > "$output_path/$username.txt"
  zgrep "$username" $log_file_path/access.*.log.zip >> "$output_path/$username.txt"
done < "$usernames_file"
