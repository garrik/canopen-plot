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
  node_guard_id_rioec = 0x707
  prev_ts_node_guard_rioec = 0
  guardtime_rioec = "N/A"
  node_guard_id_v200 = 0x701
  prev_ts_node_guard_v200 = 0
  guardtime_v200 = "N/A"
}

# the title row
NR==1 {
  # strip leading an trailing quote for all columns
  print substr($1,2,length($1)-2) "\t\t" \
        "Timestamp [us]" "\t\t" \
        substr($2,2,length($2)-2) "\t\t\t\t\t" \
        substr($4,2,length($4)-2) "\t\t\t\t\t" \
        "Guardtime RIOEC [us]" "\t\t\t" \
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
    if (prev_ts_node_guard_rioec > 0)
      guardtime_rioec = timestamp - prev_ts_node_guard_rioec
    prev_ts_node_guard_rioec = timestamp
  }
  else {
    guardtime_rioec = "N/A"
  }
  if (strtonum($4) == node_guard_id_v200 && $6 == remote_frame) {
    if (prev_ts_node_guard_v200 > 0)
      guardtime_v200 = timestamp - prev_ts_node_guard_v200
    prev_ts_node_guard_v200 = timestamp
  }
  else {
    guardtime_v200 = "N/A"
  }

  # add timestamp in column 2
  # strip leading an trailing quote for all columns
  print substr($1,2,length($1)-2) "\t\t" \
        timestamp "\t\t\t" \
        substr($2,2,length($2)-2) "\t\t\t" \
        $4 "\t\t\t\t\t\t" \
        guardtime_rioec "\t\t\t" \
        guardtime_v200 "\t\t\t" \
        substr($6,2,length($6)-2) "\t\t\t"
}

END {
  print "\n\n"
  print timestamp_master_boot
}
