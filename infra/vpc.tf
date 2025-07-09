module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "main-vpc"
  cidr   = var.vpc_cidr_block

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "main-vpc"
  }
}