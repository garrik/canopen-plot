#
# plots data from `in_file`, with a title and a summary to the `out_file`
#

# required input params
# `in_file` the input filename
# `out_file` the svg output filename
# `header` the graph title
# `summary` the graph summary
# `timestamp_master_boot` the timestamp of master boot

# collect statistics using column 2, see `help stats` in gnuplot prompt
stats in_file u 2:4
timestamp_max = STATS_max_x
message_id_max = STATS_max_y

# thanks to http://stackoverflow.com/questions/22476777/how-to-set-title-below-a-graph-in-gnuplot
set title header offset 0,3
set label summary at -10,3.5e+006
set xlabel "Time [us]"
set ylabel "Message ID (hex)"
# print y values as hex
set format y "%x"
# fit the view to important data
set xrange [timestamp_master_boot-1000000:timestamp_max+1000000]
set yrange [-0x100:message_id_max+0x100]

# set SVG output
set terminal svg font "Arial, 12" linewidth 1
# create the output file
set output sprintf("|cat >./%s", out_file)

plot in_file using 2:4 title "CANopen messages" with dots

