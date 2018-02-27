#!/usr/bin/env bash

bosh_create_env() {
    bosh create-env bosh-deployment/bosh.yml \
        --state="$BOSH_STATE_FOLDER/state.json" \
        --vars-store="$BOSH_VAR_STORE" \
        $BOSH_OPS_FILES \
        -v director_name=${tf_env_name}-bosh1 \
        -v internal_cidr=${tf_internal_cidr} \
        -v internal_gw=${tf_internal_gw} \
        -v internal_ip=${tf_internal_ip} \
        -v access_key_id=$AWS_ACCESS_KEY \
        -v secret_access_key=$AWS_SECRET_KEY \
        -v region=${tf_aws_region} \
        -v az=${tf_az_1} \
        -v default_key_name=${tf_env_name}-bosh \
        -v default_security_groups=[${tf_env_name}-bosh-deployed-vms] \
        --var-file private_key=<(echo "${tf_ssh_private_key}") \
        -v subnet_id=${tf_network_id}
}