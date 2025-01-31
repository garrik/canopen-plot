#!/bin/bash
#
# The script plots can traffic data exported from cananalyzer2 in csv format to a svg file
#
#set -x

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

# change file extension to svg
ca2_svg="${ca2_csv/csv/svg}"

# prepare the header and the summary for the plot
header="File $ca2_csv"
summary="summary"
timestamp_master_boot=$(tail -1 $ca2_dat)

# plot can messages to svg file
gnuplot -e "in_file='$ca2_dat'" \
        -e "out_file='messages_$ca2_svg'" \
        -e "header='$header'" \
        -e "summary='$summary'" \
        -e "timestamp_master_boot='$timestamp_master_boot'" \
        -p can_messages.plt
