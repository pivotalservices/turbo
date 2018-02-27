#!/usr/bin/env bash
set -exo pipefail

source /home/${tf_ssh_user}/automation/scripts/bosh/generic/helpers.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/generic/bosh-helper.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/iaas-specific/manage-env.sh
source /home/${tf_ssh_user}/automation/scripts/concourse/generic/concourse-helper.sh

bosh_login || exit 1

DEPLOYMENT_REPO_FOLDER="$DEPLOYMENT_HOME/concourse-deployment"
DEPLOYMENT_REPO=https://github.com/concourse/concourse-deployment
git_clone_or_update "$DEPLOYMENT_REPO_FOLDER" "$DEPLOYMENT_REPO"

bosh -e "$BOSH_ENV" upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent || exit 1
#bosh -e "$BOSH_ENV" upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=3445.2 || exit 1

DEPLOYMENT_OPS_FILES="-o $DEPLOYMENT_REPO_FOLDER/cluster/operations/static-web.yml \
                      -o $DEPLOYMENT_REPO_FOLDER/cluster/operations/basic-auth.yml"

DEPLOYMENT_OPS_FILES_ADD_BASIC=$(find $DEPLOYMENT_HOME/ops/*.yml)
DEPLOYMENT_OPS_FILES_ADD_FLAGS="$(
  for dir in $(echo "$DEPLOYMENT_FLAGS" | jq -r '. as $object | keys[] | select($object[.] == "true")'); do
    find $DEPLOYMENT_HOME/ops/$dir/*.yml;
  done
)"

DEPLOYMENT_OPS_FILES_ADD=$(echo "$DEPLOYMENT_OPS_FILES_ADD_BASIC" "$DEPLOYMENT_OPS_FILES_ADD_FLAGS" | sort | sed 's/^/-o /' | xargs)

bosh -e $BOSH_ENV deploy -d ${tf_env_name}-concourse "$DEPLOYMENT_REPO_FOLDER/cluster/concourse.yml" \
  -l "$DEPLOYMENT_HOME/versions/versions.yml" \
  $DEPLOYMENT_OPS_FILES \
  $DEPLOYMENT_OPS_FILES_ADD \
  --vars-store "$DEPLOYMENT_VAR_STORE" \
  --var web_ip=${cidrhost(tf_concourse_subnet_range,5)} \
  --var external_url=https://${tf_concourse_dns_entry} \
  --var network_name=concourse \
  --var web_vm_type=concourse \
  --var db_vm_type=concourse \
  --var db_persistent_disk_type=db \
  --var worker_vm_type=concourse \
  --var deployment_name=${tf_env_name}-concourse \
  --var domain_name=${tf_domain_name} \
  --var credhub_url=https://credhub.${tf_domain_name} \
  --var-file credhub_ca_cert=<(echo -n "${tf_lb_ca}") \
  --no-redact \
  -n

rc=$?
rm -rf "$DEPLOYMENT_HOME/ops.bak" && mv "$DEPLOYMENT_HOME/ops" "$DEPLOYMENT_HOME/ops.bak" && mkdir "$DEPLOYMENT_HOME/ops"
exit $rc
