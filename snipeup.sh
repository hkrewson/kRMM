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
#	updates to your Snipe-It install.
#
###############################################################################
#
# Begin grabbing some revision and version info with git.
# @ equals the local git revision whil @{u} equals the current upstream
#	revision

remote=$(git rev-parse @{u})		# Like a uid
local=$(git rev-parse @)			# Like a uid
latest=$(git describe --tags)		# Like v#.#.#-##-shortUID
currentVer=$(git tag | tail -n 1) 	# Like v#.#.#

if [[ $local == $remote ]]; then
	echo "Snipe-It is up to date. Snipe-It $currentVer is installed."
	echo "$latest"
else
	echo "Snipe-It requires an update. Snipe-It $currentVer is available."
	echo "Git revision $local installed, git revision $remote is available."
	echo "$latest"
fi