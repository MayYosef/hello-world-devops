module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name   = "main-vpc"
  cidr   = var.vpc_cidr_block

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags_per_az = {
    "${var.aws_region}a" = {
      Name = "main-vpc-public-${var.aws_region}a"
      Environment = "dev"
    }
    "${var.aws_region}b" = {
      Name = "main-vpc-public-${var.aws_region}b"
      Environment = "dev"
    }
  }

  private_subnet_tags_per_az = {
    "${var.aws_region}a" = {
      Name = "main-vpc-private-${var.aws_region}a"
      Environment = "dev"
    }
    "${var.aws_region}b" = {
      Name = "main-vpc-private-${var.aws_region}b"
      Environment = "dev"
    }
  }

  public_route_table_tags = {
    Name = "main-vpc-public-rt"
    Environment = "dev"
  }

  private_route_table_tags = {
    Name = "main-vpc-private-rt"
    Environment = "dev"
  }
  
  tags = {
    Name = "main-vpc"
  }
}