# Note
This is a WIP, Concourse is not yet integrated with Credhub nor UAA.  
Nothing is scalable for now.

# Howto use:
## Create a master DNS Zone
You'll want to create a master dns zone if you don't have one in GCP.  
The domain deployed will be a subdomain of this master dns zone  
Example:  
master dns zone = `gcp.mydomain.com` (this resource has a name in GCP, use that as the value of `master_dns_zone_name`)  
subdomain that will be created = `myenv.gcp.mydomain.com` (the value of the variable `dns_domain_name`)

## Deploy
Create a terraform.tfvars file with :
```
# Used to prefix every object
env_name = "MyEnv"

# Name of the GCP Project
gcp_project_name = "GCP-Project-Name"

# GCP Region
gcp_region = "GCP-Region"

# GCP Zone in the region
gcp_zone_1 = "GCP-Zone"

# The master DNS Zone name (not the actual fqdn, but the name of the resource in GCP)
master_dns_zone_name = "my-zone-name"

# Will be created
dns_domain_name = "xxx.master-dns-zone.com"

# Must be a /24
bootstrap_subnet = "10.0.0.0/24"

# Can be 0.0.0.0/0 for full access or a list of IPs/subnets for restricted access
source_admin_networks = ["x.y.z.t/w", "1.2.3.4/16"] 

```

Also export your GCP key:
```
export TF_VAR_gcp_key=$(cat gcp-key.json)
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