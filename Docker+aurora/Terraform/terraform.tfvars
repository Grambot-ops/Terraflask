# terraform.tfvars

aws_region   = "us-east-1" # Or your chosen region from global_variables.tf
project_name = "flask-crud-r0984339" # From global_variables.tf

# You will set this after building and pushing your Docker image
# app_image_uri = "YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/flask-crud-r0984339-app:latest"

# --- ALB Variables (Only if doing HTTPS) ---
# enable_https        = true
# acm_certificate_arn = "arn:aws:acm:YOUR_REGION:YOUR_ACCOUNT_ID:certificate/YOUR_CERT_ID"