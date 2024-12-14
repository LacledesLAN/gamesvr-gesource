#!/bin/bash

# This shell script ensures assets have been sanitized for the Linux environment.
# For details see PR #3 (https://github.com/LacledesLAN/gamesvr-gesource/pull/3).

dos2unix /output/gesource/*.txt

######

IFS=$'\n'

set -f

uppercase_directories () {
  find "$1" -maxdepth 1 -type d -not -path "$1" | while IFS= read -r d;
  do
    local upper=$(echo "$d" | tr "[:lower:]" "[:upper:]")
    if [ ! "$d" == "$upper" ]
    then
      mv "$d" "$upper"
    fi
    uppercase_directories "$upper"
  done
}

uppercase_files () {
  find . -type f | while IFS= read -r f;
  do
    local path=$(echo "${f%.*}" | tr "[:lower:]" "[:upper:]")
    local extension="${f##*.}"
    if [ ! "$f" == "$path.$extension" ]
    then
      mv "$f" "$path.$extension"
    fi
  done
}

cd /output/gesource/materials || exit 1
uppercase_directories "./"
uppercase_files

cd /output/srcds2007/hl2/materials || exit 1
uppercase_directories "./"
uppercase_files
