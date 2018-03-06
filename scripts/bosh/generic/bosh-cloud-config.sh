#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

source ~/automation/scripts/bosh/generic/helpers.sh
source ~/automation/scripts/bosh/generic/bosh-helper.sh

bosh_login || exit 1
bosh_update_cloud_config || exit 1
