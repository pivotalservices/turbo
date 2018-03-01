#!/usr/bin/env bash
# What you get:
# $DEPLOYMENT_NAME: Contains the deployment name in the form of "<env_name>-<deployment>"
# $DEPLOYMENT_HOME: Is the folder where all your deployment files and folder live
# $DEPLOYMENT_REPO_FOLDER: Folder where your repo is checked-out
#
#
# What you set:
# DEPLOYMENT_REPO: Optional. Checks out this repo in $DEPLOYMENT_REPO_FOLDER
# DEPLOYMENT_REPO_VERSION: Optional. Checks out this specific version/tags/commit of the $DEPLOYMENT_REPO
#
# do_deploy Template
# do_deploy() {
#   local DEPLOYMENT_OPS_FILES="-o $DEPLOYMENT_REPO_FOLDER/my-ops-file.yml"
#
# 	bosh -e $BOSH_ENV deploy -d "$DEPLOYMENT_NAME" "$DEPLOYMENT_REPO_FOLDER/cluster/concourse.yml" \
# 		-l "$DEPLOYMENT_HOME/versions/versions.yml" \
# 		$DEPLOYMENT_OPS_FILES \
# 		$DEPLOYMENT_OPS_FILES_ADD \
#       --var xxx="$MY_TF_ENV_VAR" \
#       -n
#   return $?
# }

DEPLOYMENT_REPO=https://github.com/concourse/concourse-deployment

do_deploy() {
	local DEPLOYMENT_OPS_FILES="-o $DEPLOYMENT_REPO_FOLDER/cluster/operations/static-web.yml \
                      -o $DEPLOYMENT_REPO_FOLDER/cluster/operations/basic-auth.yml"

	bosh -e $BOSH_ENV deploy -d "$DEPLOYMENT_NAME" "$DEPLOYMENT_REPO_FOLDER/cluster/concourse.yml" \
		-l "$DEPLOYMENT_HOME/versions/versions.yml" \
		$DEPLOYMENT_OPS_FILES \
		$DEPLOYMENT_OPS_FILES_ADD \
		--var web_ip="$TF_CONCOURSE_WEB_IP" \
		--var external_url="$TF_CONCOURSE_EXTERNAL_URL" \
		--var network_name=concourse \
		--var web_vm_type=concourse \
		--var db_vm_type=concourse \
		--var db_persistent_disk_type=db \
		--var worker_vm_type=concourse \
		--var deployment_name="$DEPLOYMENT_NAME" \
		--var domain_name="$TF_DOMAIN_NAME" \
		--var credhub_url="$TF_CREDHUB_URL" \
		--var-file credhub_ca_cert=<(echo -n "$TF_CA_CERT") \
		--no-redact \
		-n

	return $?
}
