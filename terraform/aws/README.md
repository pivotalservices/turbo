# Note
This is a WIP, Concourse is not yet integrated UAA.  
Nothing is scalable for now.

# Howto use:
## Create a master DNS Zone
You'll want to create a master dns zone if you don't have one in AWS.  
The domain deployed will be a subdomain of this master dns zone.  
Example:  
master dns zone = `sub.master-dns-zone.com`  
subdomain that will be created = `xxx.sub.master-dns-zone.com` (the value of the variable `dns_domain_name`)

## Deploy
Create a terraform.tfvars file with :
```
# Used to prefix every object
env_name = "MyEnv"

# AWS Region
aws_region = "eu-west-2"

# AWS AZ 1
aws_az_1 = "eu-west-2a"

# The master DNS Zone name (not the actual fqdn, but the name of the resource in GCP)
master_dns_domain_name = "sub.master-dns-zone.com"

# Will be created
dns_domain_name = "xxx.sub.master-dns-zone.com"

# Must be a /24
bootstrap_subnet = "10.0.0.0/24"

# Can be 0.0.0.0/0 for full access or a list of IPs/subnets for restricted access
source_admin_networks = ["x.y.z.t/w", "1.2.3.4/16"] 
```

Also export your AWS Secret and Access key:
```
export TF_VAR_aws_secret_key=XXXXXXXXXXXX
export TF_VAR_aws_access_key=XXXXXXXXXXXX
```

Then simply run `terraform init && terraform apply`

## SSH into the jumpbox
The key is located in the subfolder `local/ssh/`, and the username is `ubuntu`  
Assuming you're in the terraform forlder:
```
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"
chmod 600 local/ssh/*
ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') -i local/ssh/jumpbox  -o "IdentitiesOnly=true"
```

## Retrieve the concourse admin password:
```
export TERRAFORM_OUTPUT="$(terraform output \
  -json | jq 'map_values(.value)')"
export TERRAFORM_ENV_NAME=$(cat terraform.tfvars | grep env_name | cut -d "=" -f 2 | sed -e 's/\ //g' -e 's/"//g')
chmod 600 local/ssh/*
ssh ubuntu@$(echo $TERRAFORM_OUTPUT | jq -r '.jumpbox_ip') -i local/ssh/jumpbox  -o "IdentitiesOnly=true" credhub get -n /$TERRAFORM_ENV_NAME-bosh1/$TERRAFORM_ENV_NAME-concourse/ui_password
```

## Destroy
Simply run `terraform destroy`
All deployments will be deleted and all your resources also (Verify that's really the case :) )