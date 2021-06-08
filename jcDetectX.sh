#!/bin/bash

#!/bin/bash
API_KEY=''
Group_ID=''
detectx-jamfHOME=''

## Get JumpCloud SystemID
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

if [[ $conf =~ $regex ]]; then
	systemKey="${BASH_REMATCH[@]}"
fi
regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
	systemID="${BASH_REMATCH[@]}"
	echo "JumpCloud systemID found SystemID: "$systemID
else
	echo "No systemID found"
	exit 1
fi

# Run DetectX to look for issues and infections
python $detectx-jamfHOME/run-detectx-search.py

# Gather our results from DetectX
detINF=$(python $detectx-jamfHOME/EA-DetectX-Infections.py)
detISS=$(python $detectx-jamfHOME/EA-DetectX-Issues.py)

# If the results are 'None', make sure the system is NOT in the Group 'DetectX Issues Found'
if [[ "$detISS" == '<result>None</result>' || "$detINF" == '<result>None</result>' ]]; then
	curl -X POST https://console.jumpcloud.com/api/v2/systemgroups/"${Group_ID}"/members \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-H 'x-api-key: '${API_KEY}'' \
	-d '{
		"op": "remove",
		"type": "system",
		"id": "'${systemID}'"
	}'
else 
# Else, add it to the group 'DetectX Issues Found'
	curl -X POST https://console.jumpcloud.com/api/v2/systemgroups/"${Group_ID}"/members \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-H 'x-api-key: '${API_KEY}'' \
	-d '{
		"op": "add",
		"type": "system",
		"id": "'${systemID}'"
	}'
fi
