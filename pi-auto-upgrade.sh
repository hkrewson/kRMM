#!/bin/bash

# Set IFS to newline, and hold original IFS
IFSOLD=$IFS
IFS=$'\n'

#Check for software updates
apt update &> /dev/null

#Gather a list of updates if available
upgradable=($(apt list --upgradable))

#Set IFS to original
IFS=$IFSOLD

if [[ ${#upgradable[@]} > 1 ]]; then
	apt upgrade -y &> /dev/null

fi