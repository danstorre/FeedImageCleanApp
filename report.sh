#! /bin/sh

# Production report
production_file_name="Production report.csv"

echo "Indicators, Now, Desired" > $production_file_name

# Add total lines of code from all swift files of the production side
LOC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 wc -l | awk '{print $1}' | tail -n 1)
echo "Total LOC, $LOC, N/A" >> $production_file_name

# Add Swift file count
SFC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -type f | wc -l)
echo "Swift file count, $SFC, N/A" >> $production_file_name

# Add Avarage LOC per file
echo "Swift file count, $(($LOC/$SFC)), <100" >> $production_file_name

# Add TODO comment count
TODOC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 grep TODO | wc -l)
echo "TODO comment count, $TODOC, 0" >> $production_file_name

# Add FIX comment count
FIXC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 grep FIX | wc -l)
echo "FIX comment count, $FIXC, 0" >> $production_file_name
