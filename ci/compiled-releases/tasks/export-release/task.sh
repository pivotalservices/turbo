#!/usr/bin/env bash

set -eu

#
# stemcell metadata/upload
#

curl -L -s "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -o jq && chmod 755 jq && mv jq /usr/local/bin

tar -xzf stemcell/*.tgz $(tar -tzf stemcell/*.tgz | grep 'stemcell.MF')
STEMCELL_OS=$(grep -E '^operating_system: ' stemcell.MF | awk '{print $2}' | tr -d "\"'")
STEMCELL_VERSION=$(grep -E '^version: ' stemcell.MF | awk '{print $2}' | tr -d "\"'")

#
# release metadata/upload
#

pushd release >/dev/null
tar -xzf *.tgz $(tar -tzf *.tgz | grep 'release.MF')
RELEASE_NAME=$(grep -E '^name: ' release.MF | awk '{print $2}' | tr -d "\"'")
RELEASE_VERSION=$(grep -E '^version: ' release.MF | awk '{print $2}' | tr -d "\"'")

popd >/dev/null

releases_in_bucket=$(curl -s "https://www.googleapis.com/storage/v1/b/bosh-compiled-release-tarballs/o/?prefix=${RELEASE_NAME}" | jq -r ".items[] | select(.name | startswith(\"${RELEASE_NAME}-${RELEASE_VERSION}-${STEMCELL_OS}-${STEMCELL_VERSION}-\"))")

if [[ ! -z ${releases_in_bucket} ]]; then
	echo "Nothing to compile, release ${RELEASE_NAME}-${RELEASE_VERSION}-${STEMCELL_OS}-${STEMCELL_VERSION} already in bucket. Reusing it."
	curl -s $(echo ${releases_in_bucket} | jq -r '.mediaLink') \
		-o compiled-release/$(echo ${releases_in_bucket} | jq -r '.name')
else

	start-bosh
	source /tmp/local-bosh/director/env
	bosh -n upload-stemcell stemcell/*.tgz
	pushd release >/dev/null
	bosh -n upload-release *.tgz
	popd >/dev/null
	#
	# compilation deployment
	#

	cat >manifest.yml <<EOF
---
name: compilation
releases:
- name: "$RELEASE_NAME"
  version: "$RELEASE_VERSION"
stemcells:
- alias: default
  os: "$STEMCELL_OS"
  version: "$STEMCELL_VERSION"
update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 1000 - 90000
  update_watch_time: 1000 - 90000
instance_groups: []
EOF

	bosh -n -d compilation deploy manifest.yml
	bosh -d compilation export-release $RELEASE_NAME/$RELEASE_VERSION $STEMCELL_OS/$STEMCELL_VERSION

	mv *.tgz compiled-release/$(echo *.tgz | sed "s/\.tgz$/-$(date -u +%Y%m%d%H%M%S).tgz/")
	sha1sum compiled-release/*.tgz
fi
