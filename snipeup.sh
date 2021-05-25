#!/bin/bash

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
	exit 0
else
	echo "Snipe-It requires an update. Snipe-It $currentVer is available."
	echo "Git revision $local installed, git revision $remote is available."
	echo "$latest"
	exit 1001
fi