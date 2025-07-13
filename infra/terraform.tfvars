# terraform.tfvars
aws_region          = "us-east-1"
vpc_cidr_block      = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
cluster_name        = "eks-cluster-may"
desired_capacity    = 2
min_size            = 2
max_size            = 4
