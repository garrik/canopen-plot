#!/bin/awk -f
# parse the csv export of candump

BEGIN { 
  timestamp = 0
  # timestamp of the 1st message
  timestamp_zero = 0
  # timestamp of the master boot message
  timestamp_master_boot = 0
  # max timestamp
  timestamp_max = 0

  # calculate guardtimes
  remote_frame = "\"Remote Frame (DLC=1)\""
  short_guardtime_threshold = 50 # ignore short guardtimes from the beginning rows
  node_guard_id_rioec = 0x707
  prev_ts_node_guard_rioec = 0
  guardtime_rioec = "na"
  guardtime_min_rioec = 100000000
  guardtime_max_rioec = 0
  node_guard_id_v200 = 0x701
  prev_ts_node_guard_v200 = 0
  guardtime_v200 = "na"
  guardtime_min_v200 = 100000000
  guardtime_max_v200 = 0

  # calculate sync times
  sync_id = 0x080
  prev_ts_sync = 0
  synctime = "na"
  synctime_min = 100000000
  synctime_max = 0
}

# the title row
NR==1 {
  # strip leading an trailing quote for all columns,
  # insert padding to have title and data nicely aligned
  timestamp_title = "Timestamp [s]"
  message_id_title = "\t" "ID (hex)"
  guardtime_rioec_title = "\tGuardtime RIOEC [us]"
  guardtime_v200_title = "\tGuardtime v200 [us]"
  sync_time_title = "\tsync time [us]"
  message_data_title = "\tData"
  print timestamp_title \
        message_id_title \
        guardtime_rioec_title \
        guardtime_v200_title \
        sync_time_title \
        message_data_title
}

# the data rows
NR>0  {
  # create a timestamp in s then normalize it to start from zero
  timestamp = substr($1, 2, length($1) - 2)
  message_id = "0x" substr($3, 1, 3)
  message_data = substr($3, 5)
  suppose_remote_frame = length(message_data) == 2 && (message_data != "7F" && message_data != "FF" && message_data != "05" && message_data != "85")
  if (NR == 1)
    timestamp_zero = timestamp
  if (message_data == "8200")
    timestamp_master_boot = timestamp - timestamp_zero
  timestamp = timestamp - timestamp_zero
  timestamp_max = timestamp

  # calc the guardtime
  if (strtonum(message_id) == node_guard_id_rioec && suppose_remote_frame) {
    if (prev_ts_node_guard_rioec > 0) {
      guardtime_rioec = timestamp - prev_ts_node_guard_rioec
      # workaround: the 1st two guard time are always short,
      # try to ignore them skipping some row at the beginning
      if (NR > short_guardtime_threshold)
        guardtime_min_rioec = guardtime_rioec < guardtime_min_rioec ? guardtime_rioec : guardtime_min_rioec
      guardtime_max_rioec = guardtime_rioec > guardtime_max_rioec ? guardtime_rioec : guardtime_max_rioec
    }
    prev_ts_node_guard_rioec = timestamp
  }
  else {
    guardtime_rioec = "na"
  }
  if (strtonum(message_id) == node_guard_id_v200 && suppose_remote_frame) {
    if (prev_ts_node_guard_v200 > 0) {
      guardtime_v200 = timestamp - prev_ts_node_guard_v200
      # workaround: the 1st two guard time are always short,
      # try to ignore them skipping some row at the beginning
      if (NR > short_guardtime_threshold)
        guardtime_min_v200 = guardtime_v200 < guardtime_min_v200 ? guardtime_v200 : guardtime_min_v200
      guardtime_max_v200 = guardtime_v200 > guardtime_max_v200 ? guardtime_v200 : guardtime_max_v200
    }
    prev_ts_node_guard_v200 = timestamp
  }
  else {
    guardtime_v200 = "na"
  }
  # calc the sync time
  if (strtonum(message_id) == sync_id) {
    if (prev_ts_sync > 0) {
      synctime = timestamp - prev_ts_sync
      synctime_min = synctime < synctime_min ? synctime : synctime_min
      synctime_max = synctime > synctime_max ? synctime : synctime_max
    }
    prev_ts_sync = timestamp
  }
  else {
    synctime = "na"
  }

  # strip leading an trailing quote for all columns
  # insert padding to have title and data nicely aligned
  formatted_timestamp = sprintf("%12s", timestamp)
  formatted_message_id = sprintf("\t%8s", message_id)
  formatted_guardtime_rioec = sprintf("\t%20s", guardtime_rioec)
  formatted_guardtime_v200 = sprintf("\t%19s", guardtime_v200)
  formatted_synctime = sprintf("\t%14s", synctime)
  formatted_message_data = "\t" message_data
  print formatted_timestamp \
        formatted_message_id \
        formatted_guardtime_rioec \
        formatted_guardtime_v200 \
        formatted_synctime \
        formatted_message_data
}

END {
  # insert a double line break to separate following lines from the first data block
  # different data blocks are used in gnuplot processing
  print "\n"
  print "     " sprintf("\t%10s", "min")               "\t" sprintf("\t%10s", "max")  
  print "RIOEC" sprintf("\t%10s", guardtime_min_rioec) "\t" sprintf("\t%10s", guardtime_max_rioec) 
  print "v200 " sprintf("\t%10s", guardtime_min_v200)  "\t" sprintf("\t%10s", guardtime_max_v200)
  print "sync " sprintf("\t%10s", synctime_min)        "\t" sprintf("\t%10s", synctime_max)
  print ""
  print "master boot timestamp " timestamp_master_boot
}
