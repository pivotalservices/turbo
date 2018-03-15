# Introduction
**TuRBO** stands for: **T**e**R**afforming **BO**sh

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
## GCP
Follow documentation [here](terraform/gcp/README.md)

## AWS
Follow documentation [here](terraform/aws/README.md)

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
