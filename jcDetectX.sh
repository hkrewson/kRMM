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
#
###############################################################################
#								ABOUT
#
# This script relies on a fork of https://github.com/haircut/detectx-jamf. 
#	detectx-jamf runs the cli from DetectX Swift to check for and record
#	infections or issues. The goal of this project is to report via EA to
#	JamfPro.
#
# The fork, located at https://github.com/hkrewson/detectx-jamf, is modified
#	to not rely on or report to JamfPro. Instead we run via JumpCloud and 
#	use results to add/remove the affected computer to/from a specified group
#	for reporting.
#
###############################################################################

API_KEY=''
Group_ID=''
detectx-jamfHOME=''

jcGroupMembership() {
	curl -X POST https://console.jumpcloud.com/api/v2/systemgroups/"${Group_ID}"/members \
	-H 'Accept: application/json' \
	-H 'Content-Type: application/json' \
	-H 'x-api-key: '${API_KEY}'' \
	-d '{
		"op": "'"$1"'",
		"type": "system",
		"id": "'"${systemID}"'"
	}'
}

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
	jcGroupMembership "remove"
else 
# Else, add it to the group 'DetectX Issues Found'
	jcGroupMembership "add"
fi
