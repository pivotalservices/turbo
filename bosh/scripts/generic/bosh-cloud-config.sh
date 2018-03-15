#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

source $HOME/automation/bosh/scripts/generic/helpers.sh

bosh_login || exit 1
bosh_update_cloud_config || exit 1
