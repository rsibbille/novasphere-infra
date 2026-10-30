output "alb_dns_name" {
  description = "Adresse DNS publique du load balancer"
  value       = aws_lb.web.dns_name
}
