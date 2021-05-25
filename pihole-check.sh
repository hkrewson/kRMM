#!/bin/bash

# Set internal field separator to newline
IFSOLD=$IFS
IFS=$'\n'

# Check Pi-Hole for software updates
hasupdate=($(pihole -up --check-only | grep 'update available'))

# Set internal field separator to original
IFS=$IFSOLD

if [[ ${hasupdate[0]} =~ "update available" || ${hasupdate[1]} =~ "update available" || ${hasupdate[2]} =~ "update available" ]]; then
	echo "Update available for PiHole"
	exit 1001

else
	#No updates available.
	echo "no updates available for PiHole"
	exit 0
fi