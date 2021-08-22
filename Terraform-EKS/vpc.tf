# Using AWS Provider to be able to launch and query AWS resources.
provider "aws" {
    region = "ca-central-1"  # Define specific region to launch resources in.
}

# Here is some defined variables.
variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

# Specific Data source to get all availability zones in specific region, instead of typing them.
data "aws_availability_zones" "azs" {}


# Here we use VPC Module provided by Hashicorp to launch required resources by AWS EKS.
module "app-vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "3.6.0"
    name = "app-vpc"

    # Here we make sure that required attributes by module got a certain values [referenced by another variables defined in terraform.tfvars file]
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks
    azs = data.aws_availability_zones.azs.names
    
    enable_nat_gateway = true     # NAT GW explicitly enabled [enabled by default].
    single_nat_gateway = true     # Shared NAT GW for all private subnets.
    enable_dns_hostnames = true   # Assign public & private DNS names for private and public ips.

  # These Tags will be used to help Master processes [Cloud Controller Manager] to know which vpc,subnets to talk to. 
  tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
  }

  public_subnet_tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1      # This tag will allow Public Loadbalancers to be created in Public subnets to be accessible [For LoadBalancer Services in K8s].
  }

  private_subnet_tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1   # This tag will allow Internal Loadbalancers to be created in Private subnets to be accessible [For Internal Services in K8s].
  }
}
