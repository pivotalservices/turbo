#!/usr/bin/env bash

set -eo pipefail

# Export metadata as environment variables
green=$(tput -T xterm setaf 2)
reset=$(tput -T xterm sgr0)
env_json="$(cat terraform/metadata)"
for var in $(echo "$env_json" | jq -r 'keys[]'); do
	export $var="$(echo "$env_json" | jq -r ".$var")"
done
export env_name="$(cat terraform/name)"

cat terraform/metadata | jq -r '.jumpbox_ssh_private_key' >id_rsa
chmod 600 id_rsa

curl -o credhub https://storage.googleapis.com/bosh-release-jwi/credhub-linux &&
	chmod +x credhub

curl -k -o fly "${concourse_url}/api/v1/cli?arch=amd64&platform=linux" &&
	chmod +x fly

export CREDHUB_SERVER=${credhub_url}
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=${credhub_password}

echo "${green}Connection to the jumpbox and ls the ~/automation folder${reset}"
ssh "${jumpbox_ssh_user}@${jumpbox_ip}" \
	-i id_rsa \
	-o "IdentitiesOnly=true" -o "StrictHostKeyChecking=no" "ls -la automation"

echo "${green}Connecting to credhub on ${credhub_url}${reset}"
./credhub api -s ${credhub_url} --skip-tls-validation
echo "${green}Setting /concourse/main/test_value in credhub${reset}"
./credhub set -n /concourse/main/test_value -t value -v "World"

echo "${green}Connecting to concourse on ${concourse_url}${reset}"
./fly -t local login -c "${concourse_url}" -k \
	-u admin -p "${concourse_password}"

cat <<"EOF" >test.yml
jobs:
- name: hello-world
  plan:
  - task: say-hello
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: busybox}
      run:
        path: sh
        args:
        - -c
        - |
          #!/usr/bin/env sh
          echo Hello $CREDHUB_VALUE
    params:
      CREDHUB_VALUE: ((test_value))
EOF

set -x
echo "${green}Testing pipelines and credhub integration${reset}"
./fly -t local sp -p hello-world -c test.yml -n
./fly -t local unpause-pipeline -p hello-world
./fly -t local trigger-job --job=hello-world/hello-world -w | tee output
grep "Hello World" output
rm -rf output

# Dirty Fix fox :
# (https://github.com/pivotal-cf/credhub-release/pull/19)
echo "${green}Dirty fix while https://github.com/pivotal-cf/credhub-release/pull/19 is not accepted${reset}"
cat <<EOF >metadata
#!/usr/bin/env bash
echo "---
restore_should_be_locked_before:
- job_name: uaa
  release: uaa"
EOF
chmod 755 metadata

scp -i id_rsa \
	-o "IdentitiesOnly=true" -o "StrictHostKeyChecking=no" \
	metadata "${jumpbox_ssh_user}@${jumpbox_ip}":~/

ssh "${jumpbox_ssh_user}@${jumpbox_ip}" \
	-i id_rsa \
	-o "IdentitiesOnly=true" -o "StrictHostKeyChecking=no" \
	'bosh -d ucc scp ~/metadata web:/tmp/ ;\
    bosh -d ucc ssh web "sudo mv /tmp/metadata /var/vcap/jobs/credhub/bin/bbr/ && sudo chown root:root /var/vcap/jobs/credhub/bin/bbr/metadata" ;'

# End Dirty Fix
echo "${green}Running bbr backup of the deployment${reset}"
ssh "${jumpbox_ssh_user}@${jumpbox_ip}" \
	-i id_rsa \
	-o "IdentitiesOnly=true" -o "StrictHostKeyChecking=no" \
	'mkdir -p ci-tests && \
    cd ci-tests && \
    ~/automation/bosh/scripts/generic/bbr-backup.sh deployment ucc'

echo "${green}Waiting 2min for everything to be running again${reset}"
sleep 120

echo "${green}Deleting the pipeline and the credhub entry${reset}"
./fly -t local destroy-pipeline -p hello-world -n
./credhub delete -n /concourse/main/test_value

echo "${green}Running bbr restore of the deployment${reset}"
ssh "${jumpbox_ssh_user}@${jumpbox_ip}" \
	-i id_rsa \
	-o "IdentitiesOnly=true" -o "StrictHostKeyChecking=no" \
	'mkdir -p ci-tests && \
    pushd ci-tests ; \
    ~/automation/bosh/scripts/generic/bbr-restore.sh deployment ucc "$(pwd)/$(ls -1t -d ucc* | head -n 1)";\
    rc=$?;
    popd; \
    rm -rf ci-tests metadata;\
    exit $rc'

echo "${green}Waiting 2min for everything to be running again${reset}"
sleep 120

echo "${green}Verifying that the pipeline and the credhub entry is still there${reset}"
./fly -t local trigger-job --job=hello-world/hello-world -w | tee output
grep "Hello World" output
echo "${green}Cleaning up the environment${reset}"
./fly -t local destroy-pipeline -p hello-world -n
./credhub delete -n /concourse/main/test_value
rm -f id_rsa test.yml metadata output

echo
echo "${green}TESTING OKAY!${reset}"
