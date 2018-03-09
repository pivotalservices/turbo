#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi
set -o pipefail

if [ "x$1" == "x" ]; then
	echo "Missing deployment name"
	exit 1
fi

DEPLOYMENT=$1

source ~/automation/scripts/bosh/generic/helpers.sh
source ~/automation/scripts/bosh/generic/bosh-helper.sh

DEPLOYMENT_NAME="$TF_ENV_NAME-$DEPLOYMENT"
DEPLOYMENT_HOME="$BOSH_DEPLOYMENTS_FOLDER/$DEPLOYMENT"
DEPLOYMENT_FLAGS="$TF_FLAGS"
DEPLOYMENT_REPO_FOLDER="$DEPLOYMENT_HOME/repo"

clean_exit() {
	rc=$1
	rm -rf "$DEPLOYMENT_REPO_FOLDER" "$DEPLOYMENT_HOME/ops.bak" && mv "$DEPLOYMENT_HOME/ops" "$DEPLOYMENT_HOME/ops.bak" && mkdir "$DEPLOYMENT_HOME/ops"
	exit $rc
}

bosh_login || clean_exit 1
bosh_credhub_login || clean_exit 1

### PRE-DEPLOY
if [ -f $DEPLOYMENT_HOME/scripts/pre-deploy.sh ]; then
	source $DEPLOYMENT_HOME/scripts/pre-deploy.sh
fi

if [ "x$DEPLOYMENT_REPO" != "x" ]; then
	git_clone_or_update "$DEPLOYMENT_REPO_FOLDER" "$DEPLOYMENT_REPO" "$DEPLOYMENT_REPO_VERSION"
fi

if [ ! -f "$DEPLOYMENT_HOME/versions/versions.yml" ]; then
	echo "Missing /stemcell_version in versions.yml file"
	clean_exit 1
fi

STEMCELL_VERSION=$(bosh int "$DEPLOYMENT_HOME/versions/versions.yml" --path /stemcell_version)
if [ "$STEMCELL_VERSION" != "latest" ]; then
	STEMCELL="$STEMCELL?v=$STEMCELL_VERSION"
fi
bosh -e "$BOSH_ENV" upload-stemcell https://bosh.io/d/stemcells/$STEMCELL || clean_exit 1

DEPLOYMENT_OPS_FILES_ADD_BASIC=$(find $DEPLOYMENT_HOME/ops/*.yml)
DEPLOYMENT_OPS_FILES_ADD_FLAGS=$(
	for dir in $(echo "$DEPLOYMENT_FLAGS" | jq -r '. as $object | keys[] | select($object[.] == "true")'); do
		find $DEPLOYMENT_HOME/ops/$dir/*.yml
	done
)

if [ "x$DEPLOYMENT_OPS_FILES_ADD_FLAGS" == "x" ]; then
	DEPLOYMENT_ALL_OPS="$DEPLOYMENT_OPS_FILES_ADD_BASIC"
else
	DEPLOYMENT_ALL_OPS="$DEPLOYMENT_OPS_FILES_ADD_BASIC
$DEPLOYMENT_OPS_FILES_ADD_FLAGS"
fi

DEPLOYMENT_OPS_FILES_ADD=$(printf '%s' "$DEPLOYMENT_ALL_OPS" | sort | sed 's/^/-o /' | xargs)

# run the deployment
if do_deploy; then
	if [ -f $DEPLOYMENT_HOME/scripts/post-deploy.sh ]; then
		source $DEPLOYMENT_HOME/scripts/post-deploy.sh
	fi
	echo "Cleaning up unused releases..."
	for line in $(bosh -e "$BOSH_ENV" releases --json | jq '.Tables[].Rows[] | select(.version | endswith("*") | not)' -r --compact-output); do
		release="$(echo $line | jq -r '.name')/$(echo $line | jq -r '.version')"
		echo "Deleting release $release"
		bosh -e "$BOSH_ENV" delete-release "$(echo $line | jq -r '.name')/$(echo $line | jq -r '.version')" -n
	done
	clean_exit 0
else
	clean_exit 1
fi
