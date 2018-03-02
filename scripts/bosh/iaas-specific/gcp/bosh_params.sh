#!/usr/bin/env bash

bosh_create_env() {
	bosh create-env "$BOSH_REPO_FOLDER/bosh.yml" \
		--state="$BOSH_STATE_FOLDER/state.json" \
		--vars-store="$BOSH_VAR_STORE" \
		$BOSH_OPS_FILES \
		--var-file gcp_credentials_json=<(echo "$GCP_CREDENTIALS_JSON") \
		--var director_name="$TF_DIRECTOR_NAME" \
		--var internal_cidr="$TF_INTERNAL_CIDR" \
		--var internal_gw="$TF_INTERNAL_GW" \
		--var internal_ip="$TF_INTERNAL_IP" \
		--var project_id="$TF_PROJECT_ID" \
		--var zone="$TF_ZONE" \
		--var tags="$TF_VM_TAGS" \
		--var network="$TF_NETWORK" \
		--var subnetwork="$TF_SUBNETWORK" || exit 1
}

bosh_delete_env() {
	bosh delete-env "$BOSH_REPO_FOLDER/bosh.yml" \
		--state="$BOSH_STATE_FOLDER/state.json" \
		--vars-store="$BOSH_VAR_STORE" \
		$BOSH_OPS_FILES \
		--var-file gcp_credentials_json=<(echo "$GCP_CREDENTIALS_JSON") \
		--var director_name="$TF_DIRECTOR_NAME" \
		--var internal_cidr="$TF_INTERNAL_CIDR" \
		--var internal_gw="$TF_INTERNAL_GW" \
		--var internal_ip="$TF_INTERNAL_IP" \
		--var project_id="$TF_PROJECT_ID" \
		--var zone="$TF_ZONE" \
		--var tags="$TF_VM_TAGS" \
		--var network="$TF_NETWORK" \
		--var subnetwork="$TF_SUBNETWORK" || exit 1
}

bosh_int() {
	vars_file_arg="--var director_name=\"$TF_DIRECTOR_NAME\" \
		--var internal_cidr=\"$TF_INTERNAL_CIDR\" \
		--var internal_gw=\"$TF_INTERNAL_GW\" \
		--var internal_ip=\"$TF_INTERNAL_IP\" \
		--var project_id=\"$TF_PROJECT_ID\" \
		--var zone=\"$TF_ZONE\" \
		--var tags=\"$TF_VM_TAGS\" \
		--var network=\"$TF_NETWORK\" \
		--var subnetwork=\"$TF_SUBNETWORK\""
	manifest="$BOSH_REPO_FOLDER/bosh.yml"
	echo "$manifest" "$vars_file_arg" $BOSH_OPS_FILES --vars-store="$BOSH_VAR_STORE"
}

bosh_update_cloud_config() {
	bosh -e "$BOSH_ENV" update-cloud-config "$BOSH_CLOUD_CONFIG" \
		--var gcp_zone_1="$TF_GCP_ZONE_1" \
		--var concourse_subnet_range="$TF_CONCOURSE_SUBNET_RANGE" \
		--var concourse_subnet_gateway="$TF_CONCOURSE_SUBNET_GATEWAY" \
		--var bootstrap_network_name="$TF_BOOTSTRAP_NETWORK_NAME" \
		--var concourse_subnet_name="$TF_CONCOURSE_SUBNET_NAME" \
		--var concourse_web_backend_group="$TF_CONCOURSE_WEB_BACKEND_GROUP" \
		--var credhub_backend_group="$TF_CREDHUB_BACKEND_GROUP" \
		--var uaa_backend_group="$TF_UAA_BACKEND_GROUP" \
		--var concourse_network_static_ips="$TF_CONCOURSE_NETWORK_STATIC_IPS" \
		--var concourse_network_reserved_ips="$TF_CONCOURSE_NETWORK_RESERVED_IPS" \
		--var concourse_network_vm_tags="$TF_CONCOURSE_NETWORK_VM_TAGS" \
		--var bosh_subnet_range="$TF_BOSH_SUBNET_RANGE" \
		--var bosh_subnet_gateway="$TF_BOSH_SUBNET_GATEWAY" \
		--var bosh_subnet_name="$TF_BOSH_SUBNET_NAME" \
		--var bosh_network_static_ips="$TF_BOSH_NETWORK_STATIC_IPS" \
		--var bosh_network_reserved_ips="$TF_BOSH_NETWORK_RESERVED_IPS" \
		--var bosh_network_vm_tags="$TF_BOSH_NETWORK_VM_TAGS" \
		-n || exit 1
}
