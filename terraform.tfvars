# IAM Access and Secret Key for your IAM user
aws_access_key = ""

aws_secret_key = ""

# Name of the key pair in AWS, MUST be in same region as EC2 instance
# Check README for AWS CLI commands to create a key pair
key_name = "vockey"

# Local path to pem file for key pair. 
# Windows paths need to use double-backslash: Ex. C:/Users/min23/OneDrive - KMITL/Desktop/NPA Project/labsuser.pem
private_key_path = "" 

# Environment tag for all resources being created. You can leave this value as-is.
environment_tag = "dev"

# Made up billing code to be added as a tag to resources. You can leave this value as-is.
billing_code_tag = "NPA21"

network_address_space = {
  Development = "10.0.0.0/16"
  Production = "10.1.0.0/16"
}

instance_size = {
  Development = "t2.micro"
  Production = "t2.small"
}

subnet_count = {
  Development = 2
  Production = 3
}

instance_count = {
  Development = 2
  Production = 4
}