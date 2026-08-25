resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# user_data: on boot, tell the instance which ECS cluster to join,
# then mount the EFS file system at /mnt/efs so containers can use it.
locals {
  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
    yum install -y amazon-efs-utils
    
    # Install and start SSM Agent
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    
    mkdir -p /mnt/efs
    mount -t efs -o tls ${var.efs_id}:/ /mnt/efs
    echo "${var.efs_id}:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
    
    # Create default index.html if it doesn't exist
    if [ ! -f /mnt/efs/index.html ]; then
      echo "<h1>Hello from EFS-backed Nginx</h1>" | sudo tee /mnt/efs/index.html
    fi
  EOF
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  iam_instance_profile { name = var.ecs_instance_profile_name }
  vpc_security_group_ids = [var.ecs_instances_sg_id]
  user_data               = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-ecs-instance" }
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = 1
  max_size            = 4
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-nginx"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  execution_role_arn       = var.ecs_task_execution_role_arn
  cpu                      = 256
  memory                   = 256

  volume {
    name = "efs-html"
    host_path = "/mnt/efs"
  }

  container_definitions = jsonencode([{
    name      = "nginx"
    image     = "nginx:latest"
    cpu       = 256
    memory    = 256
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 0   # dynamic host port, ALB tracks it
      protocol      = "tcp"
    }]
    mountPoints = [{
      sourceVolume  = "efs-html"
      containerPath = "/usr/share/nginx/html"
      readOnly      = false
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "nginx"
      }
    }
  }])
}

resource "aws_ecs_service" "nginx" {
  name            = "${var.project_name}-nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = var.desired_capacity
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs]
}