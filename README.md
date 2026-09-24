# AWS HA Three-Tier Web Architecture

Production-oriented three-tier AWS architecture for a highly available web application deployed across two Availability Zones.

## Architecture

![Architecture Diagram](aws-ha-three-tier/docs/Architecture-Diagram.gif)

The design provides:

-   High availability across two Availability Zones
    
-   Public and private subnet isolation
    
-   Internet-facing and internal load balancing
    
-   Private EC2 instances for Web and Application tiers
    
-   Multi-AZ RDS PostgreSQL
    
-   NAT Gateways for controlled outbound access
    
-   Least-privilege security groups
    
-   Secrets management and encryption
    

## Project Structure

```text
.
├── README.md
├── architecture-diagram.md
├── SECURITY-DESIGN.md
└── terraform/

```



## Documentation

| Document | Description |
| :--- | :--- |
| [Architecture Diagram](./docs/architecture-diagram) | VPC, subnet, AZ, load-balancing and tier architecture |
| [Security Design](./docs/SECURITY-DESIGN.md) | Security groups, ports, secrets and encryption |
| [Terraform](./terraform/main.tf) | Infrastructure as Code implementation |



## Terraform

Terraform is being used to implement the documented architecture. While the architecture and design decisions are established first, the Terraform implementation is currently ongoing and being hardened.

```bash
cd terraform

terraform init
terraform fmt -recursive
terraform validate
terraform plan

```

## Key Design Principles

-   High availability
    
-   Network isolation
    
-   Least privilege
    
-   No direct Internet access to EC2 or RDS
    
-   Secure credential management
    
-   Encryption at rest and in transit
    
-   Infrastructure as Code
   