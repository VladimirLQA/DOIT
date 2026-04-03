# --------- VPC ---------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# ---- Internet Gateway ---------
# Attaches to the VPC and allows public subnets to reach
# the internet (and be reached from it).

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

# ----- Public Subnets ---------
# One per AZ. Resources here can receive inbound internet
# traffic (ALB, Bastion, NAT gateway live here)

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Type        = "public"
  }
}

# ----- Private Subnets ---------
# One per AZ. Resources here cannot receive inbound internet
# traffic (EC2, RDS, etc.). Outbound internet traffic routes through NAT gateway.

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    Type        = "private"
  }
}

# --- Elastic IP for NAT Gateway ------------------------
# A NAT Gateway needs a static public IP address.
# aws_eip reserves one from AWS.

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# --- NAT Gateway ---------------------------------------
# Lives in public subnet 1. Lets private subnet resources
# make outbound internet requests (e.g. npm install, OS
# updates) without being publicly reachable themselves.

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# --- Public Route Table --------------------------------
# Sends all non-local traffic (0.0.0.0/0) to the IGW.
# Associated with both public subnets.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }


  tags = {
    Environment = var.environment
    Name        = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# --- Private Route Table -------------------------------
# Sends all non-local traffic to the NAT Gateway.
# Associated with both private subnets.

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
