resource "digitalocean_droplet" "droplet" {
    name = "${var.name}-${var.env}"
    image = var.image
    region = var.region
    size = var.size
    ssh_keys = ["${var.ssh_fingerprint}"]
    tags = var.tags
    monitoring = true

    connection {
        host = self.ipv4_address
        user = var.user
        type = "ssh"
        private_key = file(var.user_pvt_key)
        timeout = "2m"
    }
}

output "urn" {
  value       = digitalocean_droplet.droplet.urn
}

output "ipv4" {
  value       = digitalocean_droplet.droplet.ipv4_address
  description = "The private IP address of the main server instance."
}
