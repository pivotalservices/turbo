#!/usr/bin/env bash

set -e
set -o pipefail

# SPRUCE_VERSION=1.9.0

# curl -L https://github.com/geofffranks/spruce/releases/download/v${SPRUCE_VERSION}/spruce-linux-amd64 >/usr/local/bin/spruce && chmod 0755 /usr/local/bin/spruce

pushd stemcell>/dev/null
tar -xzf stemcell/*.tgz $(tar -tzf stemcell/*.tgz | grep 'stemcell.MF')
stemcell_os=$(grep -E '^operating_system: ' stemcell.MF | awk '{print $2}' | tr -d "\"'")
stemcell_version=$(grep -E '^version: ' stemcell.MF | awk '{print $2}' | tr -d "\"'")
popd >/dev/null

generate_compile_manifest() {
	# 	pushd turbo >/dev/null
	# 	empty_manifest=$(
	# 		cat <<YML
	# releases:
	# - null
	# YML
	# 	)
	# 	ops=$(find deployments/ops/9-compiled-*.yml | sed 's/^/-o /' | xargs)
	# 	already_compiled_releases=$(spruce json <(
	# 		echo "releases:"
	# 		bosh int ${ops} <(echo "$empty_manifest") --path /releases)
	# 	)
	# 	popd >/dev/null
	releases_to_compile="releases:\n"
	for rc_release in ./*-release; do
		pushd $rc_release >/dev/null
		tar -xzf *.tgz $(tar -tzf *.tgz | grep 'release.MF')
		release_name=$(grep -E '^name: ' release.MF | awk '{print $2}' | tr -d "\"'")
		release_version=$(grep -E '^version: ' release.MF | awk '{print $2}' | tr -d "\"'")
		releases_in_bucket=$(curl -s "https://storage.googleapis.com/bosh-compiled-release-tarballs/?prefix=${release_name}")
		if [[ ${releases_in_bucket} != *"${release_version}-${stemcell_os}-${stemcell_version}"-* ]]; then
			releases_to_compile+="- name: ${release_name}\n"
			releases_to_compile+="  version: ${release_version}\n"
		fi
	done

	cat >manifest.yml <<EOF
---
name: compilation
stemcells:
- alias: default
  os: "$stemcell_os"
  version: "$stemcell_version"
update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 1000 - 90000
  update_watch_time: 1000 - 90000
instance_groups: []
EOF

	bosh int <(echo -e ${releases_to_compile}) >>manifest.yml
}

export_releases() {
	for release in $(bosh2 releases --json | jq -r '.Tables[0].Rows[] | (.[0] + "/" + .[1])' | sed 's/\*//g'); do
		name=$(echo ${release} | cut -d'/' -f1)
		bosh export-release -d bucc-compiled-releases ${release} ubuntu-trusty/${1}
		mv ${name}*.tgz $(echo ${name}*.tgz | sed "s/\.tgz$/-$(date -u +%Y%m%d%H%M%S).tgz/")
	done
}

generate_compile_manifest
echo "Genereated compile manifest:"
cat manifest.yml
echo ""

if bosh int manifest.yml --path /releases/0 >/dev/null; then
	start-bosh
	source /tmp/local-bosh/director/env

	version=$(bosh int manifest.yml --path /stemcells/0/version)
	bosh upload-stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=${version}"

	bosh -n deploy -d bucc-compiled-releases manifest.yml
	popd >/dev/null

	pushd compiled-releases >/dev/null
	export_releases ${version}
	popd >/dev/null
else
	echo "Nothing to compile"
fi
