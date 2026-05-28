# Multi-Cloud Disaster Recovery Solution

A capstone project implementing a multi-cloud disaster recovery solution where an application primarily runs on **AWS** and automatically fails over to **Azure** during service disruptions.

## Architecture

- **Primary:** AWS (us-east-1) — EC2 App Machine serving Nginx
- **Failover:** Azure (East US) — VM serving Nginx
- **Traffic Management:** AWS Route 53 with health check-based failover
- **CI/CD:** Jenkins declarative pipeline on AWS Tools Machine
- **IaC:** Terraform for both AWS and Azure infrastructure
- **Config Management:** Ansible for Nginx installation and deployment

## Project Structure

```
├── Task-1/aws/        # Terraform - AWS VPC, EC2, Security Groups, Key Pair
├── Task-1/azure/      # Terraform - Azure VNet, NSG, Virtual Machine
├── Task-2/            # Ansible - Nginx installation playbook + inventory
├── Task-3/            # Ansible - Custom HTML deployment playbook
├── Task-4/            # Jenkinsfile - CI/CD pipeline
└── Task-5/            # Route 53 failover setup
```

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform | Infrastructure provisioning (AWS + Azure) |
| Ansible | Configuration management and app deployment |
| Jenkins | CI/CD pipeline |
| AWS Route 53 | DNS failover and traffic management |
| Nginx | Web server on both clouds |
| GitHub | Source code and HTML file storage |

## How It Works

1. **Normal state:** Route 53 routes traffic to AWS App Machine (healthy)
2. **Failure:** AWS health check fails → Route 53 redirects to Azure VM
3. **Recovery:** AWS instance restored → traffic returns to AWS automatically
4. **Deployment:** GitHub change → Jenkins build → deploy to both clouds

## Setup

### Prerequisites
- AWS CLI configured (`aws configure`)
- Azure CLI logged in (`az login`)
- Terraform installed
- Ansible installed

### Task 1 - Infrastructure
```bash
# AWS
cd Task-1/aws
terraform init && terraform apply -auto-approve

# Azure
cd Task-1/azure
terraform init && terraform apply -auto-approve
```

### Task 2 - Install Nginx
```bash
cd Task-2
ansible-playbook -i inventory.ini nginx_install.yml
```

### Task 3 - Deploy Custom Pages
```bash
cd Task-3
ansible-playbook -i inventory.ini deploy.yml
```

### Task 4 - Jenkins Pipeline
- Install Jenkins on Tools Machine
- Create Pipeline job pointing to this GitHub repo
- Run build to deploy to both AWS and Azure

### Task 5 - Route 53 Failover
- Create hosted zone `upgrad.com`
- Add health check for AWS App Machine (port 80)
- Create Primary A record → AWS IP
- Create Secondary A record → Azure IP
