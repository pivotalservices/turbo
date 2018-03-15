#!/usr/bin/env bash
if [ "x$TF_DEBUG" == "xtrue" ]; then
	set -x
fi

if [ ! -f ~/.first_run_done ]; then
	touch ~/.first_run_done
	echo "Waiting 20sec for network to be up completely..."
	sleep 20
fi

echo "Fetching updates and installing bosh dependencies..."
sudo apt-get update >/dev/null || exit 1
sudo apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 jq >/dev/null || exit 1

curl -s -L --output bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.48-linux-amd64 >/dev/null &&
	chmod 755 bosh >/dev/null &&
	sudo mv bosh /usr/local/bin >/dev/null || exit 1

credhub_url=$(curl -s https://api.github.com/repos/cloudfoundry-incubator/credhub-cli/releases/latest | jq -r ".assets[] | select(.name | test(\"credhub-linux\")) | .browser_download_url")
(
	curl -L -o credhub.tgz $credhub_url >/dev/null &&
		tar -zxvf credhub.tgz >/dev/null &&
		chmod 755 credhub >/dev/null &&
		sudo mv credhub /usr/local/bin/ >/dev/null &&
		rm -rf credhub.tgz >/dev/null &&
		echo "credhub installation complete"
) || exit 1

bbr_url=$(curl -s https://api.github.com/repos/cloudfoundry-incubator/bosh-backup-and-restore/releases/latest | jq -r ".assets[] | select(.name | test(\"bbr-\")) | .browser_download_url")
(
	curl -L -o bbr.tar $bbr_url >/dev/null &&
		tar -xvf bbr.tar >/dev/null &&
		chmod 755 releases/bbr >/dev/null &&
		sudo mv releases/bbr /usr/local/bin/ >/dev/null &&
		rm -rf bbr.tar releases >/dev/null &&
		echo "bbr installation complete"
) || exit 1

echo "Updates and bosh dependencies installed!"

# Wait for persistent disk mount
i=0
echo "Waiting max 120sec for persistent disk to be mounted..."
while ! mount | grep /data >/dev/null; do
	sleep 1
	i=$(($i + 1))
	if [ $i -ge 120 ]; then # exit after 120 sec
		echo "Persistent disk not mounted after 120 sec, exiting..."
		exit 1
	fi
done
echo "Persistent disk mounted to /data"

USERNAME=$(id -un)
GROUP=$(id -gn)
BOSH_STATE="/data/bosh-state"
sudo mkdir -p "$BOSH_STATE" >/dev/null || exit 1
sudo chmod 755 "/data" >/dev/null || exit 1
sudo chmod 700 "$BOSH_STATE" >/dev/null || exit 1
sudo chown ${USERNAME}:${GROUP} "$BOSH_STATE" >/dev/null || exit 1
