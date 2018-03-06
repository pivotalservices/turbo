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

# Howto:
## GCP
Follow documentation [here](terraform/gcp/README.md)

## AWS
Follow documentation [here](terraform/aws/README.md)

# Usage:
## SSH into the jumpbox
The key is located in the subfolder `local/ssh/`, and the username is `ubuntu`  
Assuming you're in the terraform forlder:
```
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"
chmod 600 local/ssh/*
ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') -i local/ssh/jumpbox  -o "IdentitiesOnly=true"
```

## Retrieve the concourse admin user password
```
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

export TERRAFORM_ENV_NAME=$(cat terraform.tfvars \
  | grep env_name | cut -d "=" -f 2 \
  | sed -e 's/\ //g' -e 's/"//g')

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /$TERRAFORM_ENV_NAME-bosh1/$TERRAFORM_ENV_NAME-ucc/concourse_admin_password
```

## Retrieve the credhub admin client secret
```
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

export TERRAFORM_ENV_NAME=$(cat terraform.tfvars \
  | grep env_name | cut -d "=" -f 2 \
  | sed -e 's/\ //g' -e 's/"//g')

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /$TERRAFORM_ENV_NAME-bosh1/$TERRAFORM_ENV_NAME-ucc/credhub_admin_client_secret
```

## Retrieve the uaa admin client password
```
chmod 600 local/ssh/*
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"

export TERRAFORM_ENV_NAME=$(cat terraform.tfvars \
  | grep env_name | cut -d "=" -f 2 \
  | sed -e 's/\ //g' -e 's/"//g')

ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') \
  -i local/ssh/jumpbox  -o "IdentitiesOnly=true" \
  credhub get -n /$TERRAFORM_ENV_NAME-bosh1/$TERRAFORM_ENV_NAME-ucc/uaa-admin
```