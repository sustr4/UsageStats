#!/bin/bash

# This scripts runs the whole sequence of (re)generating IP pool usage data
#
# Arguments:
#   1st: XML files location (directory)
#   2nd: file name suffix


# Produce a list of up/down events from individual XMLs
for file in XMLs/*.xml; do ./Proc1File.rb $file; done > timeline_reduced_augmented.csv


# Sort events by time and ommit zero timestamps (typically machines that are still running)
cat timeline_reduced_augmented.csv | sort | grep -v -E '^0,' > timeline_reduced_augmented_sorted.csv


# Add up current pool usage timestamp by timestamp
./CSVtoArray.rb timeline_reduced_augmented_sorted.csv > usage_reduced_augmented.csv


# Calculate daily maximum for each recognized segment (pool)
./DailyMax.rb usage_reduced_augmented.csv > usage_reduced_augmented_maxes.csv

