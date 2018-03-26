#!/usr/bin/env bash

set -uo pipefail

ucc_credhub_login() {
	credhub api "$TF_CREDHUB_URL" --skip-tls-validation || return 1
	credhub login --client-name=credhub-admin --client-secret="$TF_CREDHUB_ADMIN_PASSWORD" || return 1
}

unset CREDHUB_SECRET
unset CREDHUB_CLIENT
unset CREDHUB_SERVER

echo "Waiting max 120sec for load balancers health checks to be valid..."
i=0
while ! curl -k -f "$TF_CREDHUB_URL" >/dev/null 2>&1; do
	sleep 1
	i=$((i + 1))
	if [ $i -ge 120 ]; then
		clean_exit 1
	fi
done

ucc_credhub_login || clean_exit 1

credhub set -n /concourse/main/bosh_ca_cert -t certificate -c "$BOSH_CA_CERT" >/dev/null || clean_exit 1
credhub set -n /concourse/main/bosh_host -t value -v "$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target)" >/dev/null || clean_exit 1
credhub set -n /concourse/main/bosh_admin -t user -z "$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client)" -w "$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client_secret)" >/dev/null || clean_exit 1
credhub set -n /concourse/main/bosh_ssh_key -t ssh -p "$BOSH_SSH_KEY" >/dev/null || clean_exit 1
credhub set -n /concourse/main/bosh_ssh_user -t value -v "jumpbox" >/dev/null || clean_exit 1
credhub set -n /concourse/main/jumpbox_host -t value -v "$TF_JUMPBOX_HOST" >/dev/null || clean_exit 1
credhub set -n /concourse/main/jumpbox_ssh_key -t ssh -p "$TF_JUMPBOX_SSH_KEY" >/dev/null || clean_exit 1
credhub set -n /concourse/main/jumpbox_user -t value -v "$TF_SSH_USER" >/dev/null || clean_exit 1
credhub set -n /concourse/main/env_name -t value -v "$TF_ENV_NAME" >/dev/null || clean_exit 1

bosh_credhub_login || clean_exit 1
