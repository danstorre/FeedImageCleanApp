#! /bin/sh
find -s EssentialFeed/EssentialFeed -iname "*.swift" -print0 -type f | xargs -0 wc -l | awk '{print $1}' | tail -n 1
