##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "VPC" {
  cidr_block           = var.network_address_space[terraform.workspace]
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-vpc-Test-by-MIN" })
}

resource "aws_subnet" "Public" {
  count                   = var.subnet_count[terraform.workspace]
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = cidrsubnet(var.network_address_space[terraform.workspace], 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-Public${count.index + 1}" })
}


resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.VPC.id

  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-Igw" })
}

# ROUTING #
resource "aws_route_table" "publicRoute" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }
  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-publicRoute" })
}

resource "aws_route_table_association" "rt-pubsub" {
  count          = var.subnet_count[terraform.workspace]
  subnet_id      = aws_subnet.Public[count.index].id
  route_table_id = aws_route_table.publicRoute.id
}


# SECURITY GROUPS #
resource "aws_security_group" "elb-sg" {
  name   = "${var.billing_code_tag}-${local.env_name}-nginx_elb_sg"
  vpc_id = aws_vpc.VPC.id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-elb-sg" })
}

# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name        = "${var.billing_code_tag}-${local.env_name}-nginx_sg"
  description = "Allow ssh and web access"
  vpc_id      = aws_vpc.VPC.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.network_address_space[terraform.workspace]]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-nginx-sg" })
}

# LOAD BALANCER #
resource "aws_elb" "web" {
  name = "${var.billing_code_tag}-${local.env_name}-nginx-elb"

  subnets         = aws_subnet.Public[*].id
  security_groups = [aws_security_group.elb-sg.id]
  instances       = aws_instance.nginx[*].id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-elb" })
}

# S3
resource "aws_s3_bucket" "tf_course" {
  bucket = "npa2021"
  acl = "private"

  tags = merge(local.common_tags, { Name = "${var.billing_code_tag}-${local.env_name}-bucket" })
}