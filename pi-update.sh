#!/bin/bash
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
	# We need an exit larger than 1000. Any number to indicate error.
	exit 1001
else
	# Otherwise, we have no updates.
	#	Notate in the log and stdout.
	echo "No updates available." | tee -a $updatesLOG
	exit 0
fi

