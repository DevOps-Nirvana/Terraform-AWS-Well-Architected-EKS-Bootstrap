#!/bin/bash -e
#
# This very simple helper script deletes all items and versions of items in an s3 bucket
#
# NOTE: At large scale this script will take far, far too long.  You'll need to write a 
#       threading/backgrounding version of this script to do that.  Typically easier with
#       a real programming langauge (eg: Py)
#

if [ $# -ne 1 ]
then
  echo "Usage: $0 <bucket_name>"
  exit
fi

BUCKET_NAME="$1"

function main {
	local IFS=
	local versionKeyRegexp=$'^([^\t]+)\t(.+)'
	while read -r item; do
		if [[ $item =~ $versionKeyRegexp ]]; then
			local versionId=${BASH_REMATCH[1]}
			local key=${BASH_REMATCH[2]}

			aws s3api delete-object \
				--bucket "$BUCKET_NAME" \
				--key "$key" \
				--version-id "$versionId"

			echo "Deleted: [$key] | [$versionId]"
		fi
	done < <(aws s3api list-object-versions \
		--bucket "$BUCKET_NAME" \
		--output text \
		--query "[DeleteMarkers,Versions][].{a:VersionId,b:Key}")
}

main
