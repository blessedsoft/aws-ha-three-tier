data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  name = "${var.project_name}-${var.environment}"

  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]

  public_subnets = {
    az_a = { cidr = cidrsubnet(var.vpc_cidr, 8, 0), az = local.az_a }
    az_b = { cidr = cidrsubnet(var.vpc_cidr, 8, 1), az = local.az_b }
  }

  web_subnets = {
    az_a = { cidr = cidrsubnet(var.vpc_cidr, 8, 10), az = local.az_a }
    az_b = { cidr = cidrsubnet(var.vpc_cidr, 8, 11), az = local.az_b }
  }

  app_subnets = {
    az_a = { cidr = cidrsubnet(var.vpc_cidr, 8, 20), az = local.az_a }
    az_b = { cidr = cidrsubnet(var.vpc_cidr, 8, 21), az = local.az_b }
  }

  db_subnets = {
    az_a = { cidr = cidrsubnet(var.vpc_cidr, 8, 30), az = local.az_a }
    az_b = { cidr = cidrsubnet(var.vpc_cidr, 8, 31), az = local.az_b }
  }

  dns_resolver_ip = cidrhost(var.vpc_cidr, 2)
}
