#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

# shellcheck disable=SC1090
source "${TURBO_HOME}/bosh/scripts/generic/helpers.sh"

bosh_login || exit 1
bosh_update_cloud_config || exit 1
