# Disclaimer
:warning: :warning: **CAUTION: Pivotal does not provide support for this tool.** :warning: :warning:  
:warning: :warning: If you find anything broken, then please submit PR's. :warning: :warning:  
:warning: :warning: This is not production ready :warning: :warning:

# Introduction
**TuRBO** stands for: TeRraforming BOsh

TuRBO will deploy:  
* A jumpbox
* A bosh director with credhub and uaa integrated
* A deployment with
    * postgres
    * credhub
    * uaa
    * concourse and it's worker
    * grafana, influxdb and riemann if you choose to (`deploy_metrics = "true"`)

Only using `terraform`

You can scale each vm horizontally or verticaly (appart from postgres and grafana)  
Your deployment will be `bbr` ready.

---
# Howto
## Use this repo
### Checkout this repo
```sh
git clone https://github.com/pivotalservices/turbo.git
git submodule sync
git submodule update --init --recursive
```

### Gather updates
```
git pull
git submodule sync
git submodule update --init --recursive
```

## GCP
Follow documentation [here](docs/gcp/README.md)

## AWS
Follow documentation [here](docs/aws/README.md)

## Azure
Follow documentation [here](docs/azure/README.md)

---
# Usage
For every command below, we assume that you're in the terraform folder of your iaas provider, and that a terraform apply has finished succesfully
## SSH into the jumpbox
The key is located in the `terraform output`, and the username is `ubuntu`  
You can connect to the jumpbox with:
```sh
../../bin/jumpbox-ssh.sh
```

## Concourse
1. Retrieve the concourse `admin` user password
```sh
terraform output concourse_password
```

2. Login to concourse with the fly cli
The username is: `admin`    
```sh
../../bin/fly-login.sh
```

3. Or connect to the web gui URL
```
terraform output concourse_url
```

## Credhub
Make sure you are using credhub-cli >=1.7.0

1. Retrieve the `credhub-admin` client secret
```sh
terraform output credhub_password
```

2. Login to credhub
The username is: `credhub-admin`  
```sh
../../bin/credhub-login.sh
```

## UAA
1. Retrieve the uaa `admin` client password
```sh
terraform output uaa_password
```

2. Login with uaac
The username is: `admin`  
```sh
../../bin/uaa-login.sh
```

## Grafana
If you opted for `deploy_metrics = "true"`, you can connect to grafana through the URL provided as terraform output and using the password retrieved from the previous step.
1. Retrieve the grafana `admin` password
```sh
terraform output metrics_password
```

2. Retrieve the grafana URL
```sh
terraform output metrics_url
```
