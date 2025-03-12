#!/bin/bash
#
# The script plots can traffic data exported to candump to a svg file
#
# debug: x echo command lines, e exits on command error, u unset variables are errors
#set -xeu

self_name=$0
candump_file=$1

if [ -z "$candump_file" ]; then
  echo "Usage: source $self_name <candump filename>"
  exit 1
fi

# change file extension to dat
can_dat="${candump_file/candump/dat}"
# transform candump input into dat for plotting
./proc-candump.awk "$candump_file" > "$can_dat"
echo "File $can_dat created"

# use the file name w/o extension as prefix
prefix_fn="${candump_file/\.candump/}"
# name messages graph file
can_msg_svg="${prefix_fn}-messages.svg"

# prepare the graph title
graph_title="Source file $candump_file"

exit 0
# plot can messages to svg file
gnuplot -e "in_file='$can_dat'" \
        -e "out_file='$can_msg_svg'" \
        -e "graph_title='$graph_title'" \
        -p can_messages.plt
echo ""
echo "File $can_msg_svg created"

# name svg output graph file
can_gt_svg="${prefix_fn}-guardtimes.svg"
# plot guardtimes to svg file
gnuplot -e "in_file='$can_dat'" \
        -e "out_file='$can_gt_svg'" \
        -e "graph_title='$graph_title'" \
        -p can_guardtimes.plt
echo ""
echo "File $can_gt_svg created"
