module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size = var.desired_capacity
      max_size     = var.max_size
      min_size     = var.min_size

      instance_types = ["t3.medium"]
      subnet_ids     = module.vpc.private_subnets
    }
  }

  cluster_endpoint_private_access = true   
  cluster_endpoint_public_access  = true   
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"] 

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
