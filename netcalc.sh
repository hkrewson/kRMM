#!/bin/zsh

#fClassless() {
#	# Airtable Calc
#	#IF(OR({Class}='Class E',{Class}='Class D'),' ',SWITCH({CIDR},'8','256 B / ','16','256 C / ')&IF({CIDR}='',' ',IF({CIDR}<9,POWER(2,8-{CIDR}) & ' ' &'A',IF({CIDR}<17,POWER(2,16-{CIDR}) & ' ' &'B',IF({CIDR}<25,POWER(2,24-{CIDR}) & ' ' & 'C','1/' & POWER(2,{CIDR}-24) & ' ' & 'C')))))
#}

fSubnet() {
	cider="$1"
	echo $cider
	rcider=$(expr 32 - $cider)
	echo $rcider
	binstring=$(printf '1%.0s' {0..$cider};printf '0%.0s' {1..$rcider})
	# In bash, printf doesn't allow passing a variable inside braces. Instead
	#	pass it as a sequence like below.
	#binstring=$(printf '1%.0s' $(seq 0 $cider);printf '0%.0s' $(seq 1 $rcider))
	echo $binstring
	subnetSTR=()
	i=1
	offset=1
	for i in 1 2 3 4; do
		subnetSTR[$i]=${binstring:$offset:8}
		i=$((i+1))
		offset=$((offset+8))
	done
	echo $subnetSTR
}

fIpToBin(){
	# From https://stackoverflow.com/questions/18870209/convert-a-decimal-number-to-hexadecimal-and-binary-in-a-shell-script
	#
	# printf "%08d" sets the length of the number to print
	#
	# Set an empty Array
	binIP=()
	i=1
	for octet in $(echo ${1} | tr "." " "); do
		# Add each binary octet to the Array
		binIP[$i]=$(printf "%08d\n" $(bc <<< "ibase=10; obase=2;$octet"))
		i=$((i+1))
	done
}


fBinMath(){
	# Expects an equation of binary numbers like $binary1 + $binary2
	1+=$(printf "%08d\n" $(bc <<< "ibase=2;obase=2;${2}"))
}

fCIDR(){
	# Test the input IP address for CIDR notation and split into vars
	if [[ $1 =~ "/" ]]; then
		CIDR=$(echo $1 | awk -F/ '{printf $2}')
		IPINPUT=$(echo $1 | awk -F/ '{printf $1}')
	else
		#IP may be Classful
		IPINPUT=$1
	fi
	# 
	BINIPINPUT=()
	fIpToBin $IPINPUT
	i=1
	for octet in ${binIP[@]}; do
		BINIPINPUT[$i]=$octet
		i=$((i+1))
	done
}
