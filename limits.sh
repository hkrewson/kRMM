#!/bin/bash -i
##### Variables In #####
# Script expects two input Variables
#	$1 = The directory root
#	$2 = The character limit

# Do we have the correct information to run? Print help if not.
if [[ ! $@ ]]; then
	printf "\nUsage: %s Directory Limit\n" $0
	printf " Where Directory is the root directory to check\n"
	printf " and Limit is the character limit in force.\n"
	printf " i.e.\n\n$ %s ~/ 256\n\n" $0
	exit
fi

# Run as root
CURRENT_USER=$(who | grep console | awk '{printf $1}')
if [ "$(id -u)" != "0" ]; then
	exec sudo "$0" "$@"
fi


	
buildArray () {
	#Recursively list the given directory, placing each path into a separate element
	#	of an array
	
	# Make sure we are in the desired directory. 
	cd $1
	
	listing=()
	i=0
	while read line
	do 
		listing[ $i ]="$line" 
		(( i++ ))
 
	done < <(find .)
}

buildArray

for i in "${listing[@]}"
	do
		if [[ $(echo "$i" | wc -m) -gt $2 ]]; then
			echo "$i exceeds character limit of $2"
		fi
	done
done