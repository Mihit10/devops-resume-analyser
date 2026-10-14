# IAM Role for EC2 Instance (Enables AWS Systems Manager SSM Session Manager)
resource "aws_iam_role" "ec2_role" {
  name = "resume-analyzer-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "resume-analyzer-ec2-role"
  }
}

# Attach AWS SSM Policy for browser-based shell access without SSH keys
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile to associate role with EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "resume-analyzer-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
