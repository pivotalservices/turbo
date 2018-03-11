#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

source $HOME/automation/scripts/bosh/generic/helpers.sh
source $HOME/automation/scripts/bosh/generic/bosh-helper.sh

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

cat >~/.bashrc <<EOF
export BOSH_ENVIRONMENT="$TF_ENV_NAME-bootstrap"
export BOSH_FOLDER="/home/$TF_SSH_USER/automation/bosh"
export STEMCELL="$TF_STEMCELL_TYPE"
EOF
cat >>~/.bashrc <<'EOF'
export BOSH_STATE_FOLDER="/data/bosh-state"
export BOSH_VAR_STORE="$BOSH_STATE_FOLDER/creds.yml"
export BOSH_VAR_CACHE="$BOSH_STATE_FOLDER/var_cache.yml"
export BOSH_CA_CERT="$BOSH_STATE_FOLDER/ca.pem"
export BOSH_CLIENT=$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client)
export BOSH_CLIENT_SECRET=$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client_secret)

credhub api https://$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target):8844 --skip-tls-validation >/dev/null 2>&1
credhub login --client-name=credhub-admin --client-secret=$(bosh int "$BOSH_VAR_CACHE" --path /credhub_admin_client_secret) >/dev/null 2>&1
bosh -e "$BOSH_ENV" log-in >/dev/null 2>&1
EOF
