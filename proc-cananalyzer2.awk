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
}

# the title row
NR==1 {
  # strip leading an trailing quote for all columns
  print substr($1,2,length($1)-2) "\t\t" \
        "Timestamp [us]" "\t\t" \
        substr($2,2,length($2)-2) "\t\t\t\t\t" \
        substr($4,2,length($4)-2) "\t\t\t\t\t" \
        substr($6,2,length($6)-2) 
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
  # add timestamp in column 2
  # strip leading an trailing quote for all columns
  print substr($1,2,length($1)-2) "\t\t" \
        timestamp "\t\t\t" \
        substr($2,2,length($2)-2) "\t\t\t" \
        $4 "\t\t\t\t\t\t" \
        substr($6,2,length($6)-2)
}

END {
  print "\n\n"
  print timestamp_master_boot
}
