#!/bin/zsh
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
###############################################################################
#								ABOUT
#
# This script is intended as a way to calculate and display information about a 
#	network from a CIDR notated address.
#
# See also my Airtable Network Calculator
#	https://airtable.com/universe/expQ6Y0IQZBfWh6at/network-calculator
# 
###############################################################################
#
#
################################## VARIABLES ###################################
# The following variables are in place to test for classless addressing
#
loopBackBin='01111111'
rfcTen='00001010'
rfcOneSevenTwo='1010110000010000'
rfcOneNineTwo='1100000010101000'
###############################################################################

# fSubnet SCIDR
fSubnet() {
	cider="$1"
	rcider=$(expr 32 - $cider)
	binstring=$(printf '1%.0s' {1..$cider};printf '0%.0s' {1..$rcider})
	# In bash, printf doesn't allow passing a variable inside braces. Instead
	#	pass it as a sequence like below.
	#binstring=$(printf '1%.0s' $(seq 0 $cider);printf '0%.0s' $(seq 1 $rcider))
	subnetstr=()
	i=1
	offset=0
	for i in 1 2 3 4; do
		subnetstr[$i]=${binstring:$offset:8}
		i=$((i+1))
		offset=$((offset+8))
	done
	#echo $subnetstr
}

# fIpToBin $IPINPUT
fIpToBin(){
	# From https://stackoverflow.com/questions/18870209/convert-a-decimal-number-to-hexadecimal-and-binary-in-a-shell-script
	#
	# printf "%08d" sets the length of the number to print
	#
	# Set an empty Array
	binaryIp=()
	i=1
	for octet in $(echo ${1} | tr "." " "); do
		# Add each binary octet to the Array
		binaryIp[$i]=$(printf "%08d\n" $(bc <<< "ibase=10; obase=2;$octet"))
		i=$((i+1))
	done
}

fNetworkBin(){
	# Called without additional arguments. Must be called following fSubnet()
	# Convert the given IP to a binary representation of the Network ID
	rem=${binstring:$CIDR:$rcider}
	netLength=$(( ${#binstring} - ${#rem}))
	ipbinflat=$(printf "%s" $binIpInput)
	networkIPBin=$(printf '%s%s' ${ipbinflat:0:$netLength}$rem)
	ipbeginbin=$networkIPBin
	broadcastbin=$(printf '%s' ${ipbinflat:0:$netLength};printf '1%.0s' {1..${#rem}})
	ipavailbeginbin=$(printf '%s%s%s' ${ipbinflat:0:$netLength}${rem:0:${#rem}-1}1)
	ipavailendbin=$(printf '%s' ${ipbinflat:0:$netLength};printf '1%.0s' {2..${#rem}};printf '0')
}

# fNetworkIP $binary ipname
fBinToIP(){     
	#convert the given binary numbers back to dot notation
	# Expects two arguments:
	# 1: A label. This will become a variable name for later.
	# 2: A variable containing a 32 digit binary number
	offset=0
	# ipnum is a temporary variable to hold the ip address. This will be passed
	#	to your label when we're done.
	ipnum=''
	for i in 1 2 3 4; do
		# 4 passes to break the binary into octets
		# octet does this with parameter expansion
		octet=${2:$offset:8}
		i=$((i+1))
		offset=$((offset+8))
		# Here, ipnum is added to, feeding it each octed followed by a '.'
		ipnum="${ipnum}$(printf "%d\n" $(bc <<< "ibase=2;$octet"))."
	done
	# ipnum has a trailing '.' that we need to remove
	eval "$1=${ipnum%.}"
}

fCIDR(){
	# Test the input IP address for CIDR notation and split into vars
	if [[ $1 =~ "/" ]]; then
		# Grab everything after the '/' in our CIDR notation
		CIDR=$(echo $1 | awk -F/ '{printf $2}')
		# Grab everything before the '/' in our CIDR notation
		IPINPUT=$(echo $1 | awk -F/ '{printf $1}')
	else
		# IP may be Classful. If it's classful, we'll assign a psuedo cidr to 
		#	provide the appropriate range for the class.
		IPINPUT=$1
		
		# Case statement to test which class this belongs to. Ultimately, we'll 
		#	expand upon this to catch classless addressing, i.e.
		#	case $IPINPUT in
		#		127.0.0.0/8)
		#			CIDR=8
		#			class='Loopback'
		#		;;
		#		172.16.0.0/12 | 192.168.0.0/16 | 10.0.0.0/8)
		#			CIDR=$(echo $1 | awk -F/ '{printf $2}')
		#			class='RFC1918'
		#		;;
		case $IPINPUT in
			0.0.0.0) 
				CIDR=1
			;;
			128.0.0.0)
				CIDR=2
			;;
			192.0.0.0) 
				CIDR=3
			;;
			224.0.0.0) 
				CIDR=4
			;;
			240.0.0.0) 
				CIDR=4
			;;
		esac
	fi
	# 
	binIpInput=()
	fIpToBin $IPINPUT
	i=1
	for octet in ${binaryIp[@]}; do
		binIpInput[$i]=$octet
		i=$((i+1))
	done
}

# Currently fCIDR() is being called with a static IP. This is for testing. IP 
#	should be replaced with a $1 variable call
fCIDR 192.168.1.1
fSubnet $CIDR
fNetworkBin 

################################## VARIABLES ###################################
# Variables to be set following a call to fSubnet()
availIPs=$((2 ** $rcider))
hosts=$(($availIPs - 2))
#
################################ END VARIABLES #################################

################################### fBinToIP ###################################
# Make the pretty IP's for the report.
fBinToIP broadcast $broadcastbin
fBinToIP networkIP $networkIPBin
fBinToIP ipbeginIP $ipbeginbin
fBinToIP ipavailbeginIP $ipavailbeginbin
fBinToIP ipavailendIP $ipavailendbin
fBinToIP subnetIP $binstring

printf "%25s %s %s\n" "IP Input:" $IPINPUT
printf "%25s %s\n %59s\n" "Network:" "$networkIP" "($networkIPBin)"
printf "%25s %s\n %59s\n" "Subnet Mask:" $subnetIP "($binstring)"
printf "%25s %s\n %59s\n" "Broadcast:" $broadcast "($broadcastbin)"
printf "%25s %s\n %59s\n" "First IP:" $ipbeginIP "($ipbeginbin)"
printf "%25s %s\n %59s\n" "First Available:" $ipavailbeginIP "($ipavailbeginbin)"
printf "%25s %s\n %59s\n" "Last Available:" $ipavailendIP "($ipavailendbin)"
printf "%25s %s\n" "Available IPs:" $availIPs
printf "%25s %s\n" "Hosts:" "$hosts"