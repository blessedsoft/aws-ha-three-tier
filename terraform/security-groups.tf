resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Public ALB security group"
  vpc_id      = aws_vpc.main.id
  egress      = []

  tags = {
    Name = "${local.name}-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "${local.name}-web-sg"
  description = "Web tier security group"
  vpc_id      = aws_vpc.main.id
  egress      = []

  tags = {
    Name = "${local.name}-web-sg"
  }
}

resource "aws_security_group" "internal_alb" {
  name        = "${local.name}-internal-alb-sg"
  description = "Internal ALB security group"
  vpc_id      = aws_vpc.main.id
  egress      = []

  tags = {
    Name = "${local.name}-internal-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${local.name}-app-sg"
  description = "Application tier security group"
  vpc_id      = aws_vpc.main.id
  egress      = []

  tags = {
    Name = "${local.name}-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${local.name}-db-sg"
  description = "Database tier security group"
  vpc_id      = aws_vpc.main.id
  egress      = []

  tags = {
    Name = "${local.name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count = var.acm_certificate_arn == null ? 0 : 1

  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "web_to_internal_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.internal_alb.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "web_dns_udp" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "${local.dns_resolver_ip}/32"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "web_dns_tcp" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "${local.dns_resolver_ip}/32"
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_web" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_to_app" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "app_from_internal_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.internal_alb.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "app_dns_udp" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "${local.dns_resolver_ip}/32"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "app_dns_tcp" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "${local.dns_resolver_ip}/32"
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}
