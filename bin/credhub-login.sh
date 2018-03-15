#!/usr/bin/env bash

TERRAFORM_OUTPUT=$(terraform output --json | jq 'map_values(.value)')

export CREDHUB_SERVER=$(echo "$TERRAFORM_OUTPUT" | jq -r '.credhub_url')
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=$(echo "$TERRAFORM_OUTPUT" | jq -r '.credhub_password')
credhub api -s $(echo "$TERRAFORM_OUTPUT" | jq -r '.credhub_url') --client --skip-tls-validation >/dev/null || exit 1
echo "You're now connected to credhub on '$CREDHUB_SERVER' as user '$CREDHUB_CLIENT'"
