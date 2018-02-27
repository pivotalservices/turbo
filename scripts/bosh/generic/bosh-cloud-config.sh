#!/usr/bin/env bash
set -x

source /home/${tf_ssh_user}/automation/scripts/bosh/generic/helpers.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/generic/bosh-helper.sh
source /home/${tf_ssh_user}/automation/scripts/bosh/iaas-specific/manage-env.sh

bosh_login || exit 1
bosh_update_cloud_config || exit 1