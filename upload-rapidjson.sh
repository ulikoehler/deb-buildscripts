#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 298D6AE3 rapidjson_*.changes
dput ppa:ulikoehler/rapidjson-update rapidjson_*changes
