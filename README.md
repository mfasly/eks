# Stratos

EKS Cluster provisioner 

## Components
```hcl
1. AWS Dedicated VPC
2. Security Groups
3. Bastion host with EC2 instance
4. EKS cluster with AWS launch template
```

### How to Deploy

Change directory to desired env (ex: for deploy production env)

```commandline
cd env/prd
```

Run terraform init

```commandline
terraform init
```

Then run terraform plan(Optional)

```commandline
terraform plan
```

Finaly run terraform apply for provision infrastructure

```commandline
terraform apply
```

To Destroy provisioned infrastructure

```commandline
terraform destroy
```

