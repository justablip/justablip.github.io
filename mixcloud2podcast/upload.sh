#!/bin/bash

#
# Uploads a mixcloud m4a file to the Internet Archive
#
# ------------------------------------------------------------------------

AUTHOR='abmc'
CONTRIBUTOR='António Costa'
CREATOR="Glenn O'Brien"
SOURCE='Dublin Digital Radio'
SUBJECT='dublindigitalradio; justablip; radio; podcast; ireland; dublin; music; alternative'
LANGUAGE='eng'

# Don't edit below this line unless you know what you are doing.
# ------------------------------------------------------------------------

if [ $# -eq 0 ]; then
	echo "Uploads a mixcloud m4a file to the Internet Archive"
	echo "usage: ./upload.sh [./full/path/file.m4a]"
	exit 1
fi

m4a=$1
json=${m4a%.m4a}.info.json # the metadata json file (full path)
IDENTIFIER=$(jq --raw-output '.id' $json) # get data from json
MEDIATYPE='audio'
TITLE=$(jq --raw-output '.title' $json) # get data from json
COLLECTION='opensource_audio'
DESCRIPTION=$(jq --raw-output '.description' $json) # get data from json
DESCRIPTION=${DESCRIPTION//$'\n'/ <br />} # convert newlines /n to html <br />
DESCRIPTION=$(echo $DESCRIPTION | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g') # convert special characters to HTML entities
ARTIST=$(jq --raw-output '.artist' $json) # get data from json
DATE=$(jq --raw-output '.timestamp' $json) # get data from json
DATE=$(date -j -f "%s" $DATE "+%F") # convert timestamp to date string
LICENSEURL='http://creativecommons.org/licenses/by-nc-sa/4.0/'


if [ -z "$DESCRIPTION" ]
then # empty
      DESCRIPTION=$DESCRIPTION' '
fi

if [ -z "$ARTIST" ]
then # empty
      ARTIST=$ARTIST' '
fi

#ia --debug upload $IDENTIFIER "$m4a" "$json" --retries 100 \
ia upload $IDENTIFIER "$m4a" "$json" --retries 100 \
--metadata="mediatype:$MEDIATYPE" \
--metadata="title:$TITLE" \
--metadata="collection:$COLLECTION" \
--metadata="description:$DESCRIPTION " \
--metadata="artist:$ARTIST" \
--metadata="author:$AUTHOR" \
--metadata="contributor:$CONTRIBUTOR" \
--metadata="creator:$CREATOR" \
--metadata="source:$SOURCE" \
--metadata="subject:$SUBJECT" \
--metadata="date:$DATE" \
--metadata="language:$LANGUAGE" \
--metadata="licenseurl:$LICENSEURL"


