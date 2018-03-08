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

# for disk in $(bosh -e "$BOSH_ENV" disks --orphaned --json | jq -r '.Tables[].Rows[] .disk_cid'); do
# 	bosh -e "$BOSH_ENV" -n delete-disk $disk
# done

bosh -e "$BOSH_ENV" clean-up --all -n || exit 1

bosh_delete_env || exit 1
