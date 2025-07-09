module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size = var.desired_capacity
      max_size     = var.max_size
      min_size     = var.min_size

      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}