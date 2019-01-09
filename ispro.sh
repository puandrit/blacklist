#!/bin/sh
URI=$(uci get mmpbxrvsipnet.sip_profile_0.uri)
EXTENSION="${URI/+/%2B}"
h=$(curl -s "http://blacklist.satellitar.it/ispro.php?exten=$EXTENSION") 
echo "$h"