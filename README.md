# Introduction
**TuRBO** stands for: TeRrafforming BOsh

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
