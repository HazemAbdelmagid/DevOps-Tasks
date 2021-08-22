# DevOps Tasks




## Project Overview

The aim of Capstone Udacity project is to use the skills acquired throughout Nano Degree journey to demonstrate Linting, Testing a simple Flask Web Application, Creating a docker image and push it towards AWS ECR then perform a rolling update on AWS EKS cluster, all these tasks performed using Circleci pipeline.

In this project some of Circleci orbs have been used:
  -   circleci/aws-ecr@6.15.3
  -   circleci/aws-eks@0.2.3
  -   circleci/kubernetes@0.4.0
---

## Setup the Environment, Lint, Test Application Locally

* Create a virtualenv and activate it
   ```
   python3 -m venv venv
   . venv/bin/activate
   ```
* Run `make install` to install the necessary dependencies
   ```
   pip install --upgrade pip && pip install -r requirements.txt
   wget -O ./hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64 && chmod +x ./hadolint
   ```

* Lint the App `make lint`
  ```
  ./hadolint Dockerfile
  pylint --disable=R,C,W1203 app.py
  ```

* Test the App `make test`
  ```
  python3 -m pytest -vv tests/*.py
  ```
---
## CircleCI Pipeline Jobs Overview
CircleCI is a modern continuous integration and continuous delivery (CI/CD) platform, it automates build, test, and deployment of software.

In this project, Circleci used to build an Entire Pipeline (Creating AWS EKS Cluster, Lint & Test Simple Flask Web Application, Build Docker image & push it to AWS ECR and performing Kubernetes Rolling update and here is the details for the jobs:

---

* Create Kubernetes Cluster using orbs circleci/aws-eks@1.0.3
  ```
  aws-eks/create-cluster:
    cluster-name: prod-cluster
  ```

* Create Deployment steps of an Original Application with aws-eks/python3 executor
  ```
  - aws-eks/update-kubeconfig-with-authenticator:
      cluster-name: << parameters.cluster-name >>
      install-kubectl: true
  - kubernetes/create-or-update-resource:
      resource-file-path: main-deployment.yml
      resource-name: deployment/main-deployment.yml
  ```
  
* Lint & Test The New App before building Docker image using `python:3.7.3-stretch` docker image
  ```
  . venv/bin/activate
  make install
  make lint
  make test
  ```

* Build The New App Dokcer image using orbs `aws-ecr/build-and-push-image`
  ```
  - aws-ecr/build-and-push-image:
        repo: devops-project
        tag: 'web-app-2.0'
  ```
* Perform Rolling Update using `aws-eks/python3`
  ```
  - aws-eks/update-kubeconfig-with-authenticator:
          cluster-name: << parameters.cluster-name >>
          install-kubectl: true
      - kubernetes/create-or-update-resource:
          get-rollout-status: true
          resource-file-path: rolling-deployment.yml
          resource-name: deployment/web-app-deployment
  ```

* Testing the cluster & New Application
  ```
  - run:
      name: "Post Rolling Deployment Commands For Testing New Application"
      command: |
        kubectl get nodes
        kubectl get deployment
        kubectl get services
        kubectl get pods
        curl "http://$lb:8000"
  ```
  
 ## References
 - https://circleci.com/developer/orbs/orb/circleci/aws-ecr
 - https://circleci.com/developer/orbs/orb/circleci/aws-eks
 - https://circleci.com/developer/orbs/orb/circleci/kubernetes
