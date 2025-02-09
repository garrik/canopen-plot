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
echo "File $ca2_dat created"

# use the file name w/o extension as prefix
prefix_fn="${ca2_csv/\.csv/}"
# name messages graph file
ca2_msg_svg="${prefix_fn}-messages.svg"

# prepare the graph title
graph_title="Source file $ca2_csv"

# plot can messages to svg file
gnuplot -e "in_file='$ca2_dat'" \
        -e "out_file='$ca2_msg_svg'" \
        -e "graph_title='$graph_title'" \
        -p can_messages.plt
echo ""
echo "File $ca2_msg_svg created"

# name svg output graph file
ca2_gt_svg="${prefix_fn}-guardtimes.svg"
# plot guardtimes to svg file
gnuplot -e "in_file='$ca2_dat'" \
        -e "out_file='$ca2_gt_svg'" \
        -e "graph_title='$graph_title'" \
        -p can_guardtimes.plt
echo ""
echo "File $ca2_gt_svg created"
