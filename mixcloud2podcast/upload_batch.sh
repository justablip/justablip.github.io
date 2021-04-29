#!/bin/bash

# Utility to batch upload multiple files to the internet archive
#

# File path where the audio and json metadata files have been saved
ARCHIVE_DIR=./downloads

IFS=$'\n' # newline as the delimiter
arr_m4a=( $(ls -r "$ARCHIVE_DIR"/*.m4a) )
items_total=$(ls "$ARCHIVE_DIR"/*.m4a | wc -l | tr -d ' ')
echo "Uploading $items_total items..."
item_num=0
for m4a in "${arr_m4a[@]}"; do
        let item_num+=1
        echo "Uploading item $item_num/$items_total"
        # $m4a is the audio file (full path)
#        echo "upload $m4a"
        ./upload.sh $m4a
done
echo "All files uploaded."
exit