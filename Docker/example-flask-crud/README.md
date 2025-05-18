
# TerraFlask 🚀

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

A production-ready Flask CRUD application deployed on AWS using Terraform, Docker, and AWS services including ECS Fargate, Aurora PostgreSQL, and Application Load Balancer.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Architecture Overview](#-architecture-overview)
- [Prerequisites](#-prerequisites)
- [Local Development](#-local-development)
- [AWS Deployment](#-aws-deployment)
- [Security Configuration](#-security-configuration)
- [Customization](#-customization)
- [Monitoring & Logging](#-monitoring--logging)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## 🚀 Quick Start

Clone the repository and set up your local environment:

```bash
# Clone repository
git clone https://github.com/yourusername/terraflask.git
cd terraflask

# Set up local development environment
cd Docker/example-flask-crud
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
flask run

# Access the application
# Visit http://localhost:5000 in your browser
```

## 🏗️ Architecture Overview

This project implements a modern cloud-native architecture with the following components:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Internet  │────▶│     ALB     │────▶│  ECS Tasks  │────▶│    Aurora   │
│             │     │ (Public SN) │     │ (Private SN)│     │ (Private SN)│
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                           │                   ▲                   ▲
                           │                   │                   │
                           ▼                   │                   │
                    ┌─────────────┐           │                   │
                    │  CloudWatch │◀──────────┘                   │
                    │   Logs      │                               │
                    └─────────────┘                               │
                           ▲                                      │
                           │                                      │
                    ┌─────────────┐                      ┌─────────────┐
                    │ Secrets Mgr │                      │  Parameter  │
                    │   & SSM     │◀─────────────────────│    Store    │
                    └─────────────┘                      └─────────────┘
```

- **Flask Application**: Containerized CRUD application with health checks and graceful error handling
- **Amazon ECS (Fargate)**: Serverless container management without managing servers
- **Aurora PostgreSQL**: Managed relational database with high performance and availability
- **Application Load Balancer**: Distributes incoming traffic across multiple ECS tasks
- **AWS VPC**: Isolated network with private and public subnets for security
- **Security Groups**: Fine-grained traffic control between components
- **IAM Roles**: Principle of least privilege access control
- **AWS Secrets Manager & SSM**: Secure management of credentials and configuration

## 📋 Prerequisites

- **AWS Account** with Administrator access
- **AWS CLI** (v2+) configured with appropriate credentials
- **Terraform** (v0.14.7+) installed
- **Docker** (v20+) installed
- **Python** (v3.6+) installed
- **Git** for version control

## 💻 Local Development

### Running with Python

```bash
# Navigate to the Flask application
cd Docker/example-flask-crud

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Initialize database
export FLASK_APP=crudapp.py
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# Run development server
flask run
```

### Running with Docker Compose

```bash
# Navigate to Docker directory
cd Docker+aurora

# Create .env file with database configuration
echo "DATABASE_URL=postgresql://postgres:postgres@db:5432/flaskdb" >> .env
echo "POSTGRES_USER=postgres" >> .env
echo "POSTGRES_PASSWORD=postgres" >> .env
echo "POSTGRES_DB=flaskdb" >> .env

# Start the application and database
docker-compose up -d

# Access the application at http://localhost:5000
```

## ☁️ AWS Deployment

### Step 1: Authenticate with AWS

Ensure your AWS credentials are properly configured:

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, region, and output format
```

### Step 2: Build and Push Docker Image

```bash
# Navigate to project root
cd terraflask

# Build the Docker image
docker build -t flask-crud-app -f Docker+aurora/Dockerfile .

# Log in to ECR (replace ACCOUNT_ID with your AWS account ID)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository if it doesn't exist
aws ecr create-repository --repository-name flask-crud-app

# Tag the image
docker tag flask-crud-app ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-crud-app:latest

# Push the image to ECR
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-crud-app:latest
```

### Step 3: Deploy Infrastructure with Terraform

```bash
# Navigate to Terraform directory
cd Docker+aurora/Terraform

# Initialize Terraform
terraform init

# Create terraform.tfvars file
cat > terraform.tfvars << EOF
aws_region = "us-east-1"
project_name = "flask-crud-app"
app_image_uri = "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-crud-app:latest"
EOF

# Preview changes
terraform plan

# Apply the configuration
terraform apply -auto-approve

# Save the outputs
terraform output > deployment_outputs.txt
```

### Step 4: Verify Deployment

```bash
# Get the ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test health check endpoint
curl http://$ALB_DNS/health

# Open in browser for full application view
echo "Open http://$ALB_DNS in your browser"
```

## 🔒 Security Configuration

### Security Groups

| Security Group | Inbound Rules | Outbound Rules | Purpose |
|----------------|---------------|----------------|---------|
| ALB | HTTP (80), HTTPS (443) from 0.0.0.0/0 | All traffic to ECS SG | Public access to application |
| ECS | Port 5000 from ALB SG | All traffic | Container access |
| Aurora DB | PostgreSQL (5432) from ECS SG | None | Database protection |

### Network Configuration

- **VPC**: CIDR block 10.0.0.0/16 with public and private subnets
- **Public Subnets**: For ALB, with route to Internet Gateway
- **Private Subnets**: For ECS tasks and Aurora, with NAT Gateway for outbound traffic
- **Network ACLs**: Default rules with additional restrictions for database subnets

### Secrets Management

- Database credentials stored in AWS Secrets Manager
- Connection strings stored as secure parameters in SSM Parameter Store
- IAM roles with least privilege principle for ECS tasks

## 🔧 Customization

### Application Configuration

To customize the Flask application:

1. Modify files in `Docker/example-flask-crud/app/`
2. Update database models in `models.py`
3. Modify routes in `routes.py`
4. Update templates in `templates/` directory

### Infrastructure Customization

To customize the AWS infrastructure:

1. Adjust instance sizes in `application_variables.tf`
2. Modify database settings in `database_variables.tf`
3. Update network configuration in `networking_variables.tf`
4. Change region or availability zones in `global_variables.tf`

## 📊 Monitoring & Logging

### CloudWatch

All ECS tasks send logs to CloudWatch Logs. View them with:

```bash
# Get the log group name
LOG_GROUP=$(terraform output -raw cloudwatch_log_group_ecs)

# View the most recent log stream
aws logs describe-log-streams --log-group-name $LOG_GROUP --order-by LastEventTime --descending --limit 1

# Get the log stream name from the output above
LOG_STREAM="your-log-stream-name"

# View logs
aws logs get-log-events --log-group-name $LOG_GROUP --log-stream-name $LOG_STREAM
```

### Performance Metrics

Set up CloudWatch Alarms for critical metrics:

```bash
# CPU utilization alarm for ECS service
aws cloudwatch put-metric-alarm \
  --alarm-name HighCPUUtilization \
  --alarm-description "Alarm when CPU exceeds 70%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ClusterName,Value=flask-crud-app-ecs-cluster Name=ServiceName,Value=flask-crud-app-ecs-service \
  --evaluation-periods 2 \
  --alarm-actions your-sns-topic-arn
```

## 🔍 Troubleshooting

### Common Issues and Solutions

| Issue | Possible Causes | Solutions |
|-------|----------------|-----------|
| ALB Health Checks Failing | Security group misconfiguration, Route issues, Flask app not responding | Check SG rules, Verify health endpoint implementation, Check ECS logs |
| Database Connection Failing | SG rules, Incorrect credentials, Network issues | Verify SG rules, Check credentials in Secrets Manager, Test connectivity from ECS task |
| ECS Tasks Not Starting | Insufficient resources, Image issues, IAM permissions | Check resource allocation, Verify Docker image, Check IAM roles |
| 5xx Errors | Application errors, Resource constraints | Check application logs, Increase task resources |

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster flask-crud-app-ecs-cluster --services flask-crud-app-ecs-service

# View ALB target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw alb_target_group_arn)

# Check most recent ECS events
aws ecs describe-services --cluster flask-crud-app-ecs-cluster --services flask-crud-app-ecs-service --query 'services[0].events[0:5]'

# Force a new deployment
aws ecs update-service --cluster flask-crud-app-ecs-cluster --service flask-crud-app-ecs-service --force-new-deployment
```

### Logs Retrieval

```bash
# Get the most recent container logs
TASK_ID=$(aws ecs list-tasks --cluster flask-crud-app-ecs-cluster --service-name flask-crud-app-ecs-service --query 'taskArns[0]' --output text | cut -d'/' -f3)
aws ecs execute-command --cluster flask-crud-app-ecs-cluster --task $TASK_ID --container app --interactive --command "/bin/sh"
```

## 👥 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Please follow our [code style guidelines](CONTRIBUTING.md) and ensure all tests pass.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Deploying Apps with Terraform and AWS](https://www.pluralsight.com/resources/blog/cloud/deploying-apps-terraform-aws)
- [AWS Open Source Blog](https://aws.amazon.com/blogs/opensource/deploying-python-flask-microservices-to-aws-using-open-source-tools/)

---

Built with ❤️ by [Maximus Mukiza]
