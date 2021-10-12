#!/bin/bash

# Grab the GUIDs for the network interfaces by order as listed in System 
#	Preferences: Network
#	en0=UUID-String
#	en1=UUID-String
#	
#	Sets them up as callable variables.
eval $(scutil <<< "show Setup:/Network/Global/IPv4" | awk -F' : ' '/[0-9]/ {gsub(/ /,"");gsub(":","=");print "en"$1""$2}')

# The following is unused at this time. Commented for compatibility between bash and zsh
# enArray=($(typeset +m 'en*'))

# Grab the primary network interface
#   PrimaryInterface=(interface short name: en#)
#   PrimaryService=(service uuid)
#   Router=(router's ip address)
eval $(scutil <<< "show State:/Network/Global/IPv4" | awk -F' : ' '/[0-9]/ {gsub(/ /,"");gsub(":","=");print $1""$2}')

# Grab the network address information for the primary interface
#   inet=(interface's ip address)
#   netmask=(interface's subnet mask in hex)
#   broadcast=(interface's broadcast ip)
#   inet6=(interface's IPv6 address, with trailing %en#)
eval $(ifconfig $PrimaryInterface | awk '{A[$1]=$2;A[$2]=$3;A[$3]=$4;A[$4]=$5;A[$5]=$6} END {print "inet=\"",A["inet"],"\"\nnetmask=\"", A["netmask"],"\"\nbroadcast=\"",A["broadcast"],"\"\ninet6=\"",A["inet6"],"\""}' OFS=)

# Remove the trailing characters from inet6
inet6=$(echo $inet6 | sed 's/%en[0-9]//g')

# Convert the 'netmask' hex to an IP
netmask=$(echo $netmask | sed 's/../&./g;s/.$//' | awk -F. '{X="0x";printf("%d.%d.%d.%d", X$2, X$3, X$4, X$5)}')

# Print them out and make it pretty
printf "%25s %s %s\n" "IPv4:" "$inet"
printf "%25s %s %s\n" "Subnet Mask:" "$netmask"
printf "%25s %s %s\n" "Broadcast:" "$broadcast"
printf "%25s %s %s\n" "IPv6:" "$inet6"
