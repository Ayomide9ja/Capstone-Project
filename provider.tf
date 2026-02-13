terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }

  backend "s3" {
    bucket         = "bedrock-state-baraka-alt-soe-025-1366"
    key            = "bedrock/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "Project"          = "Bedrock"
      "Project_Capstone" = "barakat-2025-capstone"
    }
  }
}

# 1. NEW BLOCK: Generate the token internally (No CLI needed!)
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# 2. UPDATED KUBERNETES PROVIDER
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  # FIX: Use the internal token instead of 'exec'
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# 3. UPDATED HELM PROVIDER
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    # FIX: Use the internal token instead of 'exec'
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}