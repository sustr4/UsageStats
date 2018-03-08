#!/bin/bash

# This scripts updates XMLs of VMs that have not finished yet
#
# Arguments:
#   1st: XML files location (directory)

DIR=`realpath "$1"`

# Remove XMLs for unfinished machines
date
printf "Removing XMLs for unfinished machines "
for file in ${DIR}/*.xml; do
  if grep --quiet -E '^  <ETIME>0</ETIME>' $file; then
    rm -f $file
    printf "."
  fi
done
echo " done"

# Get highest ID
date
printf "Getting current maximum ID ... "
COUNT=`onevm list | tail -n 1 | awk '{ print $1 }'`
echo $COUNT

# Get new files
date
echo Getting new files
for i in $(seq 1 ${COUNT}); do
  if [ ! -f ${DIR}/$i.xml ]; then
    echo "$i"
    onevm show --xml $i > $DIR/$i.xml
  fi
done


