# 1. Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Provision EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  key_name = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = "resume-analyzer-root-vol"
    }
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    groq_api_key = var.groq_api_key
    repo_url     = var.repo_url
    repo_branch  = var.repo_branch
  })

  tags = {
    Name = "resume-analyzer-server"
  }
}

# 3. Static Elastic IP for stable URL access
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "resume-analyzer-eip"
  }
}
