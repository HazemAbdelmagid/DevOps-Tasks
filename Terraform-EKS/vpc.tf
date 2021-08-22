provider "aws" {
    region = "ca-central-1"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

data "aws_availability_zones" "azs" {}

module "app-vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "3.6.0"
  
    name = "app-vpc"
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks
    azs = data.aws_availability_zones.azs.names
    
    enable_nat_gateway = true     # NAT GW explicitly enabled.
    single_nat_gateway = true     # Shared NAT GW for all private subnets.
    enable_dns_hostnames = true   # Assign public & private DNS names for private and public ips.

  # These Tags will be used to help Master processes [Controller Manager] to know which vpc,subnets to talk to. 
  tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
  }

  public_subnet_tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
        "kubernetes.io/cluster/app-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1
  }
}
