# D:\school\Semester 2\Cloud platforms\Terraflask\Docker+aurora\Terraform\terraform.tfvars

aws_region   = "us-east-1"
project_name = "flask-crud-r0984339"
az_count     = 2 #1 for now for test then 2 for later

app_image_uri = "125755581655.dkr.ecr.us-east-1.amazonaws.com/flask-crud-r0984339-app:latest" # <--- THIS IS THE LINE TO ENSURE IS CORRECT AND UNCOMMENTED

# --- ALB Variables (For HTTPS - Extra Points) ---
enable_https        = false
acm_certificate_arn = "arn:aws:acm:us-east-1:125755581655:certificate/YOUR_ACTUAL_CERTIFICATE_ID_HERE" # Ensure this is your valid cert ARN