#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1BAA8BBC rapidjson_*.changes
dput ppa:ulikoehler/rapidjson-update rapidjson_*changes
