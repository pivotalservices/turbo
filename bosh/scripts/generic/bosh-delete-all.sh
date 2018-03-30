#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

# shellcheck disable=SC1090
source "${TURBO_HOME}/bosh/scripts/generic/helpers.sh"

if [ -f "$BOSH_VAR_STORE" ]; then
	echo "Deleting all deployments, orphaned disks and bosh"
	bosh_login || exit 1

	DEPLOYMENTS=$(bosh -e "$BOSH_ENV" deployments --column name --json | jq .Tables[].Rows[].name)

	for dep in $DEPLOYMENTS; do
		bosh -e "$BOSH_ENV" -d "$dep" delete-deployment -n || exit 1
	done

	bosh -e "$BOSH_ENV" clean-up --all -n || exit 1

	bosh_delete_env || exit 1
else
	echo "bosh is not deployed, nothing do destroy here"
fi
