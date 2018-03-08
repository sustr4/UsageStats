#!/bin/bash

# This scripts lists ids of machines that are not yet off, and new XMLs need to be downloaded
#
# Arguments:
#   1st: XML files location (directory)

DIR=`realpath "$1"`

for file in ${DIR}/*.xml; do
  if grep --quiet -E '^  <ETIME>0</ETIME>' $file; then
    echo "$file"
  fi
done

