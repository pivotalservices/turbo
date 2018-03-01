#!/usr/bin/env bash
set -x

source ~/automation/scripts/bosh/generic/helpers.sh
source ~/automation/scripts/bosh/generic/bosh-helper.sh

git_clone_or_update "$BOSH_REPO_FOLDER" "$BOSH_REPO"

bosh_create_env || exit 1

vars() {
	cat $BOSH_VAR_STORE
	echo "bosh_environment: $TF_INTERNAL_IP"
	echo "bosh_target: $TF_INTERNAL_IP"
	echo "bosh_client: admin"
	echo "bosh_client_secret: '$(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/scim/users/name=admin/password)'"
	echo "credhub_url: $(bosh int $(bosh_int) --path /instance_groups/0/properties/director/config_server/url | rev | cut -c6- | rev)"
	echo "credhub_username: credhub-admin"
	echo "credhub_password: $(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/clients/credhub-admin/secret)"
}

bosh_login || exit 1
