# DevOps Tasks


# Task #1 [Configuring secure K8s cluster on AWS(EKS) using IAC (Terraform)]

### pre-requisites:

1- Terrafrom CLI installed [https://learn.hashicorp.com/tutorials/terraform/install-cli]

2- AWS CLI installed and configured [https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html]

## Description for files configured:

This task consists of 3 main files under `Terraform-EKS` directory, here is a description for each file:

1- `vpc.tf` : AWS EKS requires certain configurations related to VPC including [Subs, RTs, IGW, Nat GW, ...] to launch required resources [Worker Nodes, Pods, ...].

 2- `terraform.tfvars` : Contains values for some variables defined in `vpc.tf` file.

3- `eks-cluster.tf` : Here we use EKS terraform module in order to create K8s cluster also we use the network resources created from `vpc.tf` file.

## Implementation steps

* Run the following commands to initialize the modules, detect resources to be created and create the resources

   ```
   terrafrom init
   terraform plan
   terraform apply
   ```
---
# Task #2 [Deploying Sample Application on the created K8s cluster using Ansible]

### pre-requisites:

1- Make sure Python, AWS CLI installed and configured in correct way.

2- Aws-iam-authenticator installed [https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html]

3- kubectl utility installed [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/]

4- Ansible installed [https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html]
 

## Description for files configured:

This task consists of 2 main files under `Ansible-K8s` directory, here is a description for each file:

1- `nginx-app.yaml` : Contains K8s deployment and service resources to deploy nginx inside the cluster.

2- `deploy-to-k8s.yaml` : Contains Ansible configurations using K8s ansible collection to deploy nginx using `nginx-app.yaml` conf file.


## Implementation steps

* Connect to AWS EKS Cluster
   ```
   aws eks update-kubeconfig --name app-eks-cluster
   ```

* Install Ansible K8s collection used in ansible configuration file
   ```
   ansible-galaxy collection install community.kubernetes
   ```

* Running Ansible playbook against AWS EKS Cluster
   ```
   ansible-playbook deploy-to-k8s.yaml
   ```
---
---
# Task #3 [CICD pipeline using Azure Pipelines utilizing the following DevOps tools (SonarCloud, JFrog) and deploy sample app into AWS EKS] 

## Description for files configured:

This task consists of Several files in the root dir of the repo and I am going to explain the need for each one:

1- `app-config.yaml` : Contains K8s deployment and service resources to deploy simple flask app into the cluster.

2- `Dockerfile` : Contains all necessary instructions to build docker image for flask app.

3- `requirements.txt` : Contains all Deps required to perfrom simple linting and testing jobs on flask app.

4- `script.sh` : Contains some Deps that is necessary to install some tools to help deploying the app into the created AWS EKS cluster.

5- `app.py` : Simple flask web application code with 2 routes.

6- `tests/` : Directory contains simple test scenario for flask app.

7- `azure-pipelines.yml` : Main configuration file for Azure Pipeline.


## Pipeline High Overview:

Azure Pipeline consists of 4 Stages:

1- `Testing` : Linting and Running simple test scenario in order to make sure tha app code is fine.

2- `CodeAnalysis` : Code Quality checking applied using Sonar Cloud.

3- `Building` : Docker image is created using Dockerfile and Image has been pushed into JFrog Artifactory repo.

4- `Deploying` : Making sure that image exists on JFrog Artifactory and deploying the flask app into AWS EKS Cluster.

---
