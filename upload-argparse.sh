#!/bin/sh
# Usage: upload.sh <.changes file>
debsign -k 1B69364900A773C4319949E805A0300DAE58DEBD libargparse_*.changes
dput ppa:ulikoehler/deb-buildscripts libargparse_*changes
