variable "project_name" {
  description = "Prefix used to name all resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "efs_sg_id" {
  description = "Security group ID for EFS (allows NFS from ECS instances)"
  type        = string
}