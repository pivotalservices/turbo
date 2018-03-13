#!/usr/bin/env bash

TERRAFORM_OUTPUT=$(terraform output --json | jq 'map_values(.value)')

uaac target $(echo "$TERRAFORM_OUTPUT" | jq -r '.uaa_url') --skip-ssl-validation || exit 1
uaac token client get admin -s "$(echo "$TERRAFORM_OUTPUT" | jq -r '.uaa_password')" || exit 1

echo "You're now connected to UAA at '$(echo "$TERRAFORM_OUTPUT" | jq -r '.uaa_url')' as user 'admin'"
