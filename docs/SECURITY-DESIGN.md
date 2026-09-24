
## Security Design
### Security Model

The architecture uses separate security groups for each tier and permits only required tier-to-tier communication.

#### Tier-to-Tier Ports

| Source | Destination | Port | Purpose |
| :--- | :--- | :--- | :--- |
| Internet | Public ALB | `80` / `443` | Web access |
| Public ALB SG | Web SG | `80` | ALB to Nginx |
| Web SG | Internal ALB SG | `3000` | Web to application |
| Internal ALB SG | App SG | `3000` | ALB to Node.js |
| App SG | DB SG | `5432` | PostgreSQL |
| Web/App | Internet via NAT | `443` | Outbound HTTPS |

#### Least Privilege

* Public ALB accepts only required HTTP/HTTPS traffic.
* Web instances accept traffic only from the public ALB.
* Application instances accept traffic only from the internal ALB.
* RDS accepts PostgreSQL connections only from the application tier.
* No direct Internet access to EC2 or RDS.
* SSH port 22 is not publicly exposed.

    

## Secrets Management

Database credentials must not be hardcoded in Terraform or application code.

RDS is configured to manage the master password through AWS Secrets Manager:

```hcl
manage_master_user_password = true

```

Application workloads use IAM permissions to retrieve only the required secret.

Sensitive files such as Terraform state, private keys and credentials must not be committed to Git.

## Encryption

### At Rest

-   RDS storage encryption enabled.
    
-   RDS backups encrypted.
    
-   AWS KMS available for customer-managed keys where required.
    

### In Transit

-   HTTPS supported through the public ALB.
    
-   TLS used for PostgreSQL connections.
    
-   ACM certificates can be used for HTTPS.
    
-   Internal TLS can be introduced where required by the security policy.
    

## Administration

EC2 administration is intended to use AWS Systems Manager Session Manager rather than publicly exposed SSH.

## Production Hardening

Future improvements may include:

-   AWS WAF
    
-   CloudWatch monitoring and alerting
    
-   VPC endpoints
    
-   Centralized logging
    
-   Automated patch management
    
-   Terraform remote state and locking
    
-   Security scanning
    
-   Vulnerability management
    
-   Backup and restore testing