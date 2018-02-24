#Note
This is a WIP, Concourse is not yet integrated with Credhub nor UAA.
Nothing is scalable for now.

#Howto use:
##Deploy
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

# Will be created
dns_domain_name = "DNS Domain"

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

##SSH into the jumpbox
The key is located in the subfolder `local/ssh/`, and the username is `ubuntu`