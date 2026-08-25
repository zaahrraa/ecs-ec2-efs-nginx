variable "project_name" {
  description = "Prefix used to name all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}