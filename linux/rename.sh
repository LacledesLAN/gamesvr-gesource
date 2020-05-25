#!/bin/bash

IFS='
'
set -f

rename_directory () {
  echo "$1"
  for d in $(find "$1" -maxdepth 1 -type d -not -path "$1");
  do
    local upper=`echo "$d" | tr "[:lower:]" "[:upper:]"`
    if [ ! "$d" == "$upper" ]
    then
      mv "$d" "$upper"
    fi
    rename_directory "$upper"
  done
}

rename_files () {
  for f in $(find . -type f);
  do
    local path=`echo "${f%.*}" | tr "[:lower:]" "[:upper:]"`
    local extension="${f##*.}"
    if [ ! "$f" == "$path.$extension" ]
    then
      mv "$f" "$path.$extension"
    fi
  done
}

cd /output/gesource/materials
rename_directory "./"
rename_files

cd /output/srcds2007/hl2/materials
rename_directory "./"
rename_files