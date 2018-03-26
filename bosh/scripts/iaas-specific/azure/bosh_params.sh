#!/usr/bin/env bash

bosh_create_env() {
	bosh create-env "$BOSH_REPO_FOLDER/bosh.yml" \
		--state="$BOSH_STATE_FOLDER/state.json" \
		--vars-store="$BOSH_VAR_STORE" \
		$BOSH_OPS_FILES \
		-o "$BOSH_REPO_FOLDER/azure/use-managed-disks.yml" \
		-o "$BOSH_REPO_FOLDER/azure/custom-environment.yml" \
		-o "$BOSH_FOLDER/ops/azure/premium_lrs.yml" \
		--var director_name="$TF_DIRECTOR_NAME" \
		--var internal_cidr="$TF_INTERNAL_CIDR" \
		--var internal_gw="$TF_INTERNAL_GW" \
		--var internal_ip="$TF_INTERNAL_IP" \
		--var vnet_name="$TF_VNET_NAME" \
		--var subnet_name="$TF_BOSH_SUBNET_NAME" \
		--var subscription_id="$TF_ARM_SUBSCRIPTION_ID" \
		--var tenant_id="$TF_ARM_TENANT_ID" \
		--var client_id="$TF_ARM_CLIENT_ID" \
		--var client_secret="$TF_ARM_CLIENT_SECRET" \
		--var resource_group_name="$TF_ARM_RESOURCE_GROUP_NAME" \
		--var default_security_group="$TF_DEFAULT_SG" \
		--var environment="$TF_ARM_ENVIRONMENT" || exit 1
}

bosh_delete_env() {
	bosh delete-env "$BOSH_REPO_FOLDER/bosh.yml" \
		--state="$BOSH_STATE_FOLDER/state.json" \
		--vars-store="$BOSH_VAR_STORE" \
		$BOSH_OPS_FILES \
		-o "$BOSH_REPO_FOLDER/azure/use-managed-disks.yml" \
		-o "$BOSH_REPO_FOLDER/azure/custom-environment.yml" \
		-o "$BOSH_FOLDER/ops/azure/premium_lrs.yml" \
		--var director_name="$TF_DIRECTOR_NAME" \
		--var internal_cidr="$TF_INTERNAL_CIDR" \
		--var internal_gw="$TF_INTERNAL_GW" \
		--var internal_ip="$TF_INTERNAL_IP" \
		--var vnet_name="$TF_VNET_NAME" \
		--var subnet_name="$TF_BOSH_SUBNET_NAME" \
		--var subscription_id="$TF_ARM_SUBSCRIPTION_ID" \
		--var tenant_id="$TF_ARM_TENANT_ID" \
		--var client_id="$TF_ARM_CLIENT_ID" \
		--var client_secret="$TF_ARM_CLIENT_SECRET" \
		--var resource_group_name="$TF_ARM_RESOURCE_GROUP_NAME" \
		--var default_security_group="$TF_DEFAULT_SG" \
		--var environment="$TF_ARM_ENVIRONMENT" || exit 1
}

bosh_int() {
	vars_file_arg="--var director_name=\"$TF_DIRECTOR_NAME\" \
		--var internal_cidr=\"$TF_INTERNAL_CIDR\" \
		--var internal_gw=\"$TF_INTERNAL_GW\" \
		--var internal_ip=\"$TF_INTERNAL_IP\" \
		--var vnet_name=\"$TF_VNET_NAME\" \
		--var subnet_name=\"$TF_BOSH_SUBNET_NAME\" \
		--var subscription_id=\"$TF_ARM_SUBSCRIPTION_ID\" \
		--var tenant_id=\"$TF_ARM_TENANT_ID\" \
		--var client_id=\"$TF_ARM_CLIENT_ID\" \
		--var client_secret=\"$TF_ARM_CLIENT_SECRET\" \
		--var resource_group_name=\"$TF_ARM_RESOURCE_GROUP_NAME\" \
		--var default_security_group=\"$TF_DEFAULT_SG\" \
		--var environment=\"$TF_ARM_ENVIRONMENT\""
	manifest="$BOSH_REPO_FOLDER/bosh.yml"
	echo "$manifest" "$vars_file_arg" $BOSH_OPS_FILES \
		-o "$BOSH_REPO_FOLDER/azure/use-managed-disks.yml" \
		-o "$BOSH_REPO_FOLDER/azure/custom-environment.yml" \
		-o "$BOSH_FOLDER/ops/azure/premium_lrs.yml" \
		--vars-store="$BOSH_VAR_STORE"
}

bosh_update_cloud_config() {
	bosh -e "$BOSH_ENV" update-cloud-config "$BOSH_CLOUD_CONFIG" \
		--var az_list="$TF_AZ_LIST" \
		--var vnet_name="$TF_VNET_NAME" \
		--var resource_group_name="$TF_ARM_RESOURCE_GROUP_NAME" \
		--var concourse_subnet_name="$TF_CONCOURSE_SUBNET_NAME" \
		--var concourse_subnet_range="$TF_CONCOURSE_SUBNET_RANGE" \
		--var concourse_subnet_gateway="$TF_CONCOURSE_SUBNET_GATEWAY" \
		--var concourse_network_static_ips="$TF_CONCOURSE_NETWORK_STATIC_IPS" \
		--var concourse_network_reserved_ips="$TF_CONCOURSE_NETWORK_RESERVED_IPS" \
		--var bosh_subnet_name="$TF_BOSH_SUBNET_NAME" \
		--var bosh_subnet_range="$TF_BOSH_SUBNET_RANGE" \
		--var bosh_subnet_gateway="$TF_BOSH_SUBNET_GATEWAY" \
		--var bosh_network_static_ips="$TF_BOSH_NETWORK_STATIC_IPS" \
		--var bosh_network_reserved_ips="$TF_BOSH_NETWORK_RESERVED_IPS" \
		--var concourse_web_lb="$TF_CONCOURSE_WEB_LB" \
		--var concourse_web_sg="$TF_CONCOURSE_WEB_SG" \
		--var credhub_lb="$TF_CREDHUB_LB" \
		--var credhub_sg="$TF_CREDHUB_SG" \
		--var metrics_lb="$TF_METRICS_LB" \
		--var metrics_sg="$TF_METRICS_SG" \
		-n || exit 1
}
