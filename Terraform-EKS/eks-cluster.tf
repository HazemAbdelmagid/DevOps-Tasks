# Passing Kubernetes provider with required info regarding API Server Endpoint and necessary auth data.
provider "kubernetes" {
    host = data.aws_eks_cluster.app-cluster.endpoint
    token = data.aws_eks_cluster_auth.app-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.app-cluster.certificate_authority.0.data)
}

# Using some Data sources to get the endpoint of cluster [API Server], token and certificate info required by kubernetes provider.
data "aws_eks_cluster" "app-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "app-cluster" {
    name = module.eks.cluster_id
}

# Here we use VPC Module provided by Hashicorp to Create our K8s cluster on AWS using AWS EKS.
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "17.1.0"

    cluster_name = "app-eks-cluster"
    cluster_version = "1.17"

    # Here we define VPC, Private subnets that worker nodes will be launched in, which will give security to our cluster and launched pods.
    subnets = module.app-vpc.private_subnets
    vpc_id = module.app-vpc.vpc_id

    # Some defined tags.
    tags = {
        environment = "Production"
        application = "app"
    }

    # Self Managed EC2 instances, Here we define the capacity of our worker nodes and numbers.
    worker_groups = [
        {
            instance_type = "t2.micro"
            name = "app-worker-group-1"
            asg_desired_capacity = 3
        }
    ]
}
