#! /bin/sh

# Production report
production_file_name="Production report.csv"

echo "Indicators, Now, Desired" > $production_file_name

# Add total lines of code from all swift files of the production side
LOC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 wc -l | awk '{print $1}' | tail -n 1)
echo "Total LOC, $LOC, N/A" >> $production_file_name
