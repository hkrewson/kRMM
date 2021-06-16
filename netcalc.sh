#!/bin/zsh

#fClassless() {
#	# Airtable Calc
#	#IF(OR({Class}='Class E',{Class}='Class D'),' ',SWITCH({CIDR},'8','256 B / ','16','256 C / ')&IF({CIDR}='',' ',IF({CIDR}<9,POWER(2,8-{CIDR}) & ' ' &'A',IF({CIDR}<17,POWER(2,16-{CIDR}) & ' ' &'B',IF({CIDR}<25,POWER(2,24-{CIDR}) & ' ' & 'C','1/' & POWER(2,{CIDR}-24) & ' ' & 'C')))))
#}

fSubnet() {
	cider="$1"
	#echo $cider
	rcider=$(expr 32 - $cider)
	#echo $rcider
	binstring=$(printf '1%.0s' {1..$cider};printf '0%.0s' {1..$rcider})
	# In bash, printf doesn't allow passing a variable inside braces. Instead
	#	pass it as a sequence like below.
	#binstring=$(printf '1%.0s' $(seq 0 $cider);printf '0%.0s' $(seq 1 $rcider))
	#echo $binstring
	subnetSTR=()
	i=1
	offset=0
	for i in 1 2 3 4; do
		subnetSTR[$i]=${binstring:$offset:8}
		i=$((i+1))
		offset=$((offset+8))
	done
	#echo $subnetSTR
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

fNetworkBin(){
	# Convert the given IP to a binary representation of the Network ID
	rem=${binstring:$CIDR:$rcider}
	netLength=$(( ${#binstring} - ${#rem}))
	ipbinflat=$(printf "%s" $BINIPINPUT)
	networkIPBin=$(printf '%s%s' ${ipbinflat:0:$netLength}$rem)
	ipbeginbin=$networkIPBin
	broadcastbin=$(printf '%s' ${ipbinflat:0:$netLength};printf '1%.0s' {1..${#rem}})
	ipavailbeginbin=$(printf '%s%s%s' ${ipbinflat:0:$netLength}${rem:0:${#rem}-1}1)
	ipavailendbin=$(printf '%s' ${ipbinflat:0:$netLength};printf '1%.0s' {2..${#rem}};printf '0')
}

# fNetworkIP $binary ipname
fBinToIP(){     
	#convert the given binary numbers back to dot notation
	offset=0
	ipnum=''
	for i in 1 2 3 4; do
		octet=${2:$offset:8}
		i=$((i+1))
		offset=$((offset+8))
		ipnum="${ipnum}$(printf "%d\n" $(bc <<< "ibase=2;$octet"))."
	done
	eval "$1=${ipnum%.}"
}

#fBinToDecMath(){ 
#	# fBinToDecMath varname binarynumber
#	eval "$1=$(printf "%d\n" $(bc <<< "ibase=2;$2"))" 
#}


fCIDR(){
	# Test the input IP address for CIDR notation and split into vars
	if [[ $1 =~ "/" ]]; then
		CIDR=$(echo $1 | awk -F/ '{printf $2}')
		IPINPUT=$(echo $1 | awk -F/ '{printf $1}')
	else
		#IP may be Classful
		IPINPUT=$1
		
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
	BINIPINPUT=()
	fIpToBin $IPINPUT
	i=1
	for octet in ${binIP[@]}; do
		BINIPINPUT[$i]=$octet
		i=$((i+1))
	done
}

fCIDR 0.0.0.0
fSubnet $CIDR
fNetworkBin 
availIPs=$((2 ** $rcider))
hosts=$(($availIPs - 2))
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