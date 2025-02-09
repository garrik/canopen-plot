#!/bin/awk -f
# parse the csv export of canalyzer 2

# csv file uses `;` as field separator, so set awk field separator `FS` to `;`
# skill issue: failed to set separator with the command line and the -F option
BEGIN { 
  FS=";"
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
  guardtime_min_rioec = 2^1023
  guardtime_max_rioec = 0
  node_guard_id_v200 = 0x701
  prev_ts_node_guard_v200 = 0
  guardtime_v200 = "na"
  guardtime_min_v200 = 2^1023
  guardtime_max_v200 = 0

  # calculate sync times
  sync_id = 0x80
  prev_ts_sync = 0
  synctime = "na"
  synctime_min = 2^1023
  synctime_max = 0
}

# the title row
NR==1 {
  # strip leading an trailing quote for all columns
  # 1. entry number
  # 2. timestamp
  # 3. date and time
  # 4. message id
  # 5. RIOEC guardtime
  # 6. v200 guardtime
  # 7. sync time
  # 8. message data
  print substr($1,2,length($1)-2) "\t\t" \
        "Timestamp [us]" "\t\t" \
        substr($2,2,length($2)-2) "\t\t\t\t\t" \
        substr($4,2,length($4)-2) "\t\t\t\t\t" \
        "Guardtime RIOEC [us]" "\t\t\t" \
        "Guardtime v200 [us]" "\t\t\t" \
        "sync time [us]" "\t\t\t" \
        substr($6,2,length($6)-2) "\t\t\t"
}

# the data rows
NR>1  {
  # create a timestamp in s then normalize it to start from zero
  if (match($2,/([0-9]{2}):([0-9]{2}):([0-9]{2}).([0-9]{3}).([0-9]{3})/, time_tokens) > 0) {
    timestamp = time_tokens[1] * 60 * 60 * 1000000 \
                + time_tokens[2] * 60 * 1000000 \
                + time_tokens[3] * 1000000 \
                + time_tokens[4] * 1000 \
                + time_tokens[5]
    if (NR == 2)
      timestamp_zero = timestamp
    if ($6 == "\"82 00\"")
      timestamp_master_boot = timestamp - timestamp_zero
    timestamp = timestamp - timestamp_zero
    timestamp_max = timestamp
  }

  # calc the guardtime
  if (strtonum($4) == node_guard_id_rioec && $6 == remote_frame) {
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
  if (strtonum($4) == node_guard_id_v200 && $6 == remote_frame) {
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
  if (strtonum($4) == sync_id) {
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


  # add timestamp in column 2
  # strip leading an trailing quote for all columns
  print substr($1,2,length($1)-2) "\t\t" \
        timestamp "\t\t\t" \
        substr($2,2,length($2)-2) "\t\t\t" \
        $4 "\t\t\t\t\t\t" \
        guardtime_rioec "\t\t\t" \
        guardtime_v200 "\t\t\t" \
        synctime "\t\t\t" \
        substr($6,2,length($6)-2) "\t\t\t"
}

END {
  print "\n\n"
  print "RIOEC " guardtime_min_rioec " " guardtime_max_rioec "\n"
  print "v200  " guardtime_min_v200 " " guardtime_max_v200 "\n"
  print "sync  " synctime_min " " synctime_max "\n"
  # last row is expected to be the master boot time for other script
  print timestamp_master_boot
}
