#!/bin/bash
updpkgsums
pushd xdna-driver
git fetch
git show main:tools/info.json | jq -r '.firmwares | map_values(.pci_device_id + "_" + .pci_revision_id + ".sbin::" + .url) | join("\n")' | \
	while read -r line; do
		bin=${line%%::*}
		url=${line#*::}
		# echo $bin $url
		old_url=$(grep "$bin::" ../PKGBUILD | awk -F:: '{print $2}')

		if [ "$old_url" == "$url" ]; then
			echo "No update for $bin"
			continue
		else 
			echo "Update $bin"
			sed -i "s|$bin::.*$|$line|g" ../PKGBUILD
			rm ../$bin
		fi
	done
popd
updpkgsums