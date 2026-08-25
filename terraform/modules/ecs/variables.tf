variable "project_name" {
  description = "Prefix used to name all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ECS container instances"
  type        = string
}

variable "desired_capacity" {
  description = "Number of EC2 instances in the ASG"
  type        = number
}

variable "ecs_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_instances_sg_id" {
  description = "Security group ID for ECS instances"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS instances"
  type        = list(string)
}

variable "efs_id" {
  description = "EFS file system ID"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN for Nginx"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name for Nginx container logs"
  type        = string
}