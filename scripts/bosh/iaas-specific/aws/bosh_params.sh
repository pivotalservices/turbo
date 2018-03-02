#!/usr/bin/env bash

bosh_create_env() {
	bosh create-env "$BOSH_REPO_FOLDER/bosh.yml" \
		--state="$BOSH_STATE_FOLDER/state.json" \
		--vars-store="$BOSH_VAR_STORE" \
		$BOSH_OPS_FILES \
		--var access_key_id="$AWS_ACCESS_KEY" \
		--var secret_access_key="$AWS_SECRET_KEY" \
		--var-file private_key=<(echo "$SSH_PRIVATE_KEY") \
		--var director_name="$TF_DIRECTOR_NAME" \
		--var internal_cidr="$TF_INTERNAL_CIDR" \
		--var internal_gw="$TF_INTERNAL_GW" \
		--var internal_ip="$TF_INTERNAL_IP" \
		--var region="$TF_AWS_REGION" \
		--var az="$TF_AZ_1" \
		--var default_key_name="$TF_BOSH_SSH_KEY" \
		--var default_security_groups="$TF_BOSH_VMS_SECURITY_GROUPS" \
		--var subnet_id="$TF_BOSH_SUBNET_ID" || exit 1
}

bosh_delete_env() {
	bosh delete-env "$BOSH_REPO_FOLDER/bosh.yml" \
		--state="$BOSH_STATE_FOLDER/state.json" \
		--vars-store="$BOSH_VAR_STORE" \
		$BOSH_OPS_FILES \
		--var access_key_id="$AWS_ACCESS_KEY" \
		--var secret_access_key="$AWS_SECRET_KEY" \
		--var-file private_key=<(echo "$SSH_PRIVATE_KEY") \
		--var director_name="$TF_DIRECTOR_NAME" \
		--var internal_cidr="$TF_INTERNAL_CIDR" \
		--var internal_gw="$TF_INTERNAL_GW" \
		--var internal_ip="$TF_INTERNAL_IP" \
		--var region="$TF_AWS_REGION" \
		--var az="$TF_AZ_1" \
		--var default_key_name="$TF_BOSH_SSH_KEY" \
		--var default_security_groups="$TF_BOSH_VMS_SECURITY_GROUPS" \
		--var subnet_id="$TF_BOSH_SUBNET_ID" || exit 1
}

bosh_int() {
	vars_file_arg="--var access_key_id=\"$AWS_ACCESS_KEY\" \
		--var secret_access_key=\"$AWS_SECRET_KEY\" \
		--var director_name=\"$TF_DIRECTOR_NAME\" \
		--var internal_cidr=\"$TF_INTERNAL_CIDR\" \
		--var internal_gw=\"$TF_INTERNAL_GW\" \
		--var internal_ip=\"$TF_INTERNAL_IP\" \
		--var region=\"$TF_AWS_REGION\" \
		--var az=\"$TF_AZ_1\" \
		--var default_key_name=\"$TF_BOSH_SSH_KEY\" \
		--var default_security_groups=\"$TF_BOSH_VMS_SECURITY_GROUPS\" \
		--var subnet_id=\"$TF_BOSH_SUBNET_ID\""
	manifest="$BOSH_REPO_FOLDER/bosh.yml"
	echo "$manifest" "$vars_file_arg" $BOSH_OPS_FILES --vars-store="$BOSH_VAR_STORE"
}

bosh_update_cloud_config() {
	bosh -e "$BOSH_ENV" update-cloud-config "$BOSH_CLOUD_CONFIG" \
		--var aws_az1="$TF_AZ_1" \
		--var concourse_subnet_range="$TF_CONCOURSE_SUBNET_RANGE" \
		--var concourse_subnet_gateway="$TF_CONCOURSE_SUBNET_GATEWAY" \
		--var concourse_network_static_ips="$TF_CONCOURSE_NETWORK_STATIC_IPS" \
		--var concourse_network_reserved_ips="$TF_CONCOURSE_NETWORK_RESERVED_IPS" \
		--var concourse_subnet_id="$TF_CONCOURSE_SUBNET_ID" \
		--var concourse_web_backend_group="$TF_CONCOURSE_WEB_BACKEND_GROUP" \
		--var credhub_backend_group="$TF_CREDHUB_BACKEND_GROUP" \
		--var uaa_backend_group="$TF_UAA_BACKEND_GROUP" \
		--var bosh_subnet_range="$TF_BOSH_SUBNET_RANGE" \
		--var bosh_subnet_gateway="$TF_BOSH_SUBNET_GATEWAY" \
		--var bosh_subnet_id="$TF_BOSH_SUBNET_ID" \
		--var bosh_network_static_ips="$TF_BOSH_NETWORK_STATIC_IPS" \
		--var bosh_network_reserved_ips="$TF_BOSH_NETWORK_RESERVED_IPS" \
		-n || exit 1
}
