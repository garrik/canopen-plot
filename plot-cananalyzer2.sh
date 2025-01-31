#!/bin/bash
#
# The script plots can traffic data exported from cananalyzer2 in csv format to a svg file
#
# debug: x echo command lines, e exits on command error, u unset variables are errors
#set -xeu

self_name=$0
# csv file exported from cananalyzer2
ca2_csv=$1

if [ -z "$ca2_csv" ]; then
  echo "Usage: source $self_name <cananalyzer2 filename>"
  exit 1
fi

# change file extension to dat
ca2_dat="${ca2_csv/csv/dat}"
# transform csv input into dat for plotting
./proc-cananalyzer2.awk "$ca2_csv" > "$ca2_dat"

# use the file name w/o extension as prefix
prefix_fn="${ca2_csv/\.csv/}"

# prepare the header and the summary for the plot
header="File $ca2_csv"
summary="summary"
timestamp_master_boot=$(tail -1 $ca2_dat)

# plot can messages to svg file
gnuplot -e "in_file='$ca2_dat'" \
        -e "out_file='${prefix_fn}-messages.svg'" \
        -e "header='$header'" \
        -e "summary='$summary'" \
        -e "timestamp_master_boot='$timestamp_master_boot'" \
        -p can_messages.plt

# plot guardtimes to svg file
gnuplot -e "in_file='$ca2_dat'" \
        -e "out_file='${prefix_fn}-guardtimes.svg'" \
        -e "header='$header'" \
        -e "summary='$summary'" \
        -e "timestamp_master_boot='$timestamp_master_boot'" \
        -p can_guardtimes.plt
