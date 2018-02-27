#!/usr/bin/env bash
set -x

source /home/${tf_ssh_user}/automation/scripts/bosh/generic/helpers.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/generic/bosh-helper.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/iaas-specific/manage-env.sh

git_clone_or_update "$BOSH_REPO_FOLDER" "$BOSH_REPO"

bosh_create_env || exit 1

vars() {
    cat $BOSH_VAR_STORE
    echo "bosh_environment: ${tf_internal_ip}"
    echo "bosh_target: ${tf_internal_ip}"
    echo "bosh_client: admin"
    echo "bosh_client_secret: '$(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/scim/users/name=admin/password)'"
    echo "credhub_url: $(bosh int $(bosh_int) --path /instance_groups/0/properties/director/config_server/url | rev | cut -c6- | rev)"
    echo "credhub_username: credhub-admin"
    echo "credhub_password: $(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/clients/credhub-admin/secret)"
}


bosh_login || exit 1

###### TO BE MOVED SOMEWHERE ELSE
credhub api https://$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target):8844 --skip-tls-validation || exit 1
credhub login --client-name=credhub-admin --client-secret=$(bosh int "$BOSH_VAR_STORE" --path /credhub_admin_client_secret) || exit 1

credhub get -n /uaa/concourse_credhub_client >/dev/null 2>&1
if ! credhub get -n /uaa/concourse_credhub_client >/dev/null 2>&1; then
    credhub generate -n /uaa/concourse_credhub_client -t user -z concourse || exit 1
fi
