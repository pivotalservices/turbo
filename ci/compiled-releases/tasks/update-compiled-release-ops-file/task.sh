#!/bin/bash

set -e
set -o pipefail

git clone turbo turbo-out

# Get release details
for i in ./*-compiled-releases; do
	pushd $i >/dev/null
	tar -xzf *.tgz $(tar -tzf *.tgz | grep 'release.MF')
	release_name=$(grep -E '^name: ' release.MF | awk '{print $2}' | tr -d "\"'")
	release_version=$(grep -E '^version: ' release.MF | awk '{print $2}' | tr -d "\"'")
	sha1=$(sha1sum *.tgz | cut -d' ' -f1)
	url=$(sed -e 's/gs:\/\//https:\/\/storage.googleapis.com\//g' url)
	popd >/dev/null

	# Create ops-file
	pushd turbo-out >/dev/null
	OPS_FILE_PATH="deployments/ucc/ops/9-compiled-${release_name}-release.yml"
	cat >"${OPS_FILE_PATH}" <<YML
- type: replace
  path: /releases/name=${release_name}?
  value:
    name: ${release_name}
    version: ${release_version}
    url: ${url}
    sha1: ${sha1}
YML
	if [[ -z $(git config --global user.email) ]]; then
		git config --global user.email "ci@wnetworks.org"
	fi
	if [[ -z $(git config --global user.name) ]]; then
		git config --global user.name "CI Bot"
	fi

	if [[ -n $(git status -s) ]]; then
		git add "${OPS_FILE_PATH}"
		git commit -m "Compiled releases updated: ${release_name}/${release_version}"
	fi

	popd >/dev/null

	stemcell_version="$(cat ubuntu-trusty-stemcell/version)"

	pushd turbo-out >/dev/null
	versions_file="deployments/ucc/versions/versions.yml"
	echo "stemcell_version: '${stemcell_version}'" >${versions_file}
	if [[ -z $(git config --global user.email) ]]; then
		git config --global user.email "ci@wnetworks.org"
	fi
	if [[ -z $(git config --global user.name) ]]; then
		git config --global user.name "CI Bot"
	fi

	if [[ -n $(git status -s) ]]; then
		git add "${versions_file}"
		git commit -m "Stemcell updated: ${stemcell_version}"
	fi
	popd >/dev/null
done
