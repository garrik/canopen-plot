#
# plots data from `in_file`, with a title and a summary to the `out_file`
#

# required input params
# `in_file` the input filename
# `out_file` the svg output filename
# `graph_title` the graph title

# get data from input file executing system command
# extract data from last line
timestamp_master_boot = system(sprintf("tail -1 %s | awk '{print $4}'", in_file))
#show variables all

set title graph_title
set xlabel "Time [us]"
set ylabel "Message ID (hex)"
# print y values as hex
set format y "%x"
# add some padding between messages and the border top of the graph
set offsets 0, 0, 5, 0

# set SVG output
set terminal svg font "Arial, 12" linewidth 1
# create the output file
set output sprintf("|cat >./%s", out_file)


# use the every keyword to print only the 1st block of data (data blocks are separated with double line break)
# try to replace 'dots' with 'points pointtype 7 pointsize 1.5'
plot in_file every :::::0 using 2:4 title "CANopen messages" with dots

