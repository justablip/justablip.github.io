# justablip.github.io

Converts "Just A Blip" radio show from Mixcloud to an RSS podcast (with media hosted on the Internet Archive).

[Feedburner](http://feeds.feedburner.com/just-a-blip) · [Mixcloud](https://www.mixcloud.com/DublinDigitalRadio/playlists/just-a-blip) · [DDR](https://listen.dublindigitalradio.com/resident/just-a-blip) · [Internet Archive](https://archive.org/details/@abmc?&and[]=subject%3A%22justablip%22)

## mixcloud2podcast shell scripts:

#### download.sh
Downloads all m4a and json metadata for a mixcloud playlist or user

_Requirements:_  
brew install youtube-dl (to download files from mixcloud)  
brew install atomicparsley (so thumbnail can be embedded into m4a file)

#### upload.sh
Uploads a mixcloud m4a file to the Internet Archive

_Requirements:_  
brew install internetarchive (Internet Archive's command line interface)

#### rss.sh
Creates a podcast rss file from a folder of m4a and metadata json files downloaded from mixcloud using youtube-dl. Also pushes to a git repository.

Heavily adapted from https://github.com/maxhebditch/rss-roller

_Requirements:_  
brew install jq (command-line JSON processor)

#### upload_batch.sh
Utility to batch upload multiple files to the Internet Archive

