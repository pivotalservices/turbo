#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

source ~/automation/scripts/bosh/generic/helpers.sh
source ~/automation/scripts/bosh/generic/bosh-helper.sh

bosh_login || exit 1

DEPLOYMENTS=$(bosh -e "$BOSH_ENV" deployments --column name --json | jq .Tables[].Rows[].name)

for dep in $DEPLOYMENTS; do
	bosh -e "$BOSH_ENV" -d "$dep" delete-deployment -n || exit 1
done

bosh_delete_env || exit 1
