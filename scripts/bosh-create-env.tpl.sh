#!/usr/bin/env bash
set -x

mkdir -p /home/${tf_ssh_user}/automation/bosh/state && cd /home/${tf_ssh_user}/automation/bosh
FOLDER=/home/${tf_ssh_user}/automation/bosh/bosh-deployment
REPO=https://github.com/cloudfoundry/bosh-deployment
if [ -d "$FOLDER" ]; then
  pushd "$FOLDER"
  git pull || exit 1
  popd
else
  git clone "$REPO" "$FOLDER" || exit 1
fi

VAR_STORE=state/creds.yml
VAR_CACHE=state/var_cache.yml
CA_CERT=state/ca.pem

OPS_FILES="-o bosh-deployment/${tf_cpi}/cpi.yml \
-o bosh-deployment/uaa.yml \
-o bosh-deployment/credhub.yml \
-o bosh-deployment/jumpbox-user.yml"

bosh create-env bosh-deployment/bosh.yml \
    --state=state/state.json \
    --vars-store="$VAR_STORE" \
    $OPS_FILES \
    -v director_name=${tf_env_name}-bosh1 \
    -v internal_cidr=${tf_internal_cidr} \
    -v internal_gw=${tf_internal_gw} \
    -v internal_ip=${tf_internal_ip} \
    --var-file gcp_credentials_json=/home/${tf_ssh_user}/automation/gcp_key.json \
    -v project_id=${tf_project_id} \
    -v zone=${tf_zone} \
    -v tags=[${tf_env_name}-internal,${tf_env_name}-nat] \
    -v network=${tf_network} \
    -v subnetwork=${tf_subnetwork} || exit 1

bosh_int() {
    vars_file_arg="--vars-file $VAR_STORE"
    manifest="bosh-deployment/bosh.yml"
    cli="-v director_name=${tf_env_name}-bosh1 \
    -v internal_cidr=${tf_internal_cidr} \
    -v internal_gw=${tf_internal_gw} \
    -v internal_ip=${tf_internal_ip} \
    --var-file gcp_credentials_json=/home/${tf_ssh_user}/automation/gcp_key.json \
    -v project_id=${tf_project_id} \
    -v zone=${tf_zone} \
    -v tags=[${tf_env_name}-internal,${tf_env_name}-nat] \
    -v network=${tf_network} \
    -v subnetwork=${tf_subnetwork}"
    echo "$manifest" "$vars_file_arg" $OPS_FILES "$cli"
}

vars() {
    cat $VAR_STORE
    echo "bosh_environment: ${tf_internal_ip}"
    echo "bosh_target: ${tf_internal_ip}"
    echo "bosh_client: admin"
    echo "bosh_client_secret: '$(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/scim/users/name=admin/password)'"
    echo "credhub_url: $(bosh int $(bosh_int) --path /instance_groups/0/properties/director/config_server/url | rev | cut -c6- | rev)"
    echo "credhub_username: credhub-admin"
    echo "credhub_password: $(bosh int $(bosh_int) --path /instance_groups/0/jobs/name=uaa/properties/uaa/clients/credhub-admin/secret)"
}


vars > "$VAR_CACHE"

bosh int "$VAR_CACHE" --path /default_ca/ca > "$CA_CERT" || exit 1
bosh alias-env ${tf_env_name}-bootstrap \
                --environment $(bosh int "$VAR_CACHE" --path /bosh_target) \
                --ca-cert "$CA_CERT" || exit 1

printf '%s\n%s\n' $(bosh int "$VAR_CACHE" --path /bosh_client) $(bosh int "$VAR_CACHE" --path /bosh_client_secret) | \
        bosh log-in -e ${tf_env_name}-bootstrap || exit 1