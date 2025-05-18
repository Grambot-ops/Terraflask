# TerraFlask - Flask Application Deployment with AWS and Terraform

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-ready solution demonstrating how to deploy a Flask CRUD application on AWS using infrastructure as code with Terraform.

![Architecture Diagram](https://miro.medium.com/v2/resize:fit:1400/1*KD2lgyr7zCLqwXZgCm0Kpw.png)

## Table of Contents

- [Overview](#overview)
- [Application Functionality](#application-functionality)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Local Development](#local-development)
- [AWS Deployment](#aws-deployment)
  - [Step 1: Build and Push Docker Image](#step-1-build-and-push-docker-image)
  - [Step 2: Deploy Infrastructure with Terraform](#step-2-deploy-infrastructure-with-terraform)
  - [Step 3: Verify Deployment](#step-3-verify-deployment)
  - [Step 4: Access the Application](#step-4-access-the-application)
- [Infrastructure Details](#infrastructure-details)
  - [Security Configuration](#security-configuration)
  - [Network Architecture](#network-architecture)
  - [Database Configuration](#database-configuration)
  - [Secrets Management](#secrets-management)
- [Monitoring and Logging](#monitoring-and-logging)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Future Improvements](#future-improvements)
- [References](#references)
- [License](#license)

## Overview

TerraFlask demonstrates a modern cloud application deployment approach, combining Flask, Docker, and AWS services orchestrated through Terraform. This project showcases best practices for building a scalable, secure, and maintainable cloud infrastructure for web applications.

## Application Functionality

The Flask application is a simple CRUD (Create, Read, Update, Delete) application that allows users to:

- View a list of entries
- Add new entries with title and description
- Update existing entries
- Delete entries
- Toggle entry status

The application uses a PostgreSQL database for persistent storage, which is managed by AWS Aurora in the cloud deployment.

## Architecture

The deployment architecture consists of the following components:

- **Flask Application**: A containerized CRUD application running on ECS Fargate
- **Amazon ECS (Fargate)**: Serverless container orchestration service that eliminates the need to manage EC2 instances
- **Aurora PostgreSQL**: Fully managed, PostgreSQL-compatible database service with high availability
- **Application Load Balancer (ALB)**: Distributes incoming traffic across multiple targets in multiple Availability Zones
- **AWS VPC**: Virtual private cloud network with public and private subnets
- **Security Groups**: Virtual firewalls controlling traffic at the instance level
- **IAM Roles and Policies**: Securely control access to AWS resources
- **AWS Secrets Manager & SSM Parameter Store**: Secure storage for sensitive configuration and credentials
- **CloudWatch**: Monitoring and logging service for operational health insights

## Prerequisites

Before you begin, ensure you have the following installed:

- **AWS CLI** (version 2.x) configured with appropriate IAM permissions
- **Terraform** (version 1.0+)
- **Docker** (version 20.x+)
- **Git**
- An AWS account with permissions to create the required resources

## Directory Structure

```
TerraFlask/
├── Docker+aurora/              # Main project directory
│   ├── example-flask-crud/     # Flask application code
│   │   ├── app/                # Main application package
│   │   │   ├── __init__.py     # Application initialization
│   │   │   ├── config.py       # Configuration settings
│   │   │   ├── models.py       # Database models
│   │   │   ├── routes.py       # Application routes
│   │   │   └── templates/      # HTML templates
│   │   ├── migrations/         # Database migration files
│   │   ├── crudapp.py          # Application entry point
│   │   └── requirements.txt    # Python dependencies
│   ├── Dockerfile              # Docker container configuration
│   ├── docker-compose.yaml     # Local development configuration
│   ├── entrypoint.sh           # Container startup script
│   ├── init-flask-db.sh        # Database initialization script
│   ├── Terraform/              # Infrastructure as Code
│   │   ├── alb.tf              # Application Load Balancer config
│   │   ├── ecs.tf              # ECS Fargate config
│   │   ├── rds.tf              # Aurora PostgreSQL config
│   │   ├── vpc.tf              # Network configuration
│   │   ├── security_groups.tf  # Security configuration
│   │   └── ...                 # Other Terraform configs
│   └── nginx/                  # NGINX configuration (local dev)
└── README.md                   # Project documentation
```

## Local Development

To run the application locally for development:

1. Clone the repository and navigate to the project directory:
   ```bash
   git clone https://github.com/yourusername/terraflask.git
   cd terraflask/Docker+aurora
   ```

2. Create a `.env` file with the following configuration:
   ```
   DATABASE_URL=postgresql://postgres:postgres@db:5432/flaskapp
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgres
   POSTGRES_DB=flaskapp
   SECRET_KEY=your-secret-key
   FLASK_APP=crudapp.py
   FLASK_ENV=development
   ```

3. Start the application with Docker Compose:
   ```bash
   docker-compose up -d
   ```

4. Initialize the database (first time only):
   ```bash
   bash init-flask-db.sh
   ```

5. Access the application at `http://localhost:5000`

## AWS Deployment

### Step 1: Build and Push Docker Image

1. Navigate to the Docker directory:
   ```bash
   cd Docker+aurora
   ```

2. Build the Docker image:
   ```bash
   docker build -t flask-crud-app .
   ```

3. Log in to Amazon ECR:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
   ```

4. Tag the image:
   ```bash
   docker tag flask-crud-app YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-crud-app:latest
   ```

5. Push the image to ECR:
   ```bash
   docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-crud-app:latest
   ```

### Step 2: Deploy Infrastructure with Terraform

1. Navigate to the Terraform directory:
   ```bash
   cd Docker+aurora/Terraform
   ```

2. Create or edit `terraform.tfvars` with your configuration:
   ```
   aws_region   = "us-east-1"
   project_name = "flask-crud-YOUR_UNIQUE_ID"
   app_image_uri = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/flask-crud-app:latest"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment to review changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. Confirm by typing `yes` when prompted.

### Step 3: Verify Deployment

1. Check if the ECS service is running:
   ```bash
   aws ecs describe-services --cluster flask-crud-YOUR_UNIQUE_ID-ecs-cluster --services flask-crud-YOUR_UNIQUE_ID-ecs-service
   ```

2. Get the ALB DNS name:
   ```bash
   aws elbv2 describe-load-balancers --names flask-crud-YOUR_UNIQUE_ID-alb --query "LoadBalancers[0].DNSName" --output text
   ```

3. Test the application health check:
   ```bash
   curl http://ALB_DNS_NAME/health
   ```

### Step 4: Access the Application

Open your browser and go to the ALB DNS name URL:

```
http://ALB_DNS_NAME
```

You should see the Flask CRUD application running. You can now add, update, and delete entries.

## Infrastructure Details

### Security Configuration

The deployment implements a defense-in-depth approach with multiple security layers:

#### Security Groups
The deployment uses several security groups to control traffic flow:

1. **ALB Security Group**:
   - Inbound: HTTP (80) and HTTPS (443) from anywhere
   - Outbound: Port 5000 to ECS Service Security Group

2. **ECS Service Security Group**:
   - Inbound: Port 5000 from ALB Security Group only
   - Outbound: All traffic (for updates and database access)

3. **Aurora DB Security Group**:
   - Inbound: PostgreSQL port (5432) from ECS Service Security Group only
   - Outbound: None (default deny)

#### Network Architecture
- VPC with CIDR block `10.0.0.0/16`
- Public subnets for the ALB only
- Private subnets for ECS tasks and Aurora DB
- NAT Gateway for outbound internet access from private subnets
- Internet Gateway for ALB public access

#### Database Configuration
- Aurora PostgreSQL cluster with encryption at rest
- Private subnet placement
- Automated backups with 7-day retention
- Database credentials stored in AWS Secrets Manager

#### Secrets Management
- Database credentials stored in AWS Secrets Manager
- Flask application secret key stored in AWS Secrets Manager
- Database connection string stored in SSM Parameter Store
- Secure injection of secrets into ECS tasks at runtime

## Monitoring and Logging

The infrastructure includes comprehensive monitoring and logging:

- **CloudWatch Logs**: All application and ECS logs are sent to CloudWatch
- **CloudWatch Metrics**: ECS service and ALB metrics are available
- **ALB Access Logs**: Traffic logs are captured for security auditing
- **RDS Logs**: Database logs are exported to CloudWatch

To view application logs:
```bash
aws logs get-log-events --log-group-name /ecs/flask-crud-YOUR_UNIQUE_ID-app --log-stream-name ECS_TASK_LOG_STREAM
```

To view ALB access logs:
```bash
aws logs get-log-events --log-group-name /aws/alb/flask-crud-YOUR_UNIQUE_ID-alb-access-logs --log-stream-name ALB_LOG_STREAM
```

## Troubleshooting

### Common Issues

1. **ALB Health Checks Failing**:
   - Ensure ALB security group has outbound rules to ECS tasks
   - Verify the health check path (`/health`) is correctly implemented in the Flask app
   - Check ECS task logs in CloudWatch for application errors
   - Ensure container port mapping is correctly set to 5000

2. **Database Connection Issues**:
   - Verify security group rules between ECS tasks and Aurora
   - Check database endpoint and credentials in SSM Parameter Store
   - Ensure the Flask app is configured to handle connection errors gracefully
   - Check for proper database initialization with migrations

3. **Container Startup Problems**:
   - Check Docker image configuration and entrypoint script
   - Verify environment variables and secrets are correctly passed to the container
   - Examine container logs in CloudWatch for startup errors
   - Ensure ECS task execution role has proper permissions

### Useful Commands

```bash
# View ECS task logs
aws logs get-log-events --log-group-name /ecs/flask-crud-YOUR_UNIQUE_ID-app --log-stream-name LOG_STREAM_NAME

# List all ECS task log streams
aws logs describe-log-streams --log-group-name /ecs/flask-crud-YOUR_UNIQUE_ID-app

# Check target health for ALB
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN

# Force new ECS deployment (e.g., after updating the Docker image)
aws ecs update-service --cluster flask-crud-YOUR_UNIQUE_ID-ecs-cluster --service flask-crud-YOUR_UNIQUE_ID-ecs-service --force-new-deployment

# Check database connectivity from ECS task (requires SSM Session Manager and task in RUNNING state)
aws ecs execute-command --cluster flask-crud-YOUR_UNIQUE_ID-ecs-cluster --task TASK_ID --container app --command "/bin/sh" --interactive
```

## Cleanup

To avoid incurring charges, clean up resources when no longer needed:

1. Destroy the Terraform-managed infrastructure:
   ```bash
   cd Docker+aurora/Terraform
   terraform destroy
   ```

2. Confirm by typing `yes` when prompted.

3. Delete the ECR repository and Docker images (optional):
   ```bash
   aws ecr delete-repository --repository-name flask-crud-YOUR_UNIQUE_ID-app --force
   ```

## Future Improvements

Potential enhancements for this project:

- HTTPS support with AWS Certificate Manager
- Implement CI/CD pipeline with GitHub Actions or AWS CodePipeline
- Add AWS WAF for additional security
- Implement database read replicas for improved performance
- Set up automated database backups to S3
- Implement auto-scaling for ECS tasks based on load
- Add CloudFront distribution for global content delivery
- Implement monitoring and alerting with CloudWatch Alarms

## References

- [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [AWS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)
- [Network security best practices for Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-network.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Security Group Best Practices](https://repost.aws/questions/QU7RlTsgkbSRWMIYLO9G3G8g/how-to-select-appropriate-ecs-service-security-group-and-alb-security-group)
- [Troubleshooting ECS and RDS connectivity](https://repost.aws/knowledge-center/ecs-task-connect-rds-database)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Documentation](https://docs.docker.com/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
