#!/usr/bin/env bash
set -exo pipefail

source /home/${tf_ssh_user}/automation/scripts/bosh/generic/helpers.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/generic/bosh-helper.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/iaas-specific/manage-env.sh
source /home/${tf_ssh_user}/automation/scripts/credhub-uaa/generic/credhub-uaa-helper.sh


bosh_login || exit 1

DEPLOYMENT_REPO_FOLDER="$DEPLOYMENT_HOME/credhub-release"
DEPLOYMENT_REPO=https://github.com/pivotal-cf/credhub-release

git_clone_or_update "$DEPLOYMENT_REPO_FOLDER" "$DEPLOYMENT_REPO"

bosh -e "$BOSH_ENV" upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent || exit 1

DEPLOYMENT_OPS_FILES="-o $DEPLOYMENT_REPO_FOLDER/sample-manifests/ops-enable-bosh-backup-restore.yml"

DEPLOYMENT_OPS_FILES_ADD_BASIC=$(find $DEPLOYMENT_HOME/ops/*.yml)
DEPLOYMENT_OPS_FILES_ADD_FLAGS="$(
  for dir in $(echo "$DEPLOYMENT_FLAGS" | jq -r '. as $object | keys[] | select($object[.] == "true")'); do
    find $DEPLOYMENT_HOME/ops/$dir/*.yml;
  done
)"

DEPLOYMENT_OPS_FILES_ADD=$(echo "$DEPLOYMENT_OPS_FILES_ADD_BASIC" "$DEPLOYMENT_OPS_FILES_ADD_FLAGS" | sort | sed 's/^/-o /' | xargs)

bosh -e $BOSH_ENV upload-release https://bosh.io/d/github.com/pivotal-cf/credhub-release --sha1 6bff25b28dc5e099cb890b78eb727ebe7e52c909
bosh -e $BOSH_ENV upload-release https://bosh.io/d/github.com/cloudfoundry/uaa-release --sha1 393d844138f7b32017d7706684c36bf499e8cc79
bosh -e $BOSH_ENV upload-release https://bosh.io/d/github.com/cloudfoundry/postgres-release --sha1 a436047dae4d4156a1debe9f88bedf59bf40362b

bosh -e $BOSH_ENV deploy -d ${tf_env_name}-credhub "$DEPLOYMENT_REPO_FOLDER/sample-manifests/credhub-postgres-uaa.yml" \
  $DEPLOYMENT_OPS_FILES \
  $DEPLOYMENT_OPS_FILES_ADD \
  --vars-store "$DEPLOYMENT_VAR_STORE" \
  --var uaa_dns=${tf_uaa_dns_entry} \
  --var credhub_dns=${tf_credhub_dns_entry} \
  --var deployment_name=${tf_env_name}-credhub \
  --var-file lb_ca=<(echo -n "${tf_lb_ca}") \
  --var-file lb_public_key=<(echo -n "${tf_lb_public_key}") \
  --no-redact \
  -n

rc=$?
rm -rf "$DEPLOYMENT_HOME/ops.bak" && mv "$DEPLOYMENT_HOME/ops" "$DEPLOYMENT_HOME/ops.bak" && mkdir "$DEPLOYMENT_HOME/ops"
exit $rc