#!/bin/sh
debsign -k 1B69364900A773C4319949E805A0300DAE58DEBD librtipc_*.changes
dput ppa:ulikoehler/ethercat-utils librtipc_*changes
