#!/usr/bin/env bash
BOSH_ENV="${tf_env_name}-bootstrap"
BOSH_FOLDER="/home/${tf_ssh_user}/automation/bosh"

BOSH_STATE_FOLDER="$BOSH_FOLDER/state"

BOSH_VAR_STORE="$BOSH_STATE_FOLDER/state/creds.yml"
BOSH_VAR_CACHE="$BOSH_STATE_FOLDER/state/var_cache.yml"
BOSH_CA_CERT="$BOSH_STATE_FOLDER/state/ca.pem"
BOSH_CLOUD_CONFIG="$BOSH_FOLDER/cloud-config/cloud-config.yml"

BOSH_REPO_FOLDER="$BOSH_FOLDER/bosh-deployment"
BOSH_REPO=https://github.com/cloudfoundry/bosh-deployment

BOSH_OPS_FILES="-o $BOSH_FOLDER/bosh-deployment/${tf_cpi}/cpi.yml \
                -o $BOSH_FOLDER/bosh-deployment/uaa.yml \
                -o $BOSH_FOLDER/bosh-deployment/credhub.yml \
                -o $BOSH_FOLDER/bosh-deployment/jumpbox-user.yml"

bosh_vars() {
    cat $BOSH_VAR_STORE
    echo "bosh_environment: ${tf_internal_ip}"
    echo "bosh_target: ${tf_internal_ip}"
    echo "bosh_client: admin"
    echo "bosh_client_secret: '$(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/scim/users/name=admin/password)'"
    echo "credhub_url: $(bosh int $(bosh_int) --path /instance_groups/0/properties/director/config_server/url | rev | cut -c6- | rev)"
    echo "credhub_username: credhub-admin"
    echo "credhub_password: $(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/clients/credhub-admin/secret)"
}

bosh_login() {
    bosh_vars > "$BOSH_VAR_CACHE"

    bosh int "$BOSH_VAR_CACHE" --path /default_ca/ca > "$BOSH_CA_CERT" || exit 1
    bosh alias-env "$BOSH_ENV" \
                    --environment $(bosh int "$BOSH_VAR_CACHE" --path /bosh_target) \
                    --ca-cert "$BOSH_CA_CERT" || exit 1

    printf '%s\n%s\n' $(bosh int "$BOSH_VAR_CACHE" --path /bosh_client) $(bosh int "$BOSH_VAR_CACHE" --path /bosh_client_secret) | \
            bosh log-in -e "$BOSH_ENV" || exit 1
}

bosh_update_cloud_config() {
    bosh -e "$BOSH_ENV" update-cloud-config "$BOSH_CLOUD_CONFIG" -n || exit 1
}