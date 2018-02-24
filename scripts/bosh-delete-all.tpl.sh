#!/usr/bin/env bash

set -x

BOSH_ENVIRONMENT=${tf_env_name}-bootstrap

DEPLOYMENTS=$(bosh -e $BOSH_ENVIRONMENT deployments --column name --json | jq .Tables[].Rows[].name)

for dep in "$DEPLOYMENTS"; do
    bosh -e $BOSH_ENVIRONMENT -d $dep delete-deployment -n || exit 1
done

pushd /home/${tf_ssh_user}/automation/bosh

VAR_STORE=state/creds.yml
VAR_CACHE=state/var_cache.yml
CA_CERT=state/ca.pem

OPS_FILES="-o bosh-deployment/${tf_cpi}/cpi.yml \
-o bosh-deployment/uaa.yml \
-o bosh-deployment/credhub.yml \
-o bosh-deployment/jumpbox-user.yml"

bosh delete-env bosh-deployment/bosh.yml \
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