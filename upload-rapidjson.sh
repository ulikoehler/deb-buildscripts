#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k AE58DEBD rapidjson_*.changes
dput ppa:ulikoehler/rapidjson-update rapidjson_*changes
