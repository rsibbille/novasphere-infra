output "web_public_ip" {
  description = "IP publique de l'instance web"
  value       = module.web.public_ip
}

output "web_instance_id" {
  description = "Identifiant de l'instance web"
  value       = module.web.instance_id
}

output "monitoring_public_ip" {
  description = "IP publique de l'instance monitoring"
  value       = module.monitoring.public_ip
}

output "monitoring_instance_id" {
  description = "Identifiant de l'instance monitoring"
  value       = module.monitoring.instance_id
}

output "ssh_command" {
  description = "Commande de connexion au web"
  value       = "ssh -i ~/.ssh/novasphere admin@${module.web.public_ip}"
}
