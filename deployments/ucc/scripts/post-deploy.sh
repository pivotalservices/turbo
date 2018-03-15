#!/usr/bin/env bash

ucc_credhub_login() {
	credhub api "$TF_CREDHUB_URL" --skip-tls-validation || return 1
	credhub login --client-name=credhub-admin --client-secret="$TF_CREDHUB_PASSWORD" || return 1
}

ucc_credhub_login || clean_exit 1

credhub set -n /concourse/main/bosh_ca_cert -t certificate -c "$BOSH_CA_CERT" || clean_exit 1
credhub set -n /concourse/main/bosh_host -t value -v "$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target)" || clean_exit 1
credhub set -n /concourse/main/jumpbox_ssh_key -t ssh -p "$BOSH_SSH_KEY" || clean_exit 1
credhub set -n /concourse/main/jumpbox_user -t value -v "$$TF_SSH_USER" || clean_exit 1
credhub set -n /concourse/main/env_name -t value -v "$TF_ENV_NAME" || clean_exit 1

bosh_credhub_login || clean_exit 1
