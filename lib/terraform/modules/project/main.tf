resource "digitalocean_project" "project" {
  name        = var.name
  description = "The ${var.name} project to represent a resources group"
  purpose     = var.purpose
  environment = var.env
  resources   = var.resources
}