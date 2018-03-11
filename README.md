# Introduction
This tool will deploy:  
* A jumpbox
* A bosh director with credhub and uaa integrated
* A deployment with
    * postgres
    * credhub
    * uaa
    * concourse and it's worker

Only using `terraform`

You can scale each vm horizontally or verticaly (appart from postgres)

# Howto
## GCP
Follow documentation [here](terraform/gcp/README.md)

## AWS
Follow documentation [here](terraform/aws/README.md)

# Usage
## SSH into the jumpbox
The key is located in the subfolder `local/ssh/`, and the username is `ubuntu`  
Assuming you're in the terraform forlder:
```sh
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"
chmod 600 local/ssh/*
ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') -i local/ssh/jumpbox  -o "IdentitiesOnly=true"
```

## Concourse
### Retrieve the concourse admin user password (login is `admin`)
```sh
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /concourse_admin_password
```
### Login to concourse
The username is: `admin`  
The password is the one of the previous step    
```sh
fly login -c $(echo $TERRAFORM_OUTPUT | jq -r '.concourse_url') -t bootstrap -k
```

## Credhub
### Retrieve the credhub admin client secret (login is `credhub-admin`)
```sh
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /credhub_admin_client_secret
```
### Login to credub
The username is: `credhub-admin`  
The password is the one of the previous step  
```sh
credhub api -s $(echo $TERRAFORM_OUTPUT | jq -r '.credhub_url') --skip-tls-validation
export CREDHUB_CLIENT="credhub-admin"
export CREDHUB_SECRET=$(ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /credhub_admin_client_secret -j | jq -r '.value')
credhub login
```

## UAA
### Retrieve the uaa admin client password (login is `admin`)
```sh
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /uaa-admin
```
### Login with uaac
The username is: `admin`  
The password is the one of the previous step  
```sh
uaac target $(echo $TERRAFORM_OUTPUT | jq -r '.uaa_url') --skip-ssl-validation
uaac token client get admin
```

## Grafana
### Retrieve the grafana admin password (login is `admin`)
```sh
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /grafana_admin_password
```
### Connect to grafana
If you opted for `deploy_metrics = "true"`, you can connect to grafana through the URL provided as terraform output and using the password retrieved from the previous step.
```sh
terraform output -json | jq -r '.metrics_url.value'
```