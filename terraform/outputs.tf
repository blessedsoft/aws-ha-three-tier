output "public_alb_dns_name" {
  description = "Public ALB DNS name."
  value       = aws_lb.public.dns_name
}

output "public_alb_url" {
  description = "Public application URL."
  value       = var.acm_certificate_arn == null ? "http://${aws_lb.public.dns_name}" : "https://${aws_lb.public.dns_name}"
}

output "internal_alb_dns_name" {
  value = aws_lb.internal.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint; password is not exposed."
  value       = aws_db_instance.postgres.address
}

output "rds_secret_arn" {
  description = "AWS-managed RDS secret ARN."
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
  sensitive   = true
}

output "web_asg_name" {
  value = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}

output "availability_zones" {
  value = [local.az_a, local.az_b]
}
