#!/usr/bin/env bash
BOSH_HOST="https://$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target)"
BOSH_CLIENT_SECRET=$(bosh int "$BOSH_VAR_CACHE" --path /bosh_client_secret)
BOSH_CA_CERT="$BOSH_STATE_FOLDER/ca.pem"
BOSH_SSH_PRIVATE_KEY="${BOSH_SSH_KEY}"

usage() {
	echo "Usage: $0 [director|deployment [deployment-name]"
	exit 1
}

if [ "x$1" == "x" ]; then
	usage
elif [ "$1" == "deployment" ] && [ "x$2" == "x" ]; then
	usage
fi

if [ "$1" == "deployment" ]; then
	bbr deployment -t ${BOSH_HOST} \
		-u ${BOSH_CLIENT} \
		--ca-cert ${BOSH_CA_CERT} \
		-d "$2" backup || exit 1
elif [ "$1" == "director" ]; then
	bbr director --private-key-path "${BOSH_SSH_PRIVATE_KEY}" \
		--username jumpbox \
		--host "$(bosh int "$BOSH_VAR_CACHE" --path /bosh_target)" \
		backup
fi
