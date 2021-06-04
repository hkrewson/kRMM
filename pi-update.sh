#!/bin/bash
# 
# Copyright 2021 Hamlin Krewson
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# 	limitations under the License.
#
# We need a log file to keep track of installable software. 
#	/var/log/apt/history.log keeps track of all installs and upgrades.
#	We'll keep track of our list in a new /var/log/apt-updates.log file
updatesLOG="/var/log/apt-updates.log"

if [[ ! -e $updatesLOG ]]; then
	touch $updatesLOG
fi

# Set up our log file section with the current date and time.
printf '%s' $(date) >> $updatesLOG
printf '\n' >> $updatesLOG


# Set IFS to newline, and hold original IFS
IFSOLD=$IFS
IFS=$'\n' 

#Check for software updates
apt update &> /dev/null

#Gather a list of updates if available
upgradable=($(apt list --upgradable))

updatesLOG="/var/log/apt-updates.log"

if [[ ! -e $updatesLOG ]]; then
	touch $updatesLOG
fi

printf '%s '  $(date '+%a %d %b, %Y %T') >> $updatesLOG
printf '\n' >> $updatesLOG

#Set IFS to original
IFS=$IFSOLD

if [[ ${#upgradable[@]} > 1 ]]; then
	# If we have updates available, list them out.
	#	Output to stdout and our log file.
	printf '%s\n' "Listing upgradable items:" | tee -a $updatesLOG
	printf '%s\n' "${upgradable[@]:1}" | tee -a $updatesLOG
	# We need a marker for the end of this listing. 
	#	5 dashes should be searchable.
	printf "\n-----\n\n" >> $updatesLOG
else
	# Otherwise, we have no updates.
	#	Notate in the log and stdout.
	echo "No updates available." | tee -a $updatesLOG
fi

