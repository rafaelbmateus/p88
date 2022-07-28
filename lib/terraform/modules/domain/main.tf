resource "digitalocean_domain" "domain" {
   name = var.domain
   ip_address = var.ipv4
}

output "urn" {
  value       = digitalocean_domain.domain.urn
  description = "The private IP address of the main server instance."
}
