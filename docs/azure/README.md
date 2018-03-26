# Note
Do not use this for production, for now!

# Howto use:
## Instance types
**bold** is default  

| Terraform value | Concourse Web       | Concourse Worker    | postgres            |
| --------------- | :-----------------: | :-----------------: | :-----------------: |
| small           | **Standard_DS1_v2** | -                   | **Standard_DS1_v2** |
| medium          | Standard_DS2_v2     | **Standard_DS2_v2** | Standard_DS2_v2     |
| large           | Standard_DS3_v2     | Standard_DS3_v2     | Standard_DS3_v2     |
| xlarge          | Standard_DS4_v2     | Standard_DS4_v2     | Standard_DS4_v2     |
| 2xlarge         | Standard_DS5_v2     | Standard_DS5_v2     | Standard_DS5_v2     |
| 4xlarge         | -                   | Standard_D32s_v3    | Standard_D32s_v3    |
| 10xlarge        | -                   | Standard_D64s_v3    | Standard_D64s_v3    |
| 16xlarge        | -                   | Standard_D64s_v3    | Standard_D64s_v3    |

## Create a master DNS Zone
You'll want to create a master dns zone if you don't have one in GCP.  
The domain deployed will be a subdomain of this master dns zone.  
Example:  
master dns zone = `sub.master-dns-zone.com`  
subdomain that will be created = `xxx.sub.master-dns-zone.com` (the value of the variable `dns_domain_name`)

## Create an Azure Service Principal
If you don't have one already, you'll need to create an Azure Service Principal:
```sh
az login
az ad sp create-for-rbac --name turbo --password $(openssl rand -base64 32) --years 999
# Write down the AppID and the password from the output, you will not be able to retrieve it later.
# TF_VAR_arm_client_id=AppID
# TF_VAR_arm_client_secret=Password
# The service principal will have the Contributor Role on your whole subscription
```

## Deploy
Create a terraform.tfvars file with :
```sh
# Used to prefix every object
env_name = "MyEnv"

# The location for your deployments
arm_location = "West Europe"

# Optional (default is public): Azure environment: public, usgovernment, german, china
# arm_environment = "public"

# The master DNS Domain name (fqdn)
master_dns_domain_name = "sub.master-dns-zone.com"

# The Azure Resource group name where your master domain sits
master_dns_domain_name_rg = "master-dns-zone-rg"

# Will be created
dns_domain_name = "xxx.sub.master-dns-zone.com"

# Must be a /24
bootstrap_subnet = "10.0.0.0/24"

# Optional (default is small)
# concourse_web_vm_type = "small"

# Optional (default is medium)
# concourse_worker_vm_type = "medium" 

# Optional (default is 1): Number of Concourse web VMs to deploy
# concourse_web_vm_count = 1

# Optional (default is 1): Number of Concourse workers to deploy
# concourse_worker_vm_count = 1

# Optional (default is 1): Number of Credhub-UAA VMs to deploy
# credhub_uaa_vm_count = 1

# Optional (default is false): Debug enabled
# debug = "false"

# Optional (default is 10): Size of the Database persistent disk
# db_persistent_disk_size = "10"

# Optional (default is small): Size of the postgres DB VM
# db_vm_type = "small"

# Optional (default is false): Deploy grafana and influxdb to monitor the solution
# deploy_metrics = "false"
```

Also export your Azure informations:
```sh
export TF_VAR_arm_tenant_id="XXXXXXXXXXXX"
export TF_VAR_arm_subscription_id="XXXXXXXXXXXX"
export TF_VAR_arm_client_id="XXXXXXXXXXXX"
export TF_VAR_arm_client_secret="XXXXXXXXXXXX"
```

Then simply run `terraform init && terraform apply`

## Destroy
Simply run `terraform destroy`
All deployments will be deleted and all your resources also (Verify that's really the case :) )