#!/usr/bin/env bash
# What you get:
# $DEPLOYMENT_NAME: Contains the deployment name in the form of "<env_name>-<deployment>"
# $DEPLOYMENT_HOME: Is the folder where all your deployment files and folder live
# $DEPLOYMENT_REPO_FOLDER: Folder where your repo is checked-out
#
#
# What you set:
# DEPLOYMENT_OPS_FILES: List of file/flags to add to your bosh deploy command
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

DEPLOYMENT_REPO=https://github.com/pivotal-cf/credhub-release
DEPLOYMENT_REPO_VERSION="1.7.1"

if ! credhub get -n /uaa/concourse_credhub_client >/dev/null 2>&1; then
	credhub generate -n /uaa/concourse_credhub_client -t user -z concourse || clean_exit 1
fi

if ! credhub get -n /credhub/ca >/dev/null 2>&1; then
	credhub generate -n /credhub/ca -t certificate -d 3650 -c "Test" -o "Test" -u "Test" --is-ca --self-sign || clean_exit 1
fi

do_deploy() {
	local DEPLOYMENT_OPS_FILES="-o $DEPLOYMENT_REPO_FOLDER/sample-manifests/ops-enable-bosh-backup-restore.yml"

	bosh -e $BOSH_ENV deploy -d "$DEPLOYMENT_NAME" "$DEPLOYMENT_REPO_FOLDER/sample-manifests/credhub-postgres-uaa.yml" \
		-l "$DEPLOYMENT_HOME/versions/versions.yml" \
		$DEPLOYMENT_OPS_FILES \
		$DEPLOYMENT_OPS_FILES_ADD \
		--var uaa_dns="$TF_UAA_DNS_ENTRY" \
		--var credhub_dns="$TF_CREDHUB_DNS_ENTRY" \
		--var deployment_name="$DEPLOYMENT_NAME" \
		--var-file lb_ca=<(echo -n "$TF_CA_CERT") \
		--var-file lb_public_key=<(echo -n "$TF_LB_PUB_KEY") \
		--no-redact \
		-n

	return $?
}
