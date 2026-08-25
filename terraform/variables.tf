variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name all resources"
  type        = string
  default     = "ecs-ec2-efs-nginx"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for ECS container instances"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Number of EC2 instances in the ASG"
  type        = number
  default     = 2
}