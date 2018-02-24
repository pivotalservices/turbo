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


mkdir -p /home/${tf_ssh_user}/automation/credhub/state && cd /home/${tf_ssh_user}/automation/credhub

FOLDER=/home/${tf_ssh_user}/automation/credhub/credhub-release
REPO=https://github.com/pivotal-cf/credhub-release
VERSION="master"

if [ -d "$FOLDER" ]; then
  pushd "$FOLDER"
  git checkout master
  git pull
  git checkout "$VERSION"
  popd
else
  git clone "$REPO" "$FOLDER" || exit 1
  pushd "$FOLDER"
  git checkout "$VERSION"
  popd
fi

bosh -e "$BOSH_ENVIRONMENT" update-cloud-config ../cloud-config.yml -n || exit 1
bosh -e "$BOSH_ENVIRONMENT" upload-stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent || exit 1

OPS_FILES="-o $FOLDER/sample-manifests/ops-enable-bosh-backup-restore.yml"

OPS_FILES_ADD_BASIC=$(find ops/*.yml)
OPS_FILES_ADD_FLAGS="$(
  for dir in $(echo "$FLAGS" | jq -r '. as $object | keys[] | select($object[.] == "true")'); do
    find ops/$dir/*.yml;
  done
)"

OPS_FILES_ADD=$(echo "$OPS_FILES_ADD_BASIC" "$OPS_FILES_ADD_FLAGS" | sort | sed 's/^/-o /' | xargs)

# -o $FOLDER/cluster/operations/basic-auth.yml \

bosh -e $BOSH_ENVIRONMENT upload-release https://bosh.io/d/github.com/pivotal-cf/credhub-release --sha1 6bff25b28dc5e099cb890b78eb727ebe7e52c909
bosh -e $BOSH_ENVIRONMENT upload-release https://bosh.io/d/github.com/cloudfoundry/uaa-release --sha1 393d844138f7b32017d7706684c36bf499e8cc79
bosh -e $BOSH_ENVIRONMENT upload-release https://bosh.io/d/github.com/cloudfoundry/postgres-release --sha1 a436047dae4d4156a1debe9f88bedf59bf40362b

bosh -e $BOSH_ENVIRONMENT deploy -d ${tf_env_name}-credhub "$FOLDER/sample-manifests/credhub-postgres-uaa.yml" \
  $OPS_FILES \
  $OPS_FILES_ADD \
  --vars-store state/credhub-creds.yml \
  --var uaa_dns=${tf_uaa_dns_entry} \
  --var credhub_dns=${tf_credhub_dns_entry} \
  --var deployment_name=${tf_env_name}-credhub \
  --var-file lb_ca=<(echo -n "${tf_lb_ca}") \
  --var-file lb_public_key=<(echo -n "${tf_lb_public_key}") \
  --no-redact \
  -n

rc=$?
rm -rf ops.bak && mv ops ops.bak && mkdir ops
exit $rc