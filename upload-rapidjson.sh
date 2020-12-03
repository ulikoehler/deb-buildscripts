#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 5D4FAE38 rapidjson_*.changes
dput ppa:ulikoehler/rapidjson-update rapidjson_*changes
