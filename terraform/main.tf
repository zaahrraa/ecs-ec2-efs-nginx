module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "security_groups" {
  source       = "./modules/security-groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "efs" {
  source              = "./modules/efs"
  project_name        = var.project_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  efs_sg_id           = module.security_groups.efs_sg_id
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
}

module "ecs" {
  source                       = "./modules/ecs"
  project_name                 = var.project_name
  aws_region                   = var.aws_region
  instance_type                = var.instance_type
  desired_capacity             = var.desired_capacity
  ecs_instance_profile_name    = module.iam.ecs_instance_profile_name
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  ecs_instances_sg_id          = module.security_groups.ecs_instances_sg_id
  private_subnet_ids           = module.vpc.private_subnet_ids
  efs_id                       = module.efs.efs_id
  target_group_arn             = module.alb.target_group_arn
  log_group_name               = module.cloudwatch.log_group_name
}