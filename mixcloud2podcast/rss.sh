#!/bin/bash

# Creates an podcast rss file from a folder of m4a and metadata json files 
# downloaded from mixckoud using youtube-dl.
#
# Adapted from on https://github.com/maxhebditch/rss-roller
#
# ------------------------------------------------------------------------

# File path for the audio and json metadata files 
ARCHIVE_DIR=./downloads
# Name of the podcast
TITLE='Just A Blip'
# Link to the podcast's website
LINK=https://listen.dublindigitalradio.com/resident/just-a-blip
# Org, brand or individual
AUTHOR="Glenn O\'Brien"
# Verbose description of the podcast
DESCRIPTION='A fortnightly voyage through oceans of sound. Sometimes calm with clear skies, sometimes the lifeboats have to be deployed. All aboard!'
# The URL to where the rss feed will live: (e.g http://domain.tld/rssfeed.xml)
RSS_LINK=https://justablip.github.io/justablip.xml
# Where the feed file lives on the disk (e.g /home/dog/www/rssfeed.xml) has to match above
RSS_FILE=../justablip.xml
# URL to an image representing the feed
IMAGE=https://justablip.github.io/justablip.png
# Short description of the podcast - 255 character max.
SUBTITLE=$DESCRIPTION


# Don't edit below this line unless you know what you are doing.
# ------------------------------------------------------------------------

RSS_DATE=$(date -R) # now

header () {
echo """<?xml version='1.0' encoding='UTF-8' ?>
<rss version='2.0' xmlns:atom='http://www.w3.org/2005/Atom'>
""" > ./feedtop
echo """<channel>
        <atom:link href='$RSS_LINK' rel='self' type='application/rss+xml' />
        <title>$TITLE</title>
        <link>$LINK</link>
        <managingEditor>$AUTHOR</managingEditor>
        <description>$DESCRIPTION</description>
        <lastBuildDate>$RSS_DATE</lastBuildDate>
        <language>en-us</language>
        <ttl>60</ttl>
        <image>
                <link>$LINK</link>
                <url>$IMAGE</url>
                <title>$TITLE</title>
        </image>
        <itunes:author>$AUTHOR</itunes:author>
        <itunes:subtitle>$SUBTITLE</itunes:subtitle>
        <itunes:summary>$DESCRIPTION</itunes:summary>        

""" >> ./feedtop
echo "Adding the header"
}

footer () {
echo """
</channel>

</rss>
""" >> ./feedbottom
echo "Adding the footer"
}

item () {
        echo """
        <item>
                <title>$item_title</title>
                <link>$item_link</link>
                <guid>$item_guid</guid>
                <enclosure url=\"$item_enclosure\" length=\"$item_enclosure_length\" type=\"$item_enclosure_type\" />
                <description>$item_description</description>
                <pubDate>$item_date</pubDate>
        </item>
        """ >> ./feed
}

combine () {
        header
        footer
        cat ./feedtop ./feed > ./feedtb
        cat ./feedtb ./feedbottom > $RSS_FILE
        rm ./feedtop ./feed ./feedtb ./feedbottom
}

# delete feed xml file
if [[ -f $RSS_FILE ]]; then
        rm $RSS_FILE
fi
# create feed xml file
touch $RSS_FILE

IFS=$'\n' # newline as the delimiter
arr_json=( $(ls -t "$ARCHIVE_DIR"/*.json) ) # an array of all the json files
items_total=$(ls "$ARCHIVE_DIR"/*.json | wc -l | tr -d ' ')
echo "Processing $items_total items..."
item_num=0

for json in "${arr_json[@]}"; do
        m4a=${json%.info.json}.m4a # full path to m4a file (from json file path)

        # add data to json (so we dont need the m4a anymore)
        if [ "$(jq --raw-output '.length' $json)" = null ]; then # if var is empty
                echo 'Adding length to $json'
                length=$(stat -f%z $m4a) # get m4a file size in bytes
                cat $json | jq --arg length $length '. + {length: $length}' > $json.tmp # Add file size to a json.tmp file
                mv $json.tmp $json # overwite original json with new json.tmp file
        fi

        # fix timestamps: make m4a and json file have timestamp when it was published
        file_timestamp=$(date -r $json "+%s") # system date of file as timestamp
        pub_timestamp=$(jq --raw-output '.timestamp' $json) # real timestamp when file was published

        if [ $file_timestamp != $pub_timestamp ]; then
                echo "Fixing file creation time for $json"
                echo "Fixing file creation time for $m4a"
                touch_time_str=$(date -j -f "%s" $pub_timestamp "+%Y%m%d%H%M.%S") # time string in format used by touch command
                # echo "touch -t $touch_time_str [file]"
                touch -t $touch_time_str $json
                touch -t $touch_time_str $m4a
        fi
done

for json in "${arr_json[@]}"; do
        let item_num+=1
        echo "Adding item $item_num/$items_total"

        m4a=${json%.info.json}.m4a # full path to m4a file (from json file path)

        item_id=$(jq --raw-output '.id' $json) # id
        item_title=$(jq --raw-output '.title' $json) # get data from json
        item_date=$(jq --raw-output '.timestamp' $json) # get data from json
        item_date=$(date -j -f "%s" $item_date "+%a, %d %b %Y %H:%M:%S %z") # convert timestamp to date string
        item_link=$(jq --raw-output '.webpage_url' $json) # mixcloud link
        item_guid='https://archive.org/details/'$item_id 
        item_enclosure='https://archive.org/download/'$item_id'/'$item_id'.m4a'
        #item_enclosure_length=$(stat -f%z $m4a) # get file size in bytes
        item_enclosure_length=$(jq --raw-output '.length' $json) # get file size in bytes (we added this data to the json above)
        item_enclosure_type='audio/m4a'
        item_description=$(jq --raw-output '.description' $json) # get data from json
        item_description=${item_description//$'\n'/ <br />} # convert newlines /n to html <br />
        item_description=$(echo $item_description | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g') # convert special characters to HTML entities
        #item_description="![CDATA[ $item_description ]]" # add cdata tag

        item
done
combine
cp $RSS_FILE justablip.rss
echo "RSS file saved."

gitpush () {
        echo "Pushing to git..."
        cd ..
        git add .
        git commit -m "Updated feed"
        git push
}
gitpush
exit

