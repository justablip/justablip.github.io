#!/bin/bash

# Uploads a mixcloud m4a file to the Internet Archive
#
# Requirements:
# brew install internetarchive (Internet Archive's command line interface)
# ------------------------------------------------------------------------

# Internet archive screen/account name
AUTHOR='abmc'
# The person or organization that provided the physical or digital media
CONTRIBUTOR='António Costa'
# The individual(s) or organization that created the media content.
CREATOR="Glenn O'Brien"
# Source of media. Where a piece of media originated or what the physical media was prior to digitization
SOURCE='Dublin Digital Radio'
# Subjects and/or topics covered by the media content. Tags semicolon and space separated.
SUBJECT='dublindigitalradio; justablip; radio; podcast; ireland; dublin; music; alternative'
# The language the media is written or recorded in as 3 letter MARC language code
LANGUAGE='eng'
# What collection this item belongs to. Must be a valid collection identifier
#COLLECTION='opensource_audio'
COLLECTION='just-a-blip'
# The type of media. Accepted values: texts etree audio movies software image data web collection account
MEDIATYPE='audio'

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
TITLE=$(jq --raw-output '.title' $json) # get data from json
DESCRIPTION=$(jq --raw-output '.description' $json) # get data from json
DESCRIPTION=${DESCRIPTION//$'\n'/ <br />} # convert newlines /n to html <br />
DESCRIPTION=$(echo $DESCRIPTION | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g') # convert special characters to HTML entities
ARTIST=$(jq --raw-output '.artist' $json) # get data from json
DATE=$(jq --raw-output '.timestamp' $json) # get data from json
if [ "$(uname)" == "Darwin" ]; then # Mac OS X platform 
	DATE=$(date -j -f "%s" $DATE "+%F") # convert timestamp to date string
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then # GNU/Linux platform
	DATE=$(date -d @$DATE "+%F") # convert timestamp to date string
fi	
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


