locals {
  egress_all = {
    description = "Allow all outbound traffic"
    from_port   = 0 # `from` and `to` _port rules are ignored when `-1` protocol is defined
    to_port     = 0
    protocol    = "-1"
  }

  cidr_default = "0.0.0.0/0"

  default_ssh_port = 22

  tcp_protocol = "tcp"
}

# ---------------- ALB Seccurity Group ------------------
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-sg-alb"
  description = "Allow HTTP/HTTPS from the internet"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sg-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from internet"
  ip_protocol       = local.tcp_protocol
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = local.cidr_default
}

resource "aws_vpc_security_group_ingress_rule" "alb_inbound_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from internet"
  ip_protocol       = local.tcp_protocol
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = local.cidr_default
}


resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb.id
  description       = local.egress_all.description
  from_port         = local.egress_all.from_port
  to_port           = local.egress_all.to_port
  ip_protocol       = local.egress_all.protocol
  cidr_ipv4         = local.cidr_default
}

# ---------------- EC2 Security Group ------------------
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-sg-ec2"
  description = "Allow app traffic from SSH from Bastion and ALB"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sg-ec2"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound" {
  security_group_id = aws_security_group.ec2.id
  description       = "App port from ALB"
  ip_protocol       = local.tcp_protocol
  from_port         = var.app_port
  to_port           = var.app_port

  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "ec2_inbound_ssh" {
  security_group_id = aws_security_group.ec2.id
  description       = "SSH from Bastion"
  ip_protocol       = local.tcp_protocol
  from_port         = local.default_ssh_port
  to_port           = local.default_ssh_port

  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2.id
  description       = local.egress_all.description
  from_port         = local.egress_all.from_port
  to_port           = local.egress_all.to_port
  ip_protocol       = local.egress_all.protocol
  cidr_ipv4         = local.cidr_default
}

# ---------------- RDS Security Group ------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-sg-rds"
  description = "Allow RDS traffic from EC2"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sg-rds"
  })
}
resource "aws_vpc_security_group_ingress_rule" "rds_inbound" {
  description       = "PostgreSQL from EC2"
  security_group_id = aws_security_group.rds.id
  ip_protocol       = local.tcp_protocol
  from_port         = 5432
  to_port           = 5432

  referenced_security_group_id = aws_security_group.ec2.id
}

resource "aws_vpc_security_group_egress_rule" "rds_outbound" {
  security_group_id = aws_security_group.rds.id

  description = local.egress_all.description
  from_port   = local.egress_all.from_port
  to_port     = local.egress_all.to_port
  ip_protocol = local.egress_all.protocol
  cidr_ipv4   = local.cidr_default
}


# ---------------- Bastion Security Group ------------------
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${var.environment}-sg-bastion"
  description = "Allow SSH from allowed CIDRs"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sg-bastion"
  })
}

resource "aws_vpc_security_group_ingress_rule" "bastion_inbound_ssh" {
  security_group_id = aws_security_group.bastion.id
  description       = "SSH from known IP"
  ip_protocol       = "tcp"
  from_port         = local.default_ssh_port
  to_port           = local.default_ssh_port
  cidr_ipv4         = var.bastion_allowed_cidrs
}

resource "aws_vpc_security_group_egress_rule" "bastion_outbound" {
  security_group_id = aws_security_group.bastion.id
  description       = local.egress_all.description
  ip_protocol       = local.egress_all.protocol
  from_port         = local.egress_all.from_port
  to_port           = local.egress_all.to_port
  cidr_ipv4         = local.cidr_default
}


