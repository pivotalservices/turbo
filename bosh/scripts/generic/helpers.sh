#!/usr/bin/env bash

git_clone_or_update() {
	set -e

	local path=$1
	local repo=$2
	local version=$3

	if [ "x$version" = "x" ]; then
		version="master"
	fi
	if [ -d "$path" ]; then
		pushd "$path"
		git checkout master
		git pull
		git checkout "$version"
		popd
	else
		git clone "$repo" "$path"
		pushd "$path"
		git checkout "$version"
		popd
	fi
	set +e
}

env_from_terraform() {
	set -e

	local env="$1"
	local env_json=$(echo "$env" | base64 --decode)
	for var in $(echo "$env_json" | jq -r 'keys[]'); do
		export $var="$(echo "$env_json" | jq -r ".$var")"
	done

	set +e
}

source "${TF_TURBO_HOME}/bosh/scripts/generic/bosh-helper.sh"
