output "alb_dns_name" {
  description = "Visit this URL in your browser to see Nginx running"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}