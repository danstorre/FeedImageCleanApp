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

# Add ! comment count
UNWRAPC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 grep "\.*\w!\.*" | wc -l)
echo "'Optional' force unwrap (!) count, $UNWRAPC, 0" >> $production_file_name

# Add unwoned comment count
UNOWNEDC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 grep "\[unowned" | wc -l)
echo "unowned reference count, $UNOWNEDC, 0" >> $production_file_name

# Add number of tabs per line
TABSC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 grep "\t" | awk -F '.swift:' '{print $NF}' | awk -F'\t' '{ print NF-2 }' | sort -n | tail -n 1)
echo "Max indentation level, $TABSC, <=5" >> $production_file_name

# Add assignable var declaration count
VARC=$(find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 grep "var.*=" | wc -l)
echo "Assignable var declaration count, $VARC, 0" >> $production_file_name
