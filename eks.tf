module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "project-bedrock-cluster" # Requirement: Cluster Name
  cluster_version = "1.34" # Requirement >= 1.24

  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Requirement 4.4: Control Plane Logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }

  # Grant the Creator (You) Admin Access
  enable_cluster_creator_admin_permissions = true

  # Requirement 4.3: Map the Developer User to the Kubernetes "view" group
  access_entries = {
    # The developer user we create in iam.tf
    dev_view = {
      principal_arn = aws_iam_user.bedrock_dev.arn
      kubernetes_groups = ["view-group"] # We will bind this group to a Role later
      policy_associations = {
        view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

# Add-ons (including Observability/CloudWatch)
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Requirement 4.4: Application Logging (FluentBit / CloudWatch)
  enable_aws_for_fluentbit = true
  aws_for_fluentbit = {
    set = [
      {
        name  = "cloudWatch.region"
        value = "us-east-1"
      }
    ]
  }
}