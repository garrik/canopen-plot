# Utility to plot data
Sniff CANopen data with cananalyzer2 then export to file,
process it and plot somethig useful.

Requires bash, awk and gnuplot.

Example:
```bash
./plot-cananalyzer2.sh example.csv
```

Remember: zoom only works when plot command is issued from command line.
Gnuplot windows opened from *.plt file do not allow zoom!