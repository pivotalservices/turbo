#!/usr/bin/env bash

bosh_create_env() {
    bosh create-env "$BOSH_REPO_FOLDER/bosh.yml" \
        --state="$BOSH_STATE_FOLDER/state.json" \
        --vars-store="$BOSH_VAR_STORE" \
        $BOSH_OPS_FILES \
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
}

bosh_delete_env() {
    bosh delete-env "$BOSH_REPO_FOLDER/bosh.yml" \
        --state="$BOSH_STATE_FOLDER/state.json" \
        --vars-store="$BOSH_VAR_STORE" \
        $BOSH_OPS_FILES \
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
}

bosh_int() {
    vars_file_arg="--vars-file $BOSH_VAR_STORE"
    manifest="$BOSH_REPO_FOLDER/bosh.yml"
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
    echo "$manifest" "$vars_file_arg" $BOSH_OPS_FILES "$cli"
}