#!/usr/bin/env bash
env_from_terraform "$TERRAFORM_ENV"

cat >~/.bashrc <<EOF
BOSH_ENV="$TF_ENV_NAME-bootstrap"
BOSH_FOLDER="/home/$TF_SSH_USER/automation/bosh"
STEMCELL="$TF_STEMCELL_TYPE"
EOF
cat >>~/.bashrc <<'EOF'
BOSH_STATE_FOLDER="$BOSH_FOLDER/state"
BOSH_VAR_STORE="$BOSH_STATE_FOLDER/creds.yml"
BOSH_VAR_CACHE="$BOSH_STATE_FOLDER/var_cache.yml"

credhub api https://$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target):8844 --skip-tls-validation >/dev/null 2>&1
credhub login --client-name=credhub-admin --client-secret=$(bosh int "$BOSH_VAR_CACHE" --path /credhub_admin_client_secret) >/dev/null 2>&1
EOF

BOSH_ENV="$TF_ENV_NAME-bootstrap"
BOSH_FOLDER="/home/$TF_SSH_USER/automation/bosh"

BOSH_STATE_FOLDER="$BOSH_FOLDER/state"

BOSH_VAR_STORE="$BOSH_STATE_FOLDER/creds.yml"
BOSH_VAR_CACHE="$BOSH_STATE_FOLDER/var_cache.yml"
BOSH_CA_CERT="$BOSH_STATE_FOLDER/ca.pem"
BOSH_CLOUD_CONFIG="$BOSH_FOLDER/cloud-config/cloud-config.yml"
BOSH_IAAS_SPECIFIC_FOLDER="/home/$TF_SSH_USER/automation/scripts/bosh/iaas-specific"
BOSH_VARS_FILE="$BOSH_IAAS_SPECIFIC_FOLDER/var-file.yml"
BOSH_IAAS_SPECIFIC_PARAMS="$BOSH_IAAS_SPECIFIC_FOLDER/bosh_params.sh"

BOSH_REPO_FOLDER="$BOSH_FOLDER/bosh-deployment"
BOSH_REPO=https://github.com/cloudfoundry/bosh-deployment

BOSH_OPS_FILES="-o $BOSH_FOLDER/bosh-deployment/$TF_CPI/cpi.yml \
                -o $BOSH_FOLDER/bosh-deployment/uaa.yml \
                -o $BOSH_FOLDER/bosh-deployment/credhub.yml \
                -o $BOSH_FOLDER/bosh-deployment/jumpbox-user.yml"

STEMCELL="$TF_STEMCELL_TYPE"
BOSH_DEPLOYMENTS_FOLDER="/home/$TF_SSH_USER/automation/deployments"

bosh_vars() {
	cat $BOSH_VAR_STORE
	echo "bosh_environment: $TF_INTERNAL_IP"
	echo "bosh_target: $TF_INTERNAL_IP"
	echo "bosh_client: admin"
	echo "bosh_client_secret: '$(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/scim/users/name=admin/password)'"
	echo "credhub_url: $(bosh int $(bosh_int) --path /instance_groups/0/properties/director/config_server/url | rev | cut -c6- | rev)"
	echo "credhub_username: credhub-admin"
	echo "credhub_password: $(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/clients/credhub-admin/secret)"
}

# bosh_create_env() {
# 	bosh create-env "$BOSH_REPO_FOLDER/bosh.yml" \
# 		--state="$BOSH_STATE_FOLDER/state.json" \
# 		--vars-store="$BOSH_VAR_STORE" \
# 		$BOSH_OPS_FILES \
# 		--vars-file "$BOSH_VARS_FILE" || exit 1
# }

# bosh_delete_env() {
# 	bosh delete-env "$BOSH_REPO_FOLDER/bosh.yml" \
# 		--state="$BOSH_STATE_FOLDER/state.json" \
# 		--vars-store="$BOSH_VAR_STORE" \
# 		$BOSH_OPS_FILES \
# 		--vars-file "$BOSH_VARS_FILE" || exit 1
# }

# bosh_int() {
# 	vars_file_arg="--vars-file $BOSH_VAR_STORE"
# 	manifest="$BOSH_REPO_FOLDER/bosh.yml"
# 	echo "$manifest" "$vars_file_arg" $BOSH_OPS_FILES --vars-file "$BOSH_VARS_FILE"
# }

bosh_login() {
	bosh_vars >"$BOSH_VAR_CACHE"

	bosh int "$BOSH_VAR_CACHE" --path /default_ca/ca >"$BOSH_CA_CERT" || exit 1
	export BOSH_CLIENT=$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client)
	export BOSH_CLIENT_SECRET=$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client_secret)

	bosh alias-env "$BOSH_ENV" \
		--environment $(bosh int "$BOSH_VAR_CACHE" --path /bosh_target) \
		--ca-cert "$BOSH_CA_CERT" || exit 1

	bosh log-in -e "$BOSH_ENV" || exit 1
}

bosh_credhub_login() {
	bosh_vars >"$BOSH_VAR_CACHE"
	credhub api https://$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target):8844 --skip-tls-validation || exit 1
	credhub login --client-name=credhub-admin --client-secret=$(bosh int "$BOSH_VAR_STORE" --path /credhub_admin_client_secret) || exit 1
}

source "$BOSH_IAAS_SPECIFIC_PARAMS"
