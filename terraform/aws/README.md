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

# The master DNS Domain name (fqdn)
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

## Destroy
Simply run `terraform destroy`
All deployments will be deleted and all your resources also (Verify that's really the case :) )