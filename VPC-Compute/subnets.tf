# VPC-Compute/subnets.tf

# Public subnet - internet-facing
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Tag-BK"
    Type = "Public"
  }
}

# Second public subnet - different AZ
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"  # Different CIDR
  availability_zone       = "us-east-2b"   # Different AZ (yours is likely us-east-2a)
  map_public_ip_on_launch = true

  tags = {
    Name = "Tag-BK"
    Type = "Public"
  }
}

# Private subnet - internal only
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "Tag-BK"
    Type = "Private"
  }
}