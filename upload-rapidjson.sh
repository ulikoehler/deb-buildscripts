#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1BAA8BBC rapidjson_1.1.0-deb1-1_amd64.changes
dput ppa:ulikoehler/rapidjson-update rapidjson_1.1.0-deb1-1_amd64.changes
