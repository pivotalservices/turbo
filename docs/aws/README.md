# Note
Do not use this for production, for now!

# Howto use:
## Instance types
**bold** is default  

| Terraform value | Concourse Web | Concourse Worker | postgres     |
| --------------- | :-----------: | :--------------: | :----------: |
| small           | **t2.small**  | -                | **t2.small** |
| medium          | t2.medium     | **t2.medium**    | t2.medium    |
| large           | t2.large      | m4.large         | m4.large     |
| xlarge          | t2.xlarge     | m4.xlarge        | m4.xlarge    |
| 2xlarge         | t2.2xlarge    | m4.2xlarge       | m4.2xlarge   |
| 4xlarge         | -             | m4.4xlarge       | m4.4xlarge   |
| 10xlarge        | -             | m4.10xlarge      | m4.10xlarge  |
| 16xlarge        | -             | m4.16xlarge      | m4.16xlarge  |
## Create a master DNS Zone
You'll want to create a master dns zone if you don't have one in AWS.  
The domain deployed will be a subdomain of this master dns zone.  
Example:  
master dns zone = `sub.master-dns-zone.com`  
subdomain that will be created = `xxx.sub.master-dns-zone.com` (the value of the variable `dns_domain_name`)

## Deploy
Create a terraform.tfvars file with :
```sh
# Used to prefix every object
env_name = "MyEnv"

# AWS Region
aws_region = "eu-west-2"

# AWS AZ list to use (up to 3 entries in the list).
# Do not modify the order once created. You can add but not delete entries 
# Eg for 3 entries: aws_azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
aws_azs = ["eu-west-2a"]

# The master DNS Domain name (fqdn)
master_dns_domain_name = "sub.master-dns-zone.com"

# Will be created
dns_domain_name = "xxx.sub.master-dns-zone.com"

# Must be a /22
bootstrap_subnet = "10.0.0.0/22"

# Can be 0.0.0.0/0 for full access or a list of IPs/subnets for restricted access
source_admin_networks = ["x.y.z.t/w", "1.2.3.4/16"]

# Optional (default is small)
# concourse_web_vm_type = "small"

# Optional (default is medium)
# concourse_worker_vm_type = "medium" 

# Optional (default is 1): Number of Concourse web VMs to deploy
# concourse_web_vm_count = 1

# Optional (default is 1): Number of Concourse workers to deploy
# concourse_worker_vm_count = 1

# Optional (default is false): Debug enabled
# debug = "false"

# Optional (default is 10): Size of the Database persistent disk
# db_persistent_disk_size = "10"

# Optional (default is small): Size of the postgres DB VM
# db_vm_type = "small"

# Optional (default is false): Deploy grafana and influxdb to monitor the solution
# deploy_metrics = "false"
```

Also export your AWS Secret and Access key:
```sh
export TF_VAR_aws_secret_key="XXXXXXXXXXXX"
export TF_VAR_aws_access_key="XXXXXXXXXXXX"
```

Then simply run `terraform init && terraform apply`

## Destroy
Simply run `terraform destroy`
All deployments will be deleted and all your resources also (Verify that's really the case :) )