variable "aws_region" {
  description = "AWS region for provisioning resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, production)"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance size for hosting the Docker stack"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Optional AWS EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block permitted for SSH ingress"
  type        = string
  default     = "0.0.0.0/0"
}

variable "groq_api_key" {
  description = "API key for Groq LLM service"
  type        = string
  default     = ""
  sensitive   = true
}

variable "repo_url" {
  description = "Git repository URL to clone on the instance"
  type        = string
  default     = "https://github.com/Mihit10/devops-resume-analyser.git"
}

variable "repo_branch" {
  description = "Git branch to check out"
  type        = string
  default     = "master"
}
