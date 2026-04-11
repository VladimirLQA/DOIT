locals {
  egress_all = {
    description = "Allow all outbound traffic"
    from_port   = 0
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

  ingress {
    description = "App port from ALB"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from Bastion"
    from_port   = local.default_ssh_port
    to_port     = local.default_ssh_port
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.bastion.id]
  }

  egress {
    description = local.egress_all.description
    from_port   = local.egress_all.from_port
    to_port     = local.egress_all.to_port
    protocol    = local.egress_all.protocol
    cidr_blocks = [local.cidr_default]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sg-ec2"
  })
}

# ---------------- RDS Security Group ------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-sg-rds"
  description = "Allow RDS traffic from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from EC2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.ec2.id]
  }

  egress {
    description = local.egress_all.description
    from_port   = local.egress_all.from_port
    to_port     = local.egress_all.to_port
    protocol    = local.egress_all.protocol
    cidr_blocks = [local.cidr_default]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sg-rds"
  })
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
  ip_protocol       = "tcp"
  from_port         = local.default_ssh_port
  to_port           = local.default_ssh_port
  cidr_ipv4         = local.cidr_default
}


