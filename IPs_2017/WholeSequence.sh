#!/bin/bash

# This scripts runs the whole sequence of (re)generating IP pool usage data
#
# Arguments:
#   1st: XML files location (directory)
#   2nd: file name suffix

DIR=`realpath "$1"`
SUFFIX="$2"

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


# Produce a list of up/down events from individual XMLs
date
echo Extracting events from XMLs
for file in ${DIR}/*.xml; do ./Proc1File.rb $file; done > timeline${SUFFIX}.csv


# Sort events by time and ommit zero timestamps (typically machines that are still running)
date
echo Sorting
cat timeline${SUFFIX}.csv | sort | grep -v -E '^0,' > timeline${SUFFIX}_sorted.csv


# Add up current pool usage timestamp by timestamp
date
echo Compiling array
./CSVtoArray.rb timeline${SUFFIX}_sorted.csv > usage${SUFFIX}.csv


# Calculate daily maximum for each recognized segment (pool)
date
echo Getting daily maximae
./DailyMax.rb usage${SUFFIX}.csv > usage${SUFFIX}_maxes.csv

echo Files created with suffix \"${SUFFIX}\"

