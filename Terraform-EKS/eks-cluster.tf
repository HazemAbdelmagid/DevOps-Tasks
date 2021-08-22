provider "kubernetes" {
    host = data.aws_eks_cluster.app-cluster.endpoint
    token = data.aws_eks_cluster_auth.app-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.app-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "app-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "app-cluster" {
    name = module.eks.cluster_id
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "17.1.0"

    cluster_name = "app-eks-cluster"
    cluster_version = "1.17"

    subnets = module.app-vpc.private_subnets
    vpc_id = module.app-vpc.vpc_id

    tags = {
        environment = "Production"
        application = "app"
    }
    # Self Managed EC2 instances.
    worker_groups = [
        {
            instance_type = "t2.micro"
            name = "app-worker-group-1"
            asg_desired_capacity = 3
        }
    ]
}