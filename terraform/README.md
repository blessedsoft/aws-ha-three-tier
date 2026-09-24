# Terraform

Terraform is used to implement the AWS three-tier architecture documented in the root-level architecture and security documents.

## Resources

The implementation covers:

* VPC
* Public, private and isolated subnets
* Internet Gateway
* NAT Gateways
* Route tables
* Security groups
* Public Application Load Balancer
* Internal Application Load Balancer
* Web EC2 instances
* Application EC2 instances
* Auto Scaling
* RDS PostgreSQL Multi-AZ

## Configuration

Infrastructure settings are exposed through Terraform variables, including:

* AWS region
* Environment
* Availability Zones
* EC2 instance sizes
* RDS instance class
* Network CIDRs
* Application port

## Usage

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Status

The Terraform layer is the implementation phase of the architecture.

The architectural design and security requirements are documented first, with the Terraform configuration being progressively completed and validated against those requirements.
