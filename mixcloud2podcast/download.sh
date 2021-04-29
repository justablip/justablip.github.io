#!/bin/bash

# Downloads all m4a and json metadata for a mixcloud playlist or user
#
# Requirements:
# brew install youtube-dl (to download files from mixcloud)
# brew install atomicparsley (so thumbnail can be embedded into m4a file)
#
# ------------------------------------------------------------------------

# File path where to save the audio and json metadata files 
ARCHIVE_DIR=./downloads
# File used by youtube-dl to keep track of what was already downloaded
ARCHIVE_FILE=./downloaded.txt
# A mixcloud user URL (https://www.mixcloud.com/[username])
# ...or playlist URL (https://www.mixcloud.com/[username]/playlists/[playlist_name])
MIXCLOUD_URL=https://www.mixcloud.com/DublinDigitalRadio/playlists/just-a-blip/

# Don't edit below this line unless you know what you are doing.
# ------------------------------------------------------------------------

# If there are new files on mixcloud it will...
#   1. download each file 
#   2. upload each file to the Internet Archive
#   3. generate rss (runs upload.sh with full path to audio file as param and then rss.sh without any param)

#youtube-dl --simulate \
youtube-dl \
--download-archive $ARCHIVE_FILE \
-o $ARCHIVE_DIR/'%(id)s.%(ext)s' --write-info-json \
--add-metadata --embed-thumbnail \
--exec './upload.sh {} && ./rss.sh' \
$MIXCLOUD_URL

