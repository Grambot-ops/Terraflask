# TerraFlask - Flask Application Deployment with AWS and Terraform

This project demonstrates how to deploy a Flask application on AWS using Terraform, Docker, and AWS services like ECS Fargate, Aurora PostgreSQL, and Application Load Balancer.

## Architecture Overview

The deployment architecture consists of the following components:

- **Flask Application**: A simple CRUD application containerized with Docker
- **Amazon ECS (Fargate)**: Serverless container orchestration
- **Aurora PostgreSQL**: Managed PostgreSQL database
- **Application Load Balancer (ALB)**: For distributing traffic
- **AWS VPC**: Private network with public and private subnets
- **Security Groups**: Network traffic control between components
- **IAM Roles and Policies**: For secure access to AWS resources
- **AWS Secrets Manager & SSM Parameter Store**: For managing sensitive information

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Docker installed
- Git installed

## Directory Structure

- `Docker+aurora/`: Main project directory
  - `example-flask-crud/`: Flask application code
  - `Dockerfile`: Containerization configuration
  - `docker-compose.yaml`: Local development setup
  - `Terraform/`: Infrastructure as Code for AWS deployment
  - `nginx/`: NGINX configuration (for local development)

## Deployment Steps

### 1. Build and Push Docker Image

```bash
# Navigate to the Docker directory
cd Docker+aurora

# Build the Docker image
docker build -t flask-crud-app .

# Log in to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 125755581655.dkr.ecr.us-east-1.amazonaws.com

# Tag the image
docker tag flask-crud-app 125755581655.dkr.ecr.us-east-1.amazonaws.com/flask-crud-r0984339-app:latest

# Push the image to ECR
docker push 125755581655.dkr.ecr.us-east-1.amazonaws.com/flask-crud-r0984339-app:latest
```

### 2. Deploy Infrastructure with Terraform

```bash
# Navigate to the Terraform directory
cd Docker+aurora/Terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Verify Deployment

```bash
# Check if ECS service is running
aws ecs describe-services --cluster flask-crud-r0984339-ecs-cluster --services flask-crud-r0984339-ecs-service

# Get the ALB DNS name
aws elbv2 describe-load-balancers --names flask-crud-r0984339-alb --query "LoadBalancers[0].DNSName" --output text

# Test the application
curl http://<alb-dns-name>/health
```

## Security Configuration

### Security Groups
The deployment uses several security groups to control traffic flow:

1. **ALB Security Group**:
   - Inbound: HTTP (80) and HTTPS (443) from anywhere
   - Outbound: Port 5000 to ECS Service Security Group

2. **ECS Service Security Group**:
   - Inbound: Port 5000 from ALB Security Group
   - Outbound: All traffic

3. **Aurora DB Security Group**:
   - Inbound: PostgreSQL port (5432) from ECS Service Security Group
   - Outbound: None (default)

### Network Configuration
- VPC with CIDR block 10.0.0.0/16
- Public subnets for ALB
- Private subnets for ECS tasks and Aurora DB
- NAT Gateway for outbound internet access from private subnets

## Troubleshooting

### Common Issues

1. **ALB Health Checks Failing**:
   - Ensure ALB security group has outbound rules to ECS tasks
   - Verify the health check path (/health) is correctly implemented in the Flask app
   - Check ECS task logs in CloudWatch

2. **Database Connection Issues**:
   - Verify security group rules between ECS tasks and Aurora
   - Check database endpoint and credentials in SSM Parameter Store
   - Ensure the Flask app is configured to handle connection errors gracefully

3. **Container Startup Problems**:
   - Check Docker image configuration
   - Verify environment variables and secrets are correctly passed
   - Examine container logs in CloudWatch

### Useful Commands

```bash
# View ECS task logs
aws logs get-log-events --log-group-name /ecs/flask-crud-r0984339-app --log-stream-name <log-stream-name>

# Check target health for ALB
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Force new ECS deployment
aws ecs update-service --cluster flask-crud-r0984339-ecs-cluster --service flask-crud-r0984339-ecs-service --force-new-deployment
```

## References

- [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [Network security best practices for Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-network.html)
- [AWS Security Group Best Practices](https://repost.aws/questions/QU7RlTsgkbSRWMIYLO9G3G8g/how-to-select-appropriate-ecs-service-security-group-and-alb-security-group)
- [Troubleshooting ECS and RDS connectivity](https://repost.aws/knowledge-center/ecs-task-connect-rds-database)

## License

This project is licensed under the MIT License.
