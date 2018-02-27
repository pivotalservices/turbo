#!/usr/bin/env bash
set -x

source /home/${tf_ssh_user}/automation/scripts/bosh/generic/helpers.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/generic/bosh-helper.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/iaas-specific/manage-env.sh

bosh_login || exit 1

DEPLOYMENTS=$(bosh -e "$BOSH_ENV" deployments --column name --json | jq .Tables[].Rows[].name)

for dep in $DEPLOYMENTS; do
    bosh -e "$BOSH_ENV" -d "$dep" delete-deployment -n || exit 1
done

bosh_delete_env || exit 1