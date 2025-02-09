#
# plots data from `in_file`, with a title and a summary to the `out_file`
#

# required input params
# `in_file` the input filename
# `out_file` the svg output filename
# `graph_title` the graph title

set datafile missing NaN


# get data from input file executing system command
# extract data from trailing lines
#guardtime_rioec_min = system(sprintf("tail -5 %s | head -1 | awk '{print $2}'", in_file))
#guardtime_rioec_max = system(sprintf("tail -5 %s | head -1 | awk '{print $3}'", in_file))
#guardtime_v200_min = system(sprintf("tail -4 %s | head -1 | awk '{print $2}'", in_file))
#guardtime_v200_max = system(sprintf("tail -4 %s | head -1 | awk '{print $3}'", in_file))
#sync_time_min = system(sprintf("tail -3 %s | head -1 | awk '{print $2}'", in_file))
#sync_time_max = system(sprintf("tail -3 %s | head -1 | awk '{print $3}'", in_file))
#timestamp_master_boot = system(sprintf("tail -1 %s | awk '{print $4}'", in_file))
#show variables all

set title graph_title
set xlabel "Time [us]"
set ylabel "Guardtime [us]"

# set SVG output
set terminal svg font "Arial, 12" linewidth 1
# create the output file
set output sprintf("|cat >./%s", out_file)

plot in_file every :::::0 using 2:5 title "RIOEC guardtime" with dots,\
     in_file every :::::0 using 2:6 title "V200 guardtime" with dots, \
     in_file every :::::0 using 2:7 title "sync time" with dots

