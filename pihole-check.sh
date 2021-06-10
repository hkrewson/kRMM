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
###############################################################################
#								ABOUT
#
# This script is intended as a method for checking and reporting on available
#	updates to your Pi-Hole install.
#
###############################################################################
# Set internal field separator to newline
IFSOLD=$IFS
IFS=$'\n'

# Check Pi-Hole for software updates
hasupdate=($(pihole -up --check-only | grep 'update available'))

# Set internal field separator to original
IFS=$IFSOLD

if [[ ${hasupdate[0]} =~ "update available" || ${hasupdate[1]} =~ "update available" || ${hasupdate[2]} =~ "update available" ]]; then
	echo "Update available for PiHole"
else
	#No updates available.
	echo "no updates available for PiHole"
fi