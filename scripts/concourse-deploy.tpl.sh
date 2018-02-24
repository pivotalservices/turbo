#!/usr/bin/env bash
set -exo pipefail

BOSH_ENVIRONMENT=${tf_env_name}-bootstrap
FLAGS=${tf_flags}

echo "$FLAGS"

cd /home/${tf_ssh_user}/automation/bosh
VAR_STORE=state/creds.yml
VAR_CACHE=state/var_cache.yml
CA_CERT=state/ca.pem

# bosh int "$VAR_CACHE" --path /default_ca/ca > "$CA_CERT" || exit 1
# bosh alias-env ${tf_env_name}-bootstrap \
#                 --environment $(bosh int "$VAR_CACHE" --path /bosh_target) \
#                 --ca-cert "$CA_CERT" || exit 1

printf '%s\n%s\n' $(bosh int "$VAR_CACHE" --path /bosh_client) $(bosh int "$VAR_CACHE" --path /bosh_client_secret) | \
        bosh log-in -e ${tf_env_name}-bootstrap || exit 1


mkdir -p /home/${tf_ssh_user}/automation/concourse/state && cd /home/${tf_ssh_user}/automation/concourse

FOLDER=/home/${tf_ssh_user}/automation/concourse/concourse-deployment
REPO=https://github.com/concourse/concourse-deployment
if [ -d "$FOLDER" ]; then
  pushd "$FOLDER"
  git pull || exit 1
  popd
else
  git clone "$REPO" "$FOLDER" || exit 1
fi

bosh -e "$BOSH_ENVIRONMENT" update-cloud-config ../cloud-config.yml -n || exit 1
bosh -e "$BOSH_ENVIRONMENT" upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent || exit 1

OPS_FILES="-o $FOLDER/cluster/operations/static-web.yml \
-o $FOLDER/cluster/operations/basic-auth.yml"
#-o $FOLDER/cluster/operations/no-auth.yml"

OPS_FILES_ADD_BASIC=$(find ops/*.yml)
OPS_FILES_ADD_FLAGS="$(
  for dir in $(echo "$FLAGS" | jq -r '. as $object | keys[] | select($object[.] == "true")'); do
    find ops/$dir/*.yml;
  done
)"

OPS_FILES_ADD=$(echo "$OPS_FILES_ADD_BASIC" "$OPS_FILES_ADD_FLAGS" | sort | sed 's/^/-o /' | xargs)

# -o $FOLDER/cluster/operations/basic-auth.yml \

bosh -e $BOSH_ENVIRONMENT deploy -d ${tf_env_name}-concourse "$FOLDER/cluster/concourse.yml" \
  -l "$FOLDER/versions.yml" \
  $OPS_FILES \
  $OPS_FILES_ADD \
  --vars-store state/concourse-creds.yml \
  --var web_ip=${cidrhost(tf_concourse_subnet_range,5)} \
  --var external_url=https://${tf_concourse_dns_entry} \
  --var network_name=concourse \
  --var web_vm_type=concourse \
  --var db_vm_type=concourse \
  --var db_persistent_disk_type=db \
  --var worker_vm_type=concourse \
  --var deployment_name=${tf_env_name}-concourse \
  --var domain_name=${tf_domain_name} \
  -n

rc=$?
rm -rf ops.bak && mv ops ops.bak && mkdir ops
exit $rc
