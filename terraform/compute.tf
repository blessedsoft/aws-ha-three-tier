resource "aws_launch_template" "web" {
  name_prefix   = "${local.name}-web-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.web_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(templatefile("${path.module}/user-data/web.sh", {
    app_internal_dns = aws_lb.internal.dns_name
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name}-web"
      Tier = "web"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "${local.name}-web-asg"
  min_size            = var.web_min_size
  desired_capacity    = var.web_desired_size
  max_size            = var.web_max_size
  vpc_zone_identifier = [for key in sort(keys(aws_subnet.web)) : aws_subnet.web[key].id]

  health_check_type         = "ELB"
  health_check_grace_period = 180
  target_group_arns         = [aws_lb_target_group.web.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-web"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name}-app-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.app_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(templatefile("${path.module}/user-data/app.sh", {
    db_host       = aws_db_instance.postgres.address
    db_name       = var.db_name
    db_secret_arn = aws_db_instance.postgres.master_user_secret[0].secret_arn
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name}-app"
      Tier = "app"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${local.name}-app-asg"
  min_size            = var.app_min_size
  desired_capacity    = var.app_desired_size
  max_size            = var.app_max_size
  vpc_zone_identifier = [for key in sort(keys(aws_subnet.app)) : aws_subnet.app[key].id]

  health_check_type         = "ELB"
  health_check_grace_period = 240
  target_group_arns         = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-app"
    propagate_at_launch = true
  }

  depends_on = [aws_iam_role_policy.app_secret]
}
